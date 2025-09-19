import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:adomed_app/screens/home/home_screen.dart'; // ✅ Import du vrai HomeScreen
import 'package:adomed_app/screens/home/welcome_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          // ✅ Si l'utilisateur est connecté, on l'envoie vers le vrai HomeScreen
          return const HomeScreen();
        }

        return const WelcomeScreen();
      },
    );
  }
}