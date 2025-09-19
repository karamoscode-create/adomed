// lib/screens/auth/register_screen.dart

import 'package:flutter/material.dart';
import 'package:adomed_app/theme/app_theme.dart';
import 'register_steps/personal_info_screen.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext inContext) { // Renommé en inContext pour éviter la confusion
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
            padding: EdgeInsets.only(top: MediaQuery.of(inContext).padding.top + 20),
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
                            onPressed: () => Navigator.of(inContext).pop(),
                          ),
                          const Expanded(
                            child: Text(
                              'Créer un compte',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimaryColor),
                            ),
                          ),
                          const SizedBox(width: 48),
                        ],
                      ),
                    ),
                    
                    // Contenu principal scrollable
                    Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Rejoignez notre communauté de santé',
                                textAlign: TextAlign.center,
                                style: Theme.of(inContext).textTheme.titleLarge?.copyWith(
                                  color: AppColors.secondaryText,
                                ),
                              ),
                              const SizedBox(height: 40),
                              _buildStepIndicator(activeStep: 1, totalSteps: 4),
                              const SizedBox(height: 40),
                              _buildFeatureItem(
                                context: inContext,
                                icon: Icons.person_outline,
                                title: 'Informations personnelles',
                                subtitle: 'Nom complet, date de naissance',
                              ),
                              const SizedBox(height: 16),
                              _buildFeatureItem(
                                context: inContext,
                                icon: Icons.location_on_outlined,
                                title: 'Localisation',
                                subtitle: 'Pays et ville de résidence',
                                enabled: false,
                              ),
                              const SizedBox(height: 16),
                              _buildFeatureItem(
                                context: inContext,
                                icon: Icons.health_and_safety_outlined,
                                title: 'Informations médicales',
                                subtitle: 'Groupe sanguin, allergies',
                                enabled: false,
                              ),
                              const SizedBox(height: 16),
                              _buildFeatureItem(
                                context: inContext,
                                icon: Icons.lock_outline_rounded,
                                title: 'Sécurité',
                                subtitle: 'Mot de passe et confirmation',
                                enabled: false,
                              ),
                              const SizedBox(height: 60),
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    inContext,
                                    MaterialPageRoute(
                                      builder: (context) => const PersonalInfoScreen(),
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                    gradient: AppColors.primaryGradient,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Center(
                                    child: Text('Commencer l\'inscription', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator({required int activeStep, required int totalSteps}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSteps, (index) {
        bool isActive = index < activeStep;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          height: 10,
          width: 40,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(5),
          ),
        );
      }),
    );
  }

  Widget _buildFeatureItem({
    required BuildContext context,
    required IconData icon, 
    required String title, 
    required String subtitle, 
    bool enabled = true
  }) {
    return Card(
      color: enabled ? AppColors.cardColor : Colors.grey.shade100,
      child: ListTile(
        leading: Icon(
          icon, 
          color: enabled ? AppColors.primary : Colors.grey,
          size: 30,
        ),
        title: Text(
          title, 
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontSize: 16,
            color: enabled ? AppColors.primaryText : Colors.grey,
          )
        ),
        subtitle: Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: enabled ? AppColors.secondaryText : Colors.grey,
          ),
        ),
      ),
    );
  }
}