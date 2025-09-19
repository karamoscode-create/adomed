// lib/screens/animated_splash_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:adomed_app/auth_wrapper.dart'; // Redirige vers AuthWrapper

class AnimatedSplashScreen extends StatefulWidget {
  const AnimatedSplashScreen({super.key});

  @override
  State<AnimatedSplashScreen> createState() => _AnimatedSplashScreenState();
}

class _AnimatedSplashScreenState extends State<AnimatedSplashScreen> {
  @override
  void initState() {
    super.initState();
    // Déclenche la navigation après 3 secondes
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        // On utilise pushReplacement pour que l'utilisateur ne puisse pas revenir en arrière
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const AuthWrapper()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Gestion d'erreur pour l'image
            Image.asset(
              'assets/lottie/animation_adomed.gif', 
              width: 250,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  'assets/images/adomed-logo.png',
                  width: 250,
                );
              },
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text(
              'Chargement...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}



