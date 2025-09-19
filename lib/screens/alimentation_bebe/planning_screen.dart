// lib/screens/alimentation_bebe/planning_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:adomed_app/theme/app_theme.dart';
import 'package:adomed_app/screens/alimentation_bebe/recipe_by_age_screen.dart';
import 'recipe_detail_screen.dart';
import 'recipe_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PlanningScreen extends StatefulWidget {
  const PlanningScreen({super.key});

  @override
  State<PlanningScreen> createState() => _PlanningScreenState();
}

class _PlanningScreenState extends State<PlanningScreen> {
  final String? _currentUserId = FirebaseAuth.instance.currentUser?.uid;
  final List<String> daysOfWeek = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
  final List<String> mealTimes = ['Petit-déjeuner', 'Déjeuner', 'Goûter', 'Dîner'];

  // NOUVEAU : Variable pour stocker l'âge de l'enfant de l'utilisateur
  String? _userAgeGroup;

  DocumentReference? get _planningDocRef {
    if (_currentUserId == null) return null;
    return FirebaseFirestore.instance.collection('plannings').doc(_currentUserId);
  }

  // NOUVEAU : Logique pour filtrer les repas selon l'âge
  List<String> _getVisibleMealTimes(String? ageGroup) {
    // Par défaut, on affiche tout si l'âge n'est pas connu
    if (ageGroup == null) return mealTimes;

    switch (ageGroup) {
      case '4-6 mois':
        // Règle : 2 repas par jour pour les 4-6 mois
        return ['Déjeuner', 'Dîner'];
      // Pour tous les autres âges, on affiche les 4 repas
      case '6-8 mois':
      case '8-12 mois':
      case '12-18 mois':
      case '18+ mois':
      default:
        return mealTimes;
    }
  }

  @override
  void initState() {
    super.initState();
    // NOUVEAU : On charge l'âge préféré de l'utilisateur au démarrage
    _loadUserAgeGroup();
  }

  // NOUVEAU : Fonction pour charger l'âge préféré
  Future<void> _loadUserAgeGroup() async {
    if (_currentUserId == null) return;
    try {
      DocumentSnapshot userPrefs = await FirebaseFirestore.instance
          .collection('user_preferences')
          .doc(_currentUserId)
          .get();

      if (userPrefs.exists && mounted) {
        Map<String, dynamic> data = userPrefs.data() as Map<String, dynamic>;
        setState(() {
          _userAgeGroup = data['preferredAgeGroup'];
        });
      }
    } catch (e) {
      debugPrint('Erreur lors du chargement des préférences d\'âge: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    if (_currentUserId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Planning')),
        body: const Center(child: Text('Veuillez vous connecter pour voir votre planning.')),
      );
    }
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
          ),
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
                    _buildAppBar(),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            _buildHeader(),
                            _buildPlanningActions(),
                            _buildPlanningTable(),
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
  
  Widget _buildAppBar() {
     return Padding(
      padding: const EdgeInsets.fromLTRB(4, 20, 16, 10),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimaryColor),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const Expanded(
            child: Text(
              'Planning de la semaine',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimaryColor),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: AppTheme.textPrimaryColor),
            onPressed: () => setState(() {
              // NOUVEAU : On recharge aussi les préférences en cas de refresh manuel
              _loadUserAgeGroup();
            }),
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
        boxShadow: [BoxShadow(color: AppColors.shadowColor.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 2))],
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
                child: const Icon(Icons.calendar_today, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Mon planning alimentaire', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text('Planifiez les repas de votre enfant pour la semaine.', style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlanningActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          InkWell(
            onTap: _showGeneratePlanningDialog,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 50,
              decoration: BoxDecoration(color: AppColors.success, borderRadius: BorderRadius.circular(12)),
              child: const Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.auto_awesome, size: 20, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Générer un planning', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            icon: const Icon(Icons.edit_calendar_outlined),
            label: const Text('Ajouter manuellement'),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RecipeByAgeScreen())),
            style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          )
        ],
      ),
    );
  }

  Widget _buildPlanningTable() {
    return StreamBuilder<DocumentSnapshot>(
      stream: _planningDocRef!.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        }

        if (snapshot.hasData && snapshot.data!.exists) {
            final data = snapshot.data!.data() as Map<String, dynamic>;
            final expiryDate = (data['expiresAt'] as Timestamp?)?.toDate();

            if (expiryDate != null && DateTime.now().isAfter(expiryDate)) {
                _planningDocRef!.collection('weekly_planning').get().then((snap) {
                    final batch = FirebaseFirestore.instance.batch();
                    for (var doc in snap.docs) { batch.delete(doc.reference); }
                    batch.commit();
                });
                return _buildEmptyState("Le planning de la semaine passée a été archivé. Générez-en un nouveau !");
            }
        }
        
        return StreamBuilder<QuerySnapshot>(
          stream: _planningDocRef!.collection('weekly_planning').snapshots(),
          builder: (context, weeklySnapshot) {
             if (weeklySnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!weeklySnapshot.hasData || weeklySnapshot.data!.docs.isEmpty) {
              return _buildEmptyState("Aucun planning trouvé. Générez-en un automatiquement pour commencer !");
            }

            final planningDocs = weeklySnapshot.data?.docs ?? [];
            final Map<String, Map<String, dynamic>> weeklyPlanning = {};
            for (var doc in planningDocs) {
              final data = doc.data() as Map<String, dynamic>;
              weeklyPlanning.putIfAbsent(data['day'], () => {})[data['mealTime']] = data['recipeId'];
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: daysOfWeek.length,
              itemBuilder: (context, index) {
                final day = daysOfWeek[index];
                return _buildDayCard(day, weeklyPlanning[day] ?? {});
              },
            );
          },
        );
      },
    );
  }
  
  Widget _buildEmptyState(String message) {
     return Center(child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
      child: Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, color: Colors.grey)),
    ));
  }

  Widget _buildDayCard(String day, Map<String, dynamic> dailyMeals) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(day, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primary)),
            const Divider(),
            // MODIFIÉ : On utilise la liste de repas filtrée par l'âge
            ..._getVisibleMealTimes(_userAgeGroup).map((mealTime) {
              final recipeId = dailyMeals[mealTime];
              return FutureBuilder<DocumentSnapshot>(
                future: recipeId != null ? FirebaseFirestore.instance.collection('recipes').doc(recipeId).get() : null,
                builder: (context, snapshot) {
                  Recipe? recipe;
                  if (snapshot.hasData && snapshot.data!.exists) {
                    recipe = Recipe.fromFirestore(snapshot.data!);
                  }
                  return _buildMealRow(mealTime, recipe);
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildMealRow(String mealTime, Recipe? recipe) {
     return InkWell(
      onTap: recipe != null ? () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecipeDetailScreen(recipe: recipe),
          ),
        );
      } : null,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 2,
              child: Text(mealTime, style: Theme.of(context).textTheme.titleMedium),
            ),
            Expanded(
              flex: 5,
              child: Text(
                recipe?.title ?? 'Aucun repas planifié',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontStyle: recipe == null ? FontStyle.italic : null,
                  color: recipe == null ? AppColors.textSecondary : AppColors.textPrimary,
                ),
              ),
            ),
            if (recipe != null)
              const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.secondaryText),
          ],
        ),
      ),
    );
  }
  
  void _showGeneratePlanningDialog() {
    // MODIFIÉ : On utilise l'âge de l'utilisateur comme valeur par défaut
    String selectedAgeGroup = _userAgeGroup ?? '4-6 mois';
    final List<String> ageGroups = ['4-6 mois', '6-8 mois', '8-12 mois', '12-18 mois', '18+ mois'];
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Générer un planning'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Pour quel groupe d\'âge ?'),
                  const SizedBox(height: 8),
                  DropdownButton<String>(
                    value: selectedAgeGroup,
                    isExpanded: true,
                    items: ageGroups.map((String age) => DropdownMenuItem<String>(value: age, child: Text(age))).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setDialogState(() => selectedAgeGroup = newValue);
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _generatePlanning(selectedAgeGroup);
                  },
                  child: const Text('Générer'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _generatePlanning(String ageGroup) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('⏳ Génération du planning en cours...'), backgroundColor: Colors.blue),
    );
    try {
      final recipesSnapshot = await FirebaseFirestore.instance.collection('recipes').where('ageGroup', isEqualTo: ageGroup).get();

      if (recipesSnapshot.docs.isEmpty) {
        throw Exception('Aucune recette trouvée pour le groupe d\'âge "$ageGroup".');
      }
      
      final List<Recipe> allRecipes = recipesSnapshot.docs.map((doc) => Recipe.fromFirestore(doc)).toList();
      allRecipes.shuffle();

      final planningCollection = _planningDocRef!.collection('weekly_planning');
      final oldPlanning = await planningCollection.get();
      final batch = FirebaseFirestore.instance.batch();
      for (var doc in oldPlanning.docs) { batch.delete(doc.reference); }
      
      int recipeIndex = 0;
      // MODIFIÉ : On utilise la liste de repas filtrée pour générer le planning
      final visibleMeals = _getVisibleMealTimes(ageGroup);
      for (var day in daysOfWeek) {
        for (var mealTime in visibleMeals) {
          if (recipeIndex >= allRecipes.length) recipeIndex = 0;
          final recipe = allRecipes[recipeIndex];
          // On utilise un ID de document déterministe pour éviter les doublons
          batch.set(planningCollection.doc('$day-$mealTime'), {'day': day, 'mealTime': mealTime, 'recipeId': recipe.id});
          recipeIndex++;
        }
      }
      
      final expiryDate = DateTime.now().add(const Duration(days: 7));
      batch.set(_planningDocRef!, {'expiresAt': Timestamp.fromDate(expiryDate)}, SetOptions(merge: true));
      
      await batch.commit();
      
      if(mounted) {
        // NOUVEAU : On met à jour l'âge de l'utilisateur après la génération
        setState(() => _userAgeGroup = ageGroup);
        FirebaseFirestore.instance.collection('user_preferences').doc(_currentUserId).set({'preferredAgeGroup': ageGroup}, SetOptions(merge: true));
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Planning généré avec succès !'), backgroundColor: Colors.green),
        );
      }
      
    } catch (e) {
      debugPrint('Erreur lors de la génération du planning: $e');
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Erreur: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    }
  }
}