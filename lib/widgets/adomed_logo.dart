import 'package:flutter/material.dart';

class AdomedLogo extends StatelessWidget {
  const AdomedLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Placeholder pour le logo - Vous pouvez remplacer par votre image
        Container(
          height: 80,
          width: 80,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.medical_services_outlined,
            size: 40,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'ADOMED',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Votre santé en un clic',
          style: TextStyle(fontSize: 16, color: Colors.white70),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}
