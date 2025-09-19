// lib/screens/bilans/bilan_tracker_screen.dart

import 'package:flutter/material.dart';
import 'package:adomed_app/theme/app_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BilanTrackerScreen extends StatelessWidget {
  final String bilanId;
  const BilanTrackerScreen({super.key, required this.bilanId});

  @override
  Widget build(BuildContext context) {
    // MODIFICATION : La structure de l'écran est maintenant un Stack
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
                              'Suivi de votre bilan',
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

                    // Le contenu principal est dans un Expanded pour être scrollable
                    Expanded(
                      child: StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance.collection('bilans').doc(bilanId).snapshots(),
                        builder: (_, snap) {
                          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                          final data = snap.data!.data() as Map<String, dynamic>;
                          final status = data['status'] ?? 'en_attente';
                          
                          return ListView(
                            padding: const EdgeInsets.all(24),
                            children: [
                              Text(data['type'] ?? 'Votre commande', style: Theme.of(context).textTheme.headlineSmall),
                              const SizedBox(height: 8),
                              Text('ID: $bilanId', style: Theme.of(context).textTheme.bodySmall),
                              const SizedBox(height: 40),

                              _buildStatusStep(context, 'Commande reçue', 'en_attente', status, icon: Icons.receipt_long_outlined),
                              _buildConnector(),
                              _buildStatusStep(context, 'Validée par le laboratoire', 'validé', status, icon: Icons.check_circle_outline),
                              _buildConnector(),
                              _buildStatusStep(context, 'Prélèvement en cours', 'en cours', status, icon: Icons.local_shipping_outlined),
                              _buildConnector(),
                              _buildStatusStep(context, 'Résultats disponibles', 'terminé', status, icon: Icons.description_outlined),
                            ],
                          );
                        },
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

  Widget _buildStatusStep(BuildContext context, String title, String stepStatus, String currentStatus, {required IconData icon}) {
    final statusOrder = ['en_attente', 'validé', 'en cours', 'terminé'];
    final currentIndex = statusOrder.indexOf(currentStatus);
    final stepIndex = statusOrder.indexOf(stepStatus);

    final bool isActive = stepIndex <= currentIndex;
    final color = isActive ? AppColors.primary : Colors.grey.shade400;
    final textColor = isActive ? AppColors.primaryText : Colors.grey;

    return Row(
      children: [
        CircleAvatar(
          backgroundColor: color,
          child: Icon(icon, color: Colors.white),
        ),
        const SizedBox(width: 16),
        Text(title, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: textColor, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }

  Widget _buildConnector() {
    return Container(
      height: 30,
      margin: const EdgeInsets.only(left: 20),
      width: 2,
      color: Colors.grey.shade300,
    );
  }
}