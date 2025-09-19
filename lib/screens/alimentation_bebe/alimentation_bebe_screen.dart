// lib/screens/alimentation_bebe/alimentation_bebe_screen.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:adomed_app/theme/app_theme.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

import 'planning_screen.dart';
import 'favorites_screen.dart';
import 'nutrition_articles_screen.dart';
import 'recipe_by_age_screen.dart';
import 'recipe_by_ingredient_screen.dart';
import 'recipe_detail_screen.dart';
import 'recipe_model.dart';
import 'ai_chat_widget.dart';

class AlimentationBebeScreen extends StatefulWidget {
  const AlimentationBebeScreen({super.key});

  @override
  State<AlimentationBebeScreen> createState() => _AlimentationBebeScreenState();
}

class _AlimentationBebeScreenState extends State<AlimentationBebeScreen> {
  late Future<Recipe?> _dailyRecipeFuture;

  @override
  void initState() {
    super.initState();
    // MODIFICATION : On appelle la nouvelle fonction pour la recette du jour
    _dailyRecipeFuture = _fetchDailyRecipe();
  }

  // MODIFICATION : Nouvelle logique pour une recette du jour déterministe
  Future<Recipe?> _fetchDailyRecipe() async {
    try {
      final recipesCollection = FirebaseFirestore.instance.collection('recipes');
      final recipesSnapshot = await recipesCollection.get();
      if (recipesSnapshot.docs.isEmpty) return null;

      final List<Recipe> allRecipes = recipesSnapshot.docs.map((doc) => Recipe.fromFirestore(doc)).toList();
      
      // On trie la liste pour s'assurer que l'ordre est toujours le même
      allRecipes.sort((a, b) => a.id.compareTo(b.id));
      
      // On utilise la date du jour pour choisir un index de manière prévisible
      final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
      final recipeIndex = dayOfYear % allRecipes.length;
      
      return allRecipes[recipeIndex];
    } catch (e) {
      debugPrint('Erreur lors du chargement de la recette du jour: $e');
      return null;
    }
  }

  void _openEmmaChat() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final discussionsRef = FirebaseFirestore.instance.collection('users').doc(userId).collection('emma_discussions');
    final discussionsSnapshot = await discussionsRef.get();
    String conversationId;

    if (discussionsSnapshot.docs.isEmpty) {
      final newDoc = discussionsRef.doc(const Uuid().v4());
      await newDoc.set({'title': 'Discussion avec Emma', 'last_updated': Timestamp.now(), 'type': 'emma'});
      conversationId = newDoc.id;
    } else {
      conversationId = discussionsSnapshot.docs.first.id;
    }

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AiChatWidget(conversationId: conversationId, onClose: () => Navigator.of(context).pop()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openEmmaChat,
        backgroundColor: AppColors.primary,
        icon: const CircleAvatar(
          radius: 14,
          backgroundColor: Colors.white,
          backgroundImage: AssetImage('assets/images/emma.png'),
        ),
        label: const Text("Discuter avec Emma", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
          ),
          Padding(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 20),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
              child: Container(
                color: AppTheme.backgroundColor.withOpacity(0.95),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(4, 20, 16, 10),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimaryColor),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          const Expanded(
                            child: Text(
                              'Alimentation bébé',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimaryColor),
                            ),
                          ),
                          const SizedBox(width: 48),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeader(),
                            const SizedBox(height: 24),
                            _buildDailyRecipeCard(), // MODIFICATION : Le widget est renommé
                            const SizedBox(height: 24),
                            _buildMainMenuCards(),
                          ],
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

  Widget _buildHeader() {
    // ... (Ce widget ne change pas)
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Votre boutchou a déjà 4 voir 6 mois. C\'est l\'heure de la diversification. Découvrez des recettes types pour enfant de race noire Africain.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Votre assistant menu personnalisé. Programmez les repas de la semaine en 2 clics.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
  
  // MODIFICATION : Renommé en "DailyRecipeCard"
  Widget _buildDailyRecipeCard() {
    return FutureBuilder<Recipe?>(
      future: _dailyRecipeFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          return const Text('Impossible de charger la recette du jour.');
        }
        final dailyRecipe = snapshot.data!;
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // MODIFICATION : Le titre est changé
              const Text(
                'Recette du jour',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                dailyRecipe.title,
                style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => RecipeDetailScreen(recipe: dailyRecipe))),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.primary),
                  child: const Text('Découvrir'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMainMenuCards() {
    // ... (Ce widget ne change pas)
    final menuItems = [
      {'title': 'Mon planning de la semaine', 'icon': Iconsax.calendar_1, 'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PlanningScreen()))},
      {'title': 'Recette selon l\'âge', 'icon': Iconsax.ruler, 'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RecipeByAgeScreen()))},
      {'title': 'Recette selon l\'aliment', 'icon': Iconsax.courthouse, 'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RecipeByIngredientScreen()))},
      {'title': 'Mes favoris', 'icon': Iconsax.heart, 'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FavoritesScreen()))},
      {'title': 'Conseils alimentaires', 'icon': Iconsax.book_1, 'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NutritionArticlesScreen()))},
    ];
    return Column(
      children: menuItems.map((item) => _buildMenuCard(
        title: item['title'] as String,
        icon: item['icon'] as IconData,
        onTap: item['onTap'] as VoidCallback,
      )).toList(),
    );
  }

  Widget _buildMenuCard({required String title, required IconData icon, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          onTap: onTap,
          leading: Icon(icon, color: AppColors.primary),
          title: Text(title, style: Theme.of(context).textTheme.titleMedium),
          trailing: const Icon(Iconsax.arrow_right_3, size: 16),
        ),
      ),
    );
  }
}