// lib/screens/splash/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Assure-toi que les chemins d'importation sont corrects pour ton projet
import 'package:adomed_app/screens/onboarding/onboarding_screen.dart';
import 'package:adomed_app/screens/home/home_screen.dart'; 
import 'package:adomed_app/screens/home/welcome_screen.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    // On attend un court instant (le temps d'afficher le logo) avant de naviguer
    Future.delayed(const Duration(seconds: 2), _navigateUser);
  }

  Future<void> _navigateUser() async {
    // Vérification de sécurité pour s'assurer que le widget est toujours affiché
    if (!mounted) return;

    // --- C'est ici que la magie opère ---
    // 1. On vérifie si un utilisateur est déjà connecté via Firebase
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // 2. Si oui, on l'envoie directement à l'écran d'accueil
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      // 3. Sinon, on vérifie s'il a déjà vu l'écran d'onboarding
      final prefs = await SharedPreferences.getInstance();
      final bool hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

      if (hasSeenOnboarding) {
        // S'il l'a déjà vu, on l'envoie à l'écran de bienvenue/connexion
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const WelcomeScreen()),
        );
      } else {
        // Si c'est sa première visite, on lui montre l'onboarding
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // L'UI du splash screen reste simple, juste le logo
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset(
          'assets/images/adomed-logo-home.png',
          width: 150,
        ),
      ),
    );
  }
}