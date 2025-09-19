// lib/screens/suivi_medical/suivi_medical_screen.dart

import 'package:flutter/material.dart';
import 'package:adomed_app/theme/app_theme.dart';
import 'imc_screen.dart';
import 'tension_screen.dart';
import 'glycemie_screen.dart';

class SuiviMedicalScreen extends StatelessWidget {
  const SuiviMedicalScreen({super.key});

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
                    // En-tête personnalisé
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
                              'Suivi Médical',
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

                    // Contenu principal
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.all(16.0),
                        children: [
                          _buildServiceCard(
                            context: context,
                            title: 'Suivi de l\'IMC',
                            subtitle: 'Calculez et suivez votre Indice de Masse Corporelle.',
                            icon: Icons.monitor_weight_outlined,
                            color: AppColors.primary,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const ImcScreen()),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildServiceCard(
                            context: context,
                            title: 'Tension Artérielle',
                            subtitle: 'Enregistrez et consultez l\'historique de votre tension.',
                            icon: Icons.favorite_border,
                            color: Colors.red.shade400,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const TensionScreen()),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildServiceCard(
                            context: context,
                            title: 'Suivi de la Glycémie',
                            subtitle: 'Suivez votre taux de sucre dans le sang.',
                            icon: Icons.bloodtype_outlined,
                            color: Colors.orange.shade400,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const GlycemieScreen()),
                              );
                            },
                          ),
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
    );
  }

  Widget _buildServiceCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          foregroundColor: color,
          child: Icon(icon),
        ),
        title: Text(title, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.secondaryText),
        onTap: onTap,
      ),
    );
  }
}