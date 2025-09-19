import 'package:flutter/material.dart';

class GradientScaffold extends StatelessWidget {
  final String title;
  final Widget body;

  const GradientScaffold({
    super.key,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    // Ce widget utilise un Scaffold standard, ce qui garantit que la flèche
    // de retour s'affichera automatiquement quand c'est nécessaire.
    return Scaffold(
      extendBodyBehindAppBar: true, // Permet au dégradé de passer derrière l'AppBar
      appBar: AppBar(
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent, // Rend l'AppBar transparente
        elevation: 0, // Supprime l'ombre
        // Le thème de l'icône de retour sera automatiquement blanc
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        // Le dégradé est appliqué sur toute la page
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E9BBA), Color(0xFF1565C0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        // Le contenu de la page est placé dans une zone de sécurité
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: body,
          ),
        ),
      ),
    );
  }
}