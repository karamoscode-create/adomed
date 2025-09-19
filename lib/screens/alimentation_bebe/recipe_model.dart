// lib/alimentation/recipe_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class Recipe {
  final String id;
  final String title;
  final String ageGroup;
  final String imageUrl;
  final List<String> ingredients;
  final List<String> materials;
  final List<String> instructions;
  final DateTime? createdAt;
  final String? description;
  final int prepTime;
  final int cookTime;
  final String texture;
  final String difficulty;
  final List<String> allergens;
  final Map<String, dynamic> nutrition;

  const Recipe({
    required this.id,
    required this.title,
    required this.ageGroup,
    required this.imageUrl,
    required this.ingredients,
    required this.materials,
    required this.instructions,
    this.createdAt,
    this.description,
    this.prepTime = 0,
    this.cookTime = 0,
    required this.texture,
    required this.difficulty,
    required this.allergens,
    required this.nutrition,
  });

  factory Recipe.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return Recipe(
      id: doc.id,
      title: data['title'] ?? '',
      ageGroup: data['ageGroup'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      ingredients: List<String>.from(data['ingredients'] ?? []),
      materials: List<String>.from(data['materials'] ?? []),
      instructions: List<String>.from(data['instructions'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      description: data['description'] ?? '',
      prepTime: data['prepTime'] ?? 0,
      cookTime: data['cookTime'] ?? 0,
      texture: data['texture'] ?? '',
      difficulty: data['difficulty'] ?? '',
      allergens: List<String>.from(data['allergens'] ?? []),
      nutrition: Map<String, dynamic>.from(data['nutrition'] ?? {}),
    );
  }

  Recipe copyWith({
    String? id,
    String? title,
    String? ageGroup,
    String? imageUrl,
    List<String>? ingredients,
    List<String>? materials,
    List<String>? instructions,
    DateTime? createdAt,
    String? description,
    int? prepTime,
    int? cookTime,
    String? texture,
    String? difficulty,
    List<String>? allergens,
    Map<String, dynamic>? nutrition,
  }) {
    return Recipe(
      id: id ?? this.id,
      title: title ?? this.title,
      ageGroup: ageGroup ?? this.ageGroup,
      imageUrl: imageUrl ?? this.imageUrl,
      ingredients: ingredients ?? this.ingredients,
      materials: materials ?? this.materials,
      instructions: instructions ?? this.instructions,
      createdAt: createdAt ?? this.createdAt,
      description: description ?? this.description,
      prepTime: prepTime ?? this.prepTime,
      cookTime: cookTime ?? this.cookTime,
      texture: texture ?? this.texture,
      difficulty: difficulty ?? this.difficulty,
      allergens: allergens ?? this.allergens,
      nutrition: nutrition ?? this.nutrition,
    );
  }
}

extension RecipeExtension on List<Recipe> {
  List<Recipe> getByAgeGroup(String ageGroup) {
    return where((recipe) => recipe.ageGroup == ageGroup).toList();
  }

  List<Recipe> search(String query) {
    return where((recipe) => 
      recipe.title.toLowerCase().contains(query.toLowerCase()) || 
      (recipe.description ?? '').toLowerCase().contains(query.toLowerCase()) || 
      recipe.ingredients.any((ingredient) => ingredient.toLowerCase().contains(query.toLowerCase()))
    ).toList();
  }
}