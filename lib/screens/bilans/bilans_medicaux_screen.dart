// lib/screens/bilans/bilans_medicaux_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:adomed_app/theme/app_theme.dart';
import 'packs_analyse_screen.dart';
import 'liste_analyse_screen.dart';
import 'bilans_prescrits_screen.dart';
import 'bilans_en_cours_screen.dart';
import 'package:iconsax/iconsax.dart';

class BilansMedicauxScreen extends StatefulWidget {
  const BilansMedicauxScreen({super.key});

  @override
  State<BilansMedicauxScreen> createState() => _BilansMedicauxScreenState();
}

class _BilansMedicauxScreenState extends State<BilansMedicauxScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showBilanOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Commander un bilan', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            _optionTile(context, Iconsax.box, 'Packs d\'analyse', () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const PacksAnalyseScreen()));
            }),
            const Divider(),
            _optionTile(context, Iconsax.document_text_1, 'Analyse à la demande', () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ListeAnalyseScreen()));
            }),
             const Divider(),
            _optionTile(context, Iconsax.scan, 'Bilan prescrit', () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const BilansPrescritsScreen()));
            }),
          ],
        ),
      ),
    );
  }

  Widget _optionTile(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(label, style: Theme.of(context).textTheme.bodyLarge),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // COUCHE 1 : Le fond en dégradé
          Container(
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
          ),

          // COUCHE 2 : Le bloc de contenu "vitré"
          Padding(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 20),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(32),
                topRight: Radius.circular(32),
              ),
              child: Container(
                color: AppTheme.backgroundColor.withOpacity(0.95),
                child: Column(
                  children: [
                    // En-tête personnalisé remplaçant l'AppBar
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
                              'Bilans médicaux',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimaryColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 48), // Espace pour centrer le titre
                        ],
                      ),
                    ),

                    // Les onglets, maintenant intégrés au bloc principal
                    TabBar(
                      controller: _tabController,
                      labelColor: AppTheme.primaryColor,
                      unselectedLabelColor: AppTheme.textSecondaryColor,
                      indicatorColor: AppTheme.primaryColor,
                      indicatorWeight: 3.0,
                      tabs: const [Tab(text: 'En cours'), Tab(text: 'Terminés')],
                    ),

                    // Le contenu des onglets prend le reste de la place
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          BilansEnCoursScreen(uid: uid),
                          _buildTermines(uid),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showBilanOptions(context),
        label: const Text('Nouveau bilan', style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.add, color: Colors.white),
        // On applique le dégradé au bouton flottant
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ).addGradient(AppColors.primaryGradient), // Helper pour le dégradé
    );
  }

  Widget _buildTermines(String? uid) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('bilans')
          .where('uid', isEqualTo: uid)
          .where('status', isEqualTo: 'terminé')
          .snapshots(),
      builder: (_, snap) {
        if (snap.hasError) return Center(child: Text('Erreur : ${snap.error}'));
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snap.data!.docs;
        if (docs.isEmpty) {
          return const Center(child: Text('Aucun bilan terminé'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (_, i) => _bilanCard(docs[i]),
        );
      },
    );
  }

  Widget _bilanCard(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.green,
          child: Icon(Icons.check_circle_outline, color: Colors.white),
        ),
        title: Text(data['type'] ?? 'Bilan', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
        subtitle: Text('${data['totalPrice']} FCFA', style: Theme.of(context).textTheme.bodyMedium),
        trailing: Text('Terminé', style: TextStyle(color: Colors.green.shade700)),
      ),
    );
  }
}

// Petite extension pour facilement ajouter un dégradé au FloatingActionButton
extension GradientWidget on Widget {
  Widget addGradient(Gradient gradient) {
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(15)), // Assurez-vous que cela correspond au shape du FAB
      child: Container(
        decoration: BoxDecoration(gradient: gradient),
        child: this,
      ),
    );
  }
}