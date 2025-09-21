// lib/screens/alimentation_bebe/recipe_by_ingredient_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:adomed_app/theme/app_theme.dart';
import 'recipe_detail_screen.dart';
import 'recipe_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'planning_dialog.dart';
import '../../data/recipe_seeder.dart'; // IMPORT AJOUTÉ

const Map<String, List<String>> ingredientsData = {
  'Légumes': [ 'Brocoli', 'Carotte', 'Concombre', 'Courge', 'Courgette', 'Epinard', 'Gombo', 'Haricots verts', 'Navet', 'Oignon', 'Petits pois', 'Salade', 'Tomate' ],
  'Fruits': [ 'Ananas', 'Avocat', 'Banane', 'Baobab', 'Cacao', 'Citron', 'Clémentine', 'Mangue', 'Muscade', 'Néré', 'Noix de Coco', 'Orange', 'Papaye', 'Poire', 'Pomme', 'Tamarin noir (chat noir)' ],
  'Féculents': [ 'Blé', 'Echalotte', 'Flocons d’avoine', 'Haricots', 'Igname', 'Lentilles', 'Maïs', 'Manioc', 'Mil', 'Patate douce', 'Pomme de terre', 'Riz', 'Soja', 'Sorgho', 'Souchet', 'Tapioca' ],
  'Viandes': ['Agneau', 'Jambon', 'Poulet', 'Viande hachée'],
  'Poissons': ['Poisson', 'Maquereau fumé', 'Sardine'],
  'Laitages & Oeufs': ['Lait', 'Fromage blanc', 'Œuf'],
  'Herbes & Épices': ['Aneth', 'Basilic', 'Cannelle', 'Cardamome', 'Ciboulette', 'Coriandre', 'Curcuma', 'Gingembre', 'Menthe', 'Persil', 'Poivre', 'Vanille'],
};

class RecipeByIngredientScreen extends StatefulWidget {
  const RecipeByIngredientScreen({super.key});

  @override
  State<RecipeByIngredientScreen> createState() => _RecipeByIngredientScreenState();
}

class _RecipeByIngredientScreenState extends State<RecipeByIngredientScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // COUCHE 1 : Le fond en dégradé
          Container(
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
          ),

          // COUCHE 2 : Le bloc de contenu "vitré"
          Padding(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 20),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(32),
                topRight: Radius.circular(32),
              ),
              child: Container(
                color: AppTheme.backgroundColor.withOpacity(0.95),
                child: Column(
                  children: [
                    // En-tête personnalisé
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
                              'Recettes par ingrédient',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimaryColor),
                            ),
                          ),
                          // BOUTON TEMPORAIRE AJOUTÉ - À RETIRER APRÈS UTILISATION
                          IconButton(
                            icon: const Icon(Icons.sync, color: Colors.blue),
                            tooltip: 'Mettre à jour les recettes',
                            onPressed: () => completeReset(context),
                          ),
                          // FIN DU BOUTON TEMPORAIRE
                        ],
                      ),
                    ),

                    // Contenu principal
                    Expanded(
                      child: Column(
                        children: [
                          _buildHeader(),
                          _buildSearchBar(),
                          Expanded(
                            child: _buildIngredientsList(),
                          ),
                        ],
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
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [ BoxShadow( color: AppColors.shadowColor.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 2)) ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.eco, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Explorez par ingrédient', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text('Découvrez des recettes créatives', style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Trouvez des idées selon les ingrédients phare (ex: plantain, fonio), la saisonnalité et les préférences de votre tout petit.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Rechercher un ingrédient...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                  },
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildIngredientsList() {
    final filteredCategories = ingredientsData.entries.where((entry) {
      final ingredients = entry.value;
      return ingredients.any((ingredient) => 
        ingredient.toLowerCase().contains(_searchQuery.toLowerCase()));
    }).toList();

    if (filteredCategories.isEmpty && _searchQuery.isNotEmpty) {
      return const Center(child: Text('Aucun ingrédient ne correspond à votre recherche.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: filteredCategories.length,
      itemBuilder: (context, index) {
        final category = filteredCategories[index].key;
        final ingredients = filteredCategories[index].value.where((ingredient) => 
          ingredient.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          clipBehavior: Clip.antiAlias,
          child: ExpansionTile(
            title: Text(category, style: Theme.of(context).textTheme.titleMedium),
            children: ingredients.map((ingredient) {
              return ListTile(
                title: Text(ingredient),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.secondaryText),
                onTap: () => _navigateToRecipesByIngredient(ingredient),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _navigateToRecipesByIngredient(String ingredientName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipesByIngredientResultScreen(ingredientName: ingredientName),
      ),
    );
  }
}

// =========================================================================
// Écran pour afficher les recettes une fois un ingrédient sélectionné.
// =========================================================================
class RecipesByIngredientResultScreen extends StatelessWidget {
  final String ingredientName;
  const RecipesByIngredientResultScreen({super.key, required this.ingredientName});
  
  String get _currentUserId => FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // COUCHE 1 : Le fond en dégradé
          Container(
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
          ),

          // COUCHE 2 : Le bloc de contenu "vitré"
          Padding(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 20),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(32),
                topRight: Radius.circular(32),
              ),
              child: Container(
                color: AppTheme.backgroundColor.withOpacity(0.95),
                child: Column(
                  children: [
                    // En-tête personnalisé
                    Padding(
                      padding: const EdgeInsets.fromLTRB(4, 20, 16, 10),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimaryColor),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          Expanded(
                            child: Text(
                              'Recettes avec : $ingredientName',
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimaryColor),
                            ),
                          ),
                          const SizedBox(width: 48),
                        ],
                      ),
                    ),

                    // Contenu principal
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('recipes')
                            .where('ingredients', arrayContains: ingredientName)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                          }
                          if (snapshot.hasError) {
                            return Center(child: Text('Erreur: ${snapshot.error}'));
                          }
                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.search_off, size: 80, color: AppColors.secondaryText),
                                    const SizedBox(height: 16),
                                    Text('Aucune recette trouvée', style: Theme.of(context).textTheme.titleLarge),
                                    const SizedBox(height: 8),
                                    Text('Aucune recette ne contient actuellement l\'ingrédient "$ingredientName".', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
                                  ],
                                ),
                              ),
                            );
                          }
                          final recipes = snapshot.data!.docs.map((doc) => Recipe.fromFirestore(doc)).toList();

                          return GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              childAspectRatio: 0.75,
                            ),
                            itemCount: recipes.length,
                            itemBuilder: (context, index) {
                              final recipe = recipes[index];
                              return _buildRecipeCard(context, recipe);
                            },
                          );
                        },
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

  Widget _buildRecipeCard(BuildContext context, Recipe recipe) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RecipeDetailScreen(recipe: recipe),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: recipe.id,
                    child: (recipe.imageUrl.startsWith('http') || recipe.imageUrl.startsWith('https'))
                        ? CachedNetworkImage(
                            imageUrl: recipe.imageUrl,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) => Image.asset('assets/images/services/placeholder.png', fit: BoxFit.cover),
                            placeholder: (context, url) => Container(color: Colors.grey.shade200),
                          )
                        : Image.asset(
                            recipe.imageUrl,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: Colors.grey.shade200,
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.image_not_supported, color: Colors.grey, size: 40),
                                  SizedBox(height: 8),
                                  Text('Image non trouvée', style: TextStyle(color: Colors.grey, fontSize: 12)),
                                ],
                              ),
                            ),
                          ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.add_circle, color: Colors.green),
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                builder: (BuildContext context) {
                                  return PlanningSelectionDialog(recipe: recipe);
                                },
                              );
                            },
                            iconSize: 20,
                          ),
                          _buildFavoriteButton(context, recipe),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        recipe.ageGroup,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (recipe.description != null && recipe.description!.isNotEmpty)
                    Text(
                      recipe.description!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 4),
                  Text(
                    '${recipe.prepTime} min • ${recipe.difficulty}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.primary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoriteButton(BuildContext context, Recipe recipe) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('user_favorites')
          .doc(_currentUserId)
          .collection('recipes')
          .where('recipeId', isEqualTo: recipe.id)
          .limit(1)
          .snapshots(),
      builder: (context, snapshot) {
        final isFavorite = snapshot.hasData && snapshot.data!.docs.isNotEmpty;
        return IconButton(
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite ? Colors.red : Colors.white,
          ),
          onPressed: () async {
            final favoritesRef = FirebaseFirestore.instance
                .collection('user_favorites')
                .doc(_currentUserId)
                .collection('recipes');

            if (isFavorite) {
              await favoritesRef.doc(snapshot.data!.docs.first.id).delete();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Recette supprimée des favoris'), backgroundColor: Colors.orange),
              );
            } else {
              await favoritesRef.add({
                'recipeId': recipe.id,
                'addedAt': FieldValue.serverTimestamp(),
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Recette ajoutée aux favoris'), backgroundColor: Colors.green),
              );
            }
          },
          iconSize: 20,
        );
      },
    );
  }
}