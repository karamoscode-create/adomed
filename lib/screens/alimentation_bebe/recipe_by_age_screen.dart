// lib/screens/alimentation_bebe/recipe_by_age_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:adomed_app/theme/app_theme.dart';
import 'recipe_detail_screen.dart';
import 'recipe_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'planning_dialog.dart';

class RecipeByAgeScreen extends StatefulWidget {
  const RecipeByAgeScreen({super.key});

  @override
  State<RecipeByAgeScreen> createState() => _RecipeByAgeScreenState();
}

class _RecipeByAgeScreenState extends State<RecipeByAgeScreen> {
  String _selectedAgeGroup = '4-6 mois';
  String _selectedGender = 'Masculin';
  String _selectedTexture = 'Toutes';
  List<String> _selectedRestrictions = [];
  String _searchQuery = '';
  
  final String _currentUserId = FirebaseAuth.instance.currentUser!.uid;
  final TextEditingController _searchController = TextEditingController();

  final List<String> ageGroups = ['4-6 mois', '6-8 mois', '8-12 mois', '12-18 mois', '18+ mois'];
  final List<String> genders = ['Masculin', 'Féminin'];
  final List<String> textures = ['Toutes', 'Purée', 'Morceaux', 'Mixte', 'Liquide'];
  final List<String> restrictions = ['Sans œuf', 'Sans lait', 'Sans gluten', 'Sans arachides', 'Sans sucre ajouté'];

  @override
  void initState() {
    super.initState();
    _loadUserPreferences();
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

  Future<void> _loadUserPreferences() async {
    try {
      DocumentSnapshot userPrefs = await FirebaseFirestore.instance
          .collection('user_preferences')
          .doc(_currentUserId)
          .get();

      if (userPrefs.exists) {
        Map<String, dynamic> data = userPrefs.data() as Map<String, dynamic>;
        setState(() {
          _selectedAgeGroup = data['preferredAgeGroup'] ?? _selectedAgeGroup;
          _selectedGender = data['childGender'] ?? _selectedGender;
          _selectedTexture = data['preferredTexture'] ?? _selectedTexture;
          _selectedRestrictions = List<String>.from(data['dietaryRestrictions'] ?? []);
        });
      }
    } catch (e) {
      debugPrint('Erreur chargement préférences: $e');
    }
  }

  Future<void> _saveUserPreferences() async {
    try {
      await FirebaseFirestore.instance
          .collection('user_preferences')
          .doc(_currentUserId)
          .set({
        'preferredAgeGroup': _selectedAgeGroup,
        'childGender': _selectedGender,
        'preferredTexture': _selectedTexture,
        'dietaryRestrictions': _selectedRestrictions,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Erreur sauvegarde préférences: $e');
    }
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
                      padding: const EdgeInsets.fromLTRB(4, 20, 4, 10),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimaryColor),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          const Expanded(
                            child: Text(
                              'Recettes selon l\'âge',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimaryColor),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.tune, color: AppTheme.textPrimaryColor),
                            onPressed: _showFiltersBottomSheet,
                          ),
                        ],
                      ),
                    ),

                    // Contenu principal
                    Expanded(
                      child: Column(
                        children: [
                          _buildQuickFilters(),
                          _buildSearchBar(),
                          _buildFilterIndicator(),
                          Expanded(child: _buildRecipesList()),
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

  Widget _buildQuickFilters() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: ageGroups.length,
        itemBuilder: (context, index) {
          final ageGroup = ageGroups[index];
          final isSelected = _selectedAgeGroup == ageGroup;
          
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilterChip(
              label: Text(ageGroup),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _selectedAgeGroup = ageGroup);
                  _saveUserPreferences();
                }
              },
              backgroundColor: AppColors.cardColor,
              selectedColor: AppColors.primary,
              checkmarkColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.primaryText,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? Colors.transparent : Colors.grey.shade300,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Rechercher une recette...',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          )
        ),
      ),
    );
  }

  Widget _buildFilterIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              'Filtré: $_selectedAgeGroup • ${_selectedTexture == 'Toutes' ? 'Toutes textures' : _selectedTexture}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (_searchQuery.isNotEmpty)
            Text(
              'Recherche: $_searchQuery',
              style: Theme.of(context).textTheme.bodySmall,
            ),
        ],
      ),
    );
  }

  Widget _buildRecipesList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _getFilteredRecipesStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }
        
        if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        }
        
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState();
        }

        List<Recipe> recipes = snapshot.data!.docs.map((doc) => Recipe.fromFirestore(doc)).toList();

        if (_searchQuery.isNotEmpty) {
          recipes = recipes.where((recipe) {
            final query = _searchQuery.toLowerCase();
            return recipe.title.toLowerCase().contains(query) ||
                   (recipe.description ?? '').toLowerCase().contains(query) ||
                   recipe.ingredients.any((i) => i.toLowerCase().contains(query));
          }).toList();
        }

        if (recipes.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },
          child: GridView.builder(
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
              return _buildRecipeCard(recipe);
            },
          ),
        );
      },
    );
  }

  Stream<QuerySnapshot> _getFilteredRecipesStream() {
    Query query = FirebaseFirestore.instance
        .collection('recipes')
        .where('ageGroup', isEqualTo: _selectedAgeGroup);

    if (_selectedTexture != 'Toutes') {
      query = query.where('texture', isEqualTo: _selectedTexture);
    }

    return query.orderBy('title').snapshots();
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.restaurant, color: AppColors.primary, size: 50),
            ),
            const SizedBox(height: 24),
            Text('Aucune recette trouvée', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Pour: $_selectedAgeGroup • ${_selectedTexture == 'Toutes' ? 'Toutes textures' : _selectedTexture}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: 8),
            Text('Essayez de modifier vos filtres', style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeCard(Recipe recipe) {
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
                            onPressed: () => _addToPlanning(recipe),
                            iconSize: 20,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          FutureBuilder<bool>(
                            future: _isFavorite(recipe.id),
                            builder: (context, snapshot) {
                              final isFavorite = snapshot.data ?? false;
                              return IconButton(
                                icon: Icon(
                                  isFavorite ? Icons.favorite : Icons.favorite_border,
                                  color: isFavorite ? Colors.red : Colors.white,
                                ),
                                onPressed: () => _toggleFavorite(recipe),
                                iconSize: 20,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              );
                            },
                          ),
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

  Future<bool> _isFavorite(String recipeId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('user_favorites')
          .doc(_currentUserId)
          .collection('recipes')
          .where('recipeId', isEqualTo: recipeId)
          .limit(1)
          .get();
      return doc.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<void> _toggleFavorite(Recipe recipe) async {
    try {
      final favoritesRef = FirebaseFirestore.instance
          .collection('user_favorites')
          .doc(_currentUserId)
          .collection('recipes');

      QuerySnapshot existingFavorite = await favoritesRef
          .where('recipeId', isEqualTo: recipe.id)
          .limit(1)
          .get();

      if (existingFavorite.docs.isNotEmpty) {
        await existingFavorite.docs.first.reference.delete();
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Recette supprimée des favoris'), backgroundColor: Colors.orange));
      } else {
        await favoritesRef.add({
          'recipeId': recipe.id,
          'addedAt': FieldValue.serverTimestamp(),
        });
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Recette ajoutée aux favoris'), backgroundColor: Colors.green));
      }
      setState(() {});
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erreur lors de la modification des favoris'), backgroundColor: Colors.red));
    }
  }

  void _addToPlanning(Recipe recipe) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (BuildContext context) {
        return PlanningSelectionDialog(recipe: recipe);
      },
    );
  }

  void _showFiltersBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Filtres avancés', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 20),
                    Text('Genre de l\'enfant:', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Row(
                      children: genders.map((gender) {
                        return Expanded(
                          child: RadioListTile<String>(
                            title: Text(gender),
                            value: gender,
                            groupValue: _selectedGender,
                            onChanged: (value) {
                              setModalState(() => _selectedGender = value!);
                              setState(() => _selectedGender = value!);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    Text('Type de texture:', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedTexture,
                      isExpanded: true,
                      items: textures.map((texture) => DropdownMenuItem<String>(value: texture, child: Text(texture))).toList(),
                      onChanged: (value) {
                        setModalState(() => _selectedTexture = value!);
                        setState(() => _selectedTexture = value!);
                      },
                    ),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setModalState(() {
                                _selectedGender = 'Masculin';
                                _selectedTexture = 'Toutes';
                                _selectedRestrictions.clear();
                              });
                              setState(() {
                                _selectedGender = 'Masculin';
                                _selectedTexture = 'Toutes';
                                _selectedRestrictions.clear();
                              });
                            },
                            child: const Text('Réinitialiser'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              _saveUserPreferences();
                              Navigator.pop(context);
                            },
                            child: const Text('Appliquer'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}