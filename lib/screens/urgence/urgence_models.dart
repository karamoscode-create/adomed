// lib/screens/urgence/urgence_models.dart
import 'package:flutter/material.dart';

class UrgenceCategory {
  final String name;
  final IconData icon;
  final String? imageUrl; // Rendu facultatif
  final String? description; // Rendu facultatif

  const UrgenceCategory({
    required this.name,
    required this.icon,
    this.imageUrl,
    this.description,
  });
}