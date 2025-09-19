// lib/screens/bilans/bilans_en_cours_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:adomed_app/theme/app_theme.dart';
import 'bilan_tracker_screen.dart';

class BilansEnCoursScreen extends StatelessWidget {
  final String? uid;
  const BilansEnCoursScreen({super.key, this.uid});

  // Fonction pour annuler un bilan
  Future<void> _cancelBilan(BuildContext context, String bilanId) async {
    final bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer l\'annulation'),
        content: const Text('Êtes-vous sûr de vouloir annuler cette demande de bilan ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Non'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Oui, annuler'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance.collection('bilans').doc(bilanId).delete();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('La demande de bilan a été annulée.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('bilans')
          .where('uid', isEqualTo: uid)
          .where('status', whereIn: ['pending', 'validé', 'en cours', 'En attente']) // 'En attente' ajouté pour la rétrocompatibilité
          .snapshots(),
      builder: (_, snap) {
        if (snap.hasError) return Center(child: Text('Erreur : ${snap.error}'));
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snap.data!.docs;
        if (docs.isEmpty) {
          return const Center(child: Text('Aucun bilan en cours'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (_, i) {
            final data = docs[i].data() as Map<String, dynamic>;
            final bilanId = docs[i].id;
            final status = data['status'] ?? '';

            // MODIFICATION : Le statut est maintenant dans un Chip, et on conditionne l'affichage du bouton Annuler
            return Card(
              child: ListTile(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => BilanTrackerScreen(bilanId: bilanId)));
                },
                leading: const CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: Icon(Icons.science_outlined, color: Colors.white)
                ),
                title: Text(data['type'], style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                subtitle: Text('${data['totalPrice']} FCFA', style: Theme.of(context).textTheme.bodyMedium),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Chip(
                      label: Text(status, style: const TextStyle(color: AppColors.primaryText)),
                      backgroundColor: Colors.grey.shade200,
                    ),
                    // Affiche le bouton uniquement si le statut est 'En attente'
                    if (status == 'En attente')
                      IconButton(
                        icon: const Icon(Icons.cancel_outlined, color: Colors.red),
                        onPressed: () => _cancelBilan(context, bilanId),
                        tooltip: 'Annuler',
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}