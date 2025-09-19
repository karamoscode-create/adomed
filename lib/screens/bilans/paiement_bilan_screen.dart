// lib/screens/bilans/paiement_bilan_screen.dart

import 'package:flutter/material.dart';
import 'package:adomed_app/theme/app_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:adomed_app/screens/home/home_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

class PaiementBilanScreen extends StatefulWidget {
  final List<Map<String, dynamic>> analyses;
  final int totalPrice;
  final String type;
  final DateTime date;
  final String location;

  const PaiementBilanScreen({
    super.key,
    required this.analyses,
    required this.totalPrice,
    required this.type,
    required this.date,
    required this.location,
  });

  @override
  State<PaiementBilanScreen> createState() => _PaiementBilanScreenState();
}

class _PaiementBilanScreenState extends State<PaiementBilanScreen> {
  bool _isLoading = false;
  final User? user = FirebaseAuth.instance.currentUser;

  Future<void> _sendOrderAndSave() async {
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erreur: Utilisateur non trouvé')));
      return;
    }

    setState(() => _isLoading = true);
    String? bilanId;

    try {
      // 1. Sauvegarder la commande dans la collection 'bilans'
      final bilanDocRef = await FirebaseFirestore.instance.collection('bilans').add({
        'uid': user!.uid, 'analyses': widget.analyses, 'totalPrice': widget.totalPrice,
        'type': widget.type, 'status': 'En attente', 'createdAt': FieldValue.serverTimestamp(),
        'date': widget.date, 'location': widget.location,
      });
      bilanId = bilanDocRef.id;

      // 2. Préparer le message pour WhatsApp
      final analysesList = widget.analyses.map((e) => "- ${e['name']}").join('\n');
      final formattedDate = DateFormat('dd MMMM yyyy', 'fr_FR').format(widget.date);
      final String message = "Bonjour Docteur,\n\n"
          "Je souhaite faire le bilan médical suivant :\n\n"
          "*Type de Bilan :* ${widget.type}\n"
          "*Analyses :*\n$analysesList\n\n"
          "À la date du : *$formattedDate*\n"
          "Lieu : ${widget.location}\n\n"
          "ID de la commande : $bilanId";

      // 3. Envoyer le message sur WhatsApp
      const String phoneNumber = '2250704044643';
      final Uri url = Uri.parse('https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}');
      
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw 'Impossible de lancer WhatsApp.';
      }

      // 4. Mettre à jour le profil utilisateur et l'agenda (NOUVELLE LOGIQUE)
      final formattedToday = DateFormat('dd/MM/yyyy').format(DateTime.now());
      final userRef = FirebaseFirestore.instance.collection('users').doc(user!.uid);
      
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        // Mettre à jour le dernier bilan dans le profil
        transaction.update(userRef, {'lastCheck': formattedToday});
        
        // Ajouter un rendez-vous pour le bilan
        transaction.set(userRef.collection('appointments').doc(), {
          'title': 'Demande de Bilan Médical',
          'status': 'OK',
          'date': widget.date, // On utilise la date choisie pour le bilan
          'type': 'Bilan',
        });
      });
      
      // 5. Naviguer vers l'accueil
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Votre demande a été envoyée et votre profil mis à jour !')));
      }

    } catch (e) {
      if (bilanId != null) {
        await FirebaseFirestore.instance.collection('bilans').doc(bilanId).delete();
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: ${e.toString()}')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Le widget build reste le même
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Container(decoration: const BoxDecoration(gradient: AppColors.primaryGradient)),
          Padding(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 20),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
              child: Container(
                color: AppTheme.backgroundColor.withOpacity(0.95),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(4, 20, 16, 10),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimaryColor),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          const Expanded(
                            child: Text(
                              'Finaliser la commande',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimaryColor),
                            ),
                          ),
                          const SizedBox(width: 48),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Spacer(),
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    const Icon(Icons.payment, size: 48, color: AppColors.primary),
                                    const SizedBox(height: 16),
                                    Text('Total à payer', style: Theme.of(context).textTheme.bodyMedium),
                                    Text('${widget.totalPrice} FCFA', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.primary)),
                                    const SizedBox(height: 24),
                                    const Text(
                                      "Votre commande sera envoyée à notre équipe par WhatsApp pour validation. Le paiement se fera après confirmation.",
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const Spacer(),
                            ElevatedButton(
                              onPressed: _isLoading ? null : _sendOrderAndSave,
                              child: _isLoading
                                  ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                                  : const Text('Confirmer et envoyer sur WhatsApp'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}