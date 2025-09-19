import 'package:flutter/material.dart';
// Importer AppTheme pour accéder aux couleurs

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Remplacement de GradientScaffold par un Scaffold standard avec un fond blanc
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              // Logo Adomed centré
              Image.asset(
                'assets/images/adomed-logo-home.png',
                width: 180,
                height: 180,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 60),

              // Bouton Connexion utilisant le style du thème
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/login'),
                // Aucun style n'est nécessaire ici, il prendra celui de ElevatedButtonThemeData
                child: const Text('Se connecter'),
              ),
              const SizedBox(height: 16),

              // Bouton Inscription adapté pour un fond blanc
              OutlinedButton(
                onPressed: () => Navigator.pushNamed(context, '/register'),
                // Le style par défaut d'un OutlinedButton utilise la couleur primaire du thème
                child: const Text('Créer un compte'),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}