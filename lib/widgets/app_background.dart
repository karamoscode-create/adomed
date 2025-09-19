import 'package:flutter/material.dart';
import 'package:adomed_app/theme/app_theme.dart';

class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, -1.2), // Place le centre du dégradé en haut de l'écran
          radius: 1.0, // La taille du dégradé
          colors: [
            AppTheme.primaryLightColor, // La couleur "fumée"
            AppTheme.backgroundColor,   // La couleur de fond normale
          ],
          stops: [0.0, 0.8], // Contrôle la rapidité de la transition
        ),
      ),
      child: child, // Affiche le contenu de votre écran par-dessus le fond
    );
  }
}