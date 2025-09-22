// lib/data/recipe_seeder.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// Fonction pour supprimer TOUTES les recettes
Future<void> deleteAllRecipes() async {
  try {
    final collectionRef = FirebaseFirestore.instance.collection('recipes');
    final snapshot = await collectionRef.get();
    
    if (snapshot.docs.isNotEmpty) {
      final batch = FirebaseFirestore.instance.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      print('✅ Toutes les recettes supprimées avec succès');
    }
  } catch (e) {
    print('❌ Erreur lors de la suppression: $e');
    rethrow;
  }
}

// Fonction de reset COMPLET
Future<void> completeReset(BuildContext context) async {
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  
  try {
    scaffoldMessenger.showSnackBar(
      const SnackBar(
        content: Text('🔄 Réinitialisation complète en cours...'),
        backgroundColor: Colors.orange,
      ),
    );

    // 1. Suppression de TOUTES les recettes
    await deleteAllRecipes();
    
    // 2. Pause pour laisser Firebase terminer
    await Future.delayed(const Duration(seconds: 2));

    // 3. Ajout de TOUTES les nouvelles recettes
    await addInitialRecipes(context);

    scaffoldMessenger.showSnackBar(
      const SnackBar(
        content: Text('✅ Reset complet réussi ! Toutes les recettes sont à jour.'),
        backgroundColor: Colors.green,
      ),
    );

  } catch (e) {
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text('❌ Erreur: $e'), 
        backgroundColor: Colors.red
      ),
    );
    print('Erreur détaillée: $e');
  }
}

// Fonction de débogage pour vérifier les recettes
Future<void> debugRecipes(BuildContext context) async {
  try {
    final recipes = await FirebaseFirestore.instance.collection('recipes').get();
    
    if (recipes.docs.isEmpty) {
      print('⚠️ Aucune recette trouvée dans Firestore');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aucune recette trouvée - Ajoutez des recettes d\'abord'),
          backgroundColor: Colors.orange
        ),
      );
      return;
    }
    
    print('=== 📋 RECETTES DISPONIBLES ===');
    recipes.docs.forEach((doc) {
      print('• ${doc['title']}');
      print('  Age: ${doc['ageGroup']}');
      print('  Texture: ${doc['texture']}');
      print('  Difficulté: ${doc['difficulty']}');
      print('  Temps: ${doc['prepTime']}min');
      print('---');
    });
    print('Total: ${recipes.docs.length} recettes');
    
    // Afficher les groupes d'âge disponibles
    final ageGroups = recipes.docs.map((doc) => doc['ageGroup']).toSet();
    print('Groupes d\'âge disponibles: $ageGroups');
    
  } catch (e) {
    print('❌ Erreur de débogage: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Erreur de débogage: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

Future<void> addInitialRecipes(BuildContext context) async {
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  try {
    final recipes = [
      // Recettes existantes
      {
        'title': 'Purée de carotte et pomme de terre',
        'ageGroup': '4-6 mois',
        'imageUrl': 'assets/images/puree_carotte_pdterre.png',
        'ingredients': ['Carotte', 'Pomme de terre', 'Eau'],
        'materials': ['Casserole', 'Mixeur'],
        'instructions': [
          'Épluchez et coupez les carottes et pommes de terre en morceaux.',
          'Faites-les cuire à la vapeur jusqu\'à ce qu\'ils soient tendres.',
          'Mixez avec un peu d\'eau de cuisson pour obtenir une purée lisse.',
        ],
        'description': 'Une purée simple et nutritive pour les premières étapes de diversification.',
        'prepTime': 10,
        'cookTime': 20,
        'texture': 'Purée',
        'difficulty': 'Facile',
        'allergens': [],
        'nutrition': {
          'calories': 80, 'carbs': 18, 'protein': 2, 'fat': 0.5
        }
      },
      {
        'title': 'Purée de courgette',
        'ageGroup': '4-6 mois',
        'imageUrl': 'assets/images/puree_courgette.png',
        'ingredients': ['Courgette', 'Eau', 'Lait'],
        'materials': ['Casserole', 'Mixeur'],
        'instructions': [
          'Lavez et coupez la courgette en morceaux. Faites-la cuire à la vapeur.',
          'Mixez avec le lait et de l\'eau de cuisson pour obtenir une purée onctueuse.',
        ],
        'description': 'Une purée de courgette douce et crémeuse, parfaite pour les débutants.',
        'prepTime': 5,
        'cookTime': 15,
        'texture': 'Purée',
        'difficulty': 'Facile',
        'allergens': ['Lait'],
        'nutrition': {
          'calories': 60, 'carbs': 8, 'protein': 2, 'fat': 2
        }
      },
      {
        'title': 'Compote de banane et pomme',
        'ageGroup': '4-6 mois',
        'imageUrl': 'assets/images/compote_banane_pomme.png',
        'ingredients': ['Banane', 'Pomme', 'Cannelle'],
        'materials': ['Casserole', 'Mixeur'],
        'instructions': [
          'Épluchez et coupez la pomme en morceaux. Faites-la cuire à la vapeur.',
          'Ajoutez la banane coupée en morceaux et mixez le tout.',
          'Saupoudrez d\'une pincée de cannelle pour plus de saveur.',
        ],
        'description': 'Une délicieuse compote de fruits, idéale pour les goûters.',
        'prepTime': 10,
        'cookTime': 10,
        'texture': 'Purée',
        'difficulty': 'Facile',
        'allergens': [],
        'nutrition': {
          'calories': 120, 'carbs': 30, 'protein': 1, 'fat': 0.5
        }
      },
      {
        'title': 'Purée de poulet et patate douce',
        'ageGroup': '6-8 mois',
        'imageUrl': 'assets/images/puree_poulet_patate_douce.png',
        'ingredients': ['Poulet', 'Patate douce', 'Haricots verts'],
        'materials': ['Casserole', 'Mixeur'],
        'instructions': [
          'Cuisez le poulet et la patate douce à la vapeur.',
          'Ajoutez les haricots verts cuits et mixez le tout.',
          'Assaisonnez avec une pincée de poivre.',
        ],
        'description': 'Une purée complète pour introduire les protéines.',
        'prepTime': 15,
        'cookTime': 25,
        'texture': 'Mixte',
        'difficulty': 'Moyen',
        'allergens': [],
        'nutrition': {
          'calories': 150, 'carbs': 15, 'protein': 10, 'fat': 5
        }
      },
      {
        'title': 'Ragoût de viande hachée',
        'ageGroup': '8-12 mois',
        'imageUrl': 'assets/images/ragout_viande_hachee.png',
        'ingredients': ['Viande hachée', 'Carotte', 'Pomme de terre', 'Oignon'],
        'materials': ['Casserole', 'Fourchette'],
        'instructions': [
          'Faites revenir la viande hachée avec l\'oignon.',
          'Ajoutez les légumes coupés en petits morceaux et de l\'eau. Laissez mijoter.',
          'Écrasez légèrement à la fourchette pour obtenir des morceaux tendres.',
        ],
        'description': 'Un plat savoureux avec des petits morceaux pour habituer l\'enfant.',
        'prepTime': 15,
        'cookTime': 30,
        'texture': 'Morceaux',
        'difficulty': 'Moyen',
        'allergens': [],
        'nutrition': {
          'calories': 180, 'carbs': 10, 'protein': 15, 'fat': 8
        }
      },
      {
        'title': 'Purée de Maïs',
        'ageGroup': '4-6 mois',
        'imageUrl': 'assets/images/puree_mais.png',
        'ingredients': ['Maïs', 'Lait', 'Eau'],
        'materials': ['Casserole', 'Mixeur'],
        'instructions': [
          'Faites bouillir les grains de maïs puis mixez avec le lait.',
          'Passez au tamis pour éliminer les peaux et obtenir une purée très lisse.',
        ],
        'description': 'Une purée de maïs onctueuse, riche en saveurs douces.',
        'prepTime': 5,
        'cookTime': 15,
        'texture': 'Purée',
        'difficulty': 'Facile',
        'allergens': ['Lait'],
        'nutrition': {
          'calories': 95, 'carbs': 15, 'protein': 3, 'fat': 3
        }
      },
      {
        'title': 'Purée d\'avocat et banane',
        'ageGroup': '4-6 mois',
        'imageUrl': 'assets/images/puree_avocat_banane.png',
        'ingredients': ['Avocat', 'Banane'],
        'materials': ['Bol', 'Fourchette'],
        'instructions': [
          'Écrasez l\'avocat et la banane à la fourchette jusqu\'à obtenir une consistance lisse.',
          'Servez immédiatement pour éviter l\'oxydation de l\'avocat.',
        ],
        'description': 'Une purée de fruits crémeuse et riche en bonnes graisses.',
        'prepTime': 5,
        'cookTime': 0,
        'texture': 'Purée',
        'difficulty': 'Facile',
        'allergens': [],
        'nutrition': {
          'calories': 140, 'carbs': 12, 'protein': 2, 'fat': 10
        }
      },
      {
        'title': 'Riz au lait de coco',
        'ageGroup': '8-12 mois',
        'imageUrl': 'assets/images/riz_coco.png',
        'ingredients': ['Riz', 'Lait de Coco', 'Vanille'],
        'materials': ['Casserole'],
        'instructions': [
          'Rincez le riz. Faites-le cuire doucement dans le lait de coco avec la vanille.',
          'Remuez régulièrement pour que le riz absorbe le lait.',
          'Laissez tiédir avant de servir.',
        ],
        'description': 'Un dessert lacté exotique et très doux.',
        'prepTime': 5,
        'cookTime': 20,
        'texture': 'Mixte',
        'difficulty': 'Facile',
        'allergens': ['Lait'],
        'nutrition': {
          'calories': 180, 'carbs': 25, 'protein': 3, 'fat': 8
        }
      },
      {
        'title': 'Soupe de poulet et de riz',
        'ageGroup': '12-18 mois',
        'imageUrl': 'assets/images/soupe_poulet_riz.png',
        'ingredients': ['Poulet', 'Riz', 'Carotte', 'Oignon'],
        'materials': ['Marmite', 'Louche'],
        'instructions': [
          'Coupez le poulet et les légumes en petits morceaux.',
          'Faites-les mijoter avec le riz dans de l\'eau. Assaisonnez au goût.',
          'Servez en soupe pour un repas complet.',
        ],
        'description': 'Une soupe nourrissante et facile à manger pour les plus grands.',
        'prepTime': 15,
        'cookTime': 35,
        'texture': 'Liquide',
        'difficulty': 'Moyen',
        'allergens': [],
        'nutrition': {
          'calories': 220, 'carbs': 25, 'protein': 18, 'fat': 5
        }
      },
      {
        'title': 'Couscous de mil au lait',
        'ageGroup': '8-12 mois',
        'imageUrl': 'assets/images/couscous_mil_lait.png',
        'ingredients': ['Mil', 'Lait'],
        'materials': ['Bol', 'Cuillère'],
        'instructions': [
          'Préparez le mil et faites-le cuire selon les instructions du paquet.',
          'Servez le mil cuit dans un bol avec du lait tiède.',
        ],
        'description': 'Un repas traditionnel africain adapté aux besoins de bébé.',
        'prepTime': 10,
        'cookTime': 10,
        'texture': 'Morceaux',
        'difficulty': 'Facile',
        'allergens': ['Lait'],
        'nutrition': {
          'calories': 160, 'carbs': 20, 'protein': 5, 'fat': 6
        }
      },

      // --- Début des nouvelles recettes ---
      {
        'title': 'Compote de mangue',
        'ageGroup': '4-6 mois',
        'imageUrl': 'assets/images/compote_mangue.png',
        'ingredients': ['Mangue'],
        'materials': ['Couteau', 'Casserole', 'Mixeur'],
        'instructions': [
          'Lavez et épluchez la mangue et coupez-la en morceaux.',
          'Faites cuire les morceaux à la vapeur ou dans une casserole d’eau pendant 10 minutes.',
          'Une fois tendres, mixez pour obtenir une compote bien lisse.',
        ],
        'description': 'Une petite douceur pour débuter l\'alimentation complémentaire.',
        'prepTime': 10,
        'cookTime': 10,
        'texture': 'Purée',
        'difficulty': 'Facile',
        'allergens': [],
        'nutrition': {'calories': 60, 'carbs': 15, 'protein': 0.8, 'fat': 0.4},
      },
      {
        'title': 'Compote de pomme',
        'ageGroup': '4-6 mois',
        'imageUrl': 'assets/images/compote_pomme.png',
        'ingredients': ['Pomme'],
        'materials': ['Couteau', 'Casserole', 'Mixeur'],
        'instructions': [
          'Épluchez la pomme et retirez le centre dur et les pépins.',
          'Coupez en petits morceaux et faites cuire à la vapeur ou dans une casserole d’eau pendant 10 minutes.',
          'Mixez pour obtenir une compote bien lisse.'
        ],
        'description': 'Une recette facile, riche en vitamines C, B et E.',
        'prepTime': 10,
        'cookTime': 10,
        'texture': 'Purée',
        'difficulty': 'Facile',
        'allergens': [],
        'nutrition': {'calories': 95, 'carbs': 25, 'protein': 0.5, 'fat': 0.3},
      },
      {
        'title': 'Purée de courge',
        'ageGroup': '4-6 mois',
        'imageUrl': 'assets/images/puree_courge.png',
        'ingredients': ['Courge'],
        'materials': ['Couteau', 'Casserole', 'Mixeur'],
        'instructions': [
          'Nettoyez et coupez le morceau de courge en petits dés.',
          'Faites cuire à la vapeur ou à l’eau pendant 20 minutes.',
          'Mixez pour obtenir une belle purée lisse et homogène.'
        ],
        'description': 'Une purée de courge plus délicieuse que la purée de carotte.',
        'prepTime': 10,
        'cookTime': 20,
        'texture': 'Purée',
        'difficulty': 'Facile',
        'allergens': [],
        'nutrition': {'calories': 20, 'carbs': 5, 'protein': 0.7, 'fat': 0.1},
      },
      {
        'title': 'Compote de poire',
        'ageGroup': '4-6 mois',
        'imageUrl': 'assets/images/compote_poire.png',
        'ingredients': ['Poire'],
        'materials': ['Couteau', 'Casserole', 'Mixeur'],
        'instructions': [
          'Épluchez la poire, épépinez et coupez-la en morceaux.',
          'Faites cuire les morceaux à la vapeur ou à l\'eau bouillante pendant environ 10 minutes.',
          'Mixez pour obtenir une compote lisse au bon plaisir de bébé.'
        ],
        'description': 'Une recette simple et délicieuse pour le goûter de bébé.',
        'prepTime': 5,
        'cookTime': 10,
        'texture': 'Purée',
        'difficulty': 'Facile',
        'allergens': [],
        'nutrition': {'calories': 57, 'carbs': 15, 'protein': 0.4, 'fat': 0.1},
      },
      {
        'title': 'Purée de carotte au beurre',
        'ageGroup': '6-8 mois',
        'imageUrl': 'assets/images/puree_carotte.png',
        'ingredients': ['Carotte', 'Beurre'],
        'materials': ['Couteau', 'Casserole', 'Mixeur'],
        'instructions': [
          'Épluchez et rincez les carottes. Coupez-les en petits morceaux.',
          'Faites-les cuire à la vapeur jusqu’à ce qu’ils soient tendres.',
          'Mixez pour obtenir une purée lisse. Ajoutez une noisette de beurre et mélangez.'
        ],
        'description': 'Une purée douce pour apprendre à bébé à aimer les légumes.',
        'prepTime': 10,
        'cookTime': 20,
        'texture': 'Purée',
        'difficulty': 'Facile',
        'allergens': ['Lait'],
        'nutrition': {'calories': 70, 'carbs': 10, 'protein': 1.5, 'fat': 3},
      },
      {
        'title': 'Purée d’avocat – pomme de terre',
        'ageGroup': '6-8 mois',
        'imageUrl': 'assets/images/puree_avocat_banane.png',
        'ingredients': ['Avocat', 'Pomme de terre'],
        'materials': ['Couteau', 'Casserole', 'Mixeur'],
        'instructions': [
          'Faites cuire les morceaux de pomme de terre jusqu\'à ce qu\'ils soient cuits.',
          'Mixez les morceaux de pomme de terre et les morceaux d\'avocat jusqu\'à obtenir une purée lisse.'
        ],
        'description': 'Une purée riche en vitamines et en oligo-éléments essentiels.',
        'prepTime': 10,
        'cookTime': 15,
        'texture': 'Purée',
        'difficulty': 'Facile',
        'allergens': [],
        'nutrition': {'calories': 120, 'carbs': 15, 'protein': 2, 'fat': 6},
      },
      {
        'title': 'Purée de plantain - épinard',
        'ageGroup': '6-8 mois',
        'imageUrl': 'assets/images/puree_plantain.png',
        'ingredients': ['Banane plantain', 'Epinard', 'Huile végétale'],
        'materials': ['Couteau', 'Casserole', 'Mixeur'],
        'instructions': [
          'Épluchez la banane, coupez-la en morceaux. Lavez les feuilles d’épinard.',
          'Faites cuire dans une casserole avec de l’eau environ 15 min.',
          'Mixez avec l\'huile pour obtenir une purée lisse et homogène.'
        ],
        'description': 'Une purée onctueuse pour apprendre à bébé à aimer les légumes d\'ici.',
        'prepTime': 10,
        'cookTime': 15,
        'texture': 'Purée',
        'difficulty': 'Facile',
        'allergens': [],
        'nutrition': {'calories': 130, 'carbs': 25, 'protein': 3, 'fat': 2},
      },
      {
        'title': 'Purée de patate – jambon - fromage',
        'ageGroup': '6-8 mois',
        'imageUrl': 'assets/images/04m.png',
        'ingredients': ['Patate douce', 'Brocoli', 'Jambon blanc', 'Fromage'],
        'materials': ['Couteau', 'Casserole', 'Mixeur'],
        'instructions': [
          'Épluchez et coupez la patate douce et le brocoli en dés.',
          'Faites cuire pendant 20 minutes.',
          'Mixez les légumes avec le jambon et le fromage.'
        ],
        'description': 'Une recette idéale pour éveiller en douceur le goût de votre nourrisson.',
        'prepTime': 15,
        'cookTime': 20,
        'texture': 'Purée',
        'difficulty': 'Facile',
        'allergens': ['Lait'],
        'nutrition': {'calories': 160, 'carbs': 18, 'protein': 8, 'fat': 6},
      },
      {
        'title': 'Purée de concombre - carotte',
        'ageGroup': '6-8 mois',
        'imageUrl': 'assets/images/05m.png',
        'ingredients': ['Concombre', 'Carotte', 'Beurre'],
        'materials': ['Couteau', 'Casserole', 'Mixeur'],
        'instructions': [
          'Épluchez et coupez la carotte et le concombre en petits dés.',
          'Faites-les cuire à la vapeur. Mixez avec le beurre.'
        ],
        'description': 'Une purée légèrement sucrée pour le dîner de bébé.',
        'prepTime': 10,
        'cookTime': 10,
        'texture': 'Purée',
        'difficulty': 'Facile',
        'allergens': ['Lait'],
        'nutrition': {'calories': 80, 'carbs': 8, 'protein': 1, 'fat': 4},
      },
      {
        'title': 'Purée de pomme de terre - fromage',
        'ageGroup': '6-8 mois',
        'imageUrl': 'assets/images/06m.png',
        'ingredients': ['Courgette', 'Pomme de terre', 'Fromage blanc'],
        'materials': ['Couteau', 'Casserole', 'Mixeur'],
        'instructions': [
          'Coupez les légumes en dés. Faites-les bouillir pendant 15 min.',
          'Mixez les légumes avec le fromage.'
        ],
        'description': 'Une recette simple pour le déjeuner de bébé, riche en vitamines.',
        'prepTime': 10,
        'cookTime': 15,
        'texture': 'Purée',
        'difficulty': 'Facile',
        'allergens': ['Lait'],
        'nutrition': {'calories': 110, 'carbs': 15, 'protein': 4, 'fat': 4},
      },
      {
        'title': 'Purée de patate douce aux épinards - poisson',
        'ageGroup': '6-8 mois',
        'imageUrl': 'assets/images/puree_patate_douce.png',
        'ingredients': ['Patate douce', 'Poisson', 'Echalotte', 'Tomate', 'Carotte', 'Epinard', 'Huile végétale'],
        'materials': ['Couteau', 'Casserole', 'Mixeur'],
        'instructions': [
          'Lavez et coupez les légumes en dés. Faites-les revenir avec le poisson dans l\'huile.',
          'Ajoutez la patate douce et l\'eau, puis laissez cuire.',
          'Mixez le tout pour obtenir une purée.'
        ],
        'description': 'Une purée riche en vitamines et minéraux.',
        'prepTime': 15,
        'cookTime': 25,
        'texture': 'Purée',
        'difficulty': 'Moyen',
        'allergens': ['Poisson'],
        'nutrition': {'calories': 180, 'carbs': 18, 'protein': 10, 'fat': 7},
      },
      {
        'title': 'Purée de pomme de terre - tomate',
        'ageGroup': '6-8 mois',
        'imageUrl': 'assets/images/08m.png',
        'ingredients': ['Pomme de terre', 'Poisson fumé', 'Tomate', 'Huile'],
        'materials': ['Couteau', 'Casserole', 'Mixeur'],
        'instructions': [
          'Faites revenir la tomate et le poisson dans l\'huile.',
          'Ajoutez l\'eau et la pomme de terre et portez à ébullition.',
          'Mixez le tout pour obtenir une purée lisse.'
        ],
        'description': 'Une purée délicieuse, riche en vitamines.',
        'prepTime': 10,
        'cookTime': 15,
        'texture': 'Purée',
        'difficulty': 'Facile',
        'allergens': ['Poisson'],
        'nutrition': {'calories': 110, 'carbs': 14, 'protein': 4, 'fat': 4},
      },
      {
        'title': 'Purée de maïs au beurre',
        'ageGroup': '6-8 mois',
        'imageUrl': 'assets/images/Puree_mais.png',
        'ingredients': ['Maïs', 'Beurre'],
        'materials': ['Mixeur'],
        'instructions': [
          'Ajoutez le maïs chaud dans le mixeur avec l\'eau.',
          'Mixez avec le beurre pour obtenir une purée bien lisse et homogène.'
        ],
        'description': 'Une délicieuse recette de purée de maïs facile à réaliser.',
        'prepTime': 5,
        'cookTime': 5,
        'texture': 'Purée',
        'difficulty': 'Facile',
        'allergens': ['Lait'],
        'nutrition': {'calories': 100, 'carbs': 16, 'protein': 2, 'fat': 3},
      },
      {
        'title': 'Purée de pomme de terre',
        'ageGroup': '6-8 mois',
        'imageUrl': 'assets/images/10m.png',
        'ingredients': ['Pomme de terre', 'Lait', 'Beurre'],
        'materials': ['Couteau', 'Casserole', 'Mixeur'],
        'instructions': [
          'Épluchez la pomme de terre et faites-la cuire à la vapeur.',
          'Mixez avec le beurre et le lait.'
        ],
        'description': 'Une purée facile à réaliser pour démarrer la diversification.',
        'prepTime': 10,
        'cookTime': 15,
        'texture': 'Purée',
        'difficulty': 'Facile',
        'allergens': ['Lait'],
        'nutrition': {'calories': 120, 'carbs': 20, 'protein': 3, 'fat': 4},
      },
      {
        'title': 'Dessert Pomme – banane au lait',
        'ageGroup': '6-8 mois',
        'imageUrl': 'assets/images/11m.png',
        'ingredients': ['Pomme', 'Banane', 'Lait'],
        'materials': ['Couteau', 'Casserole', 'Mixeur'],
        'instructions': [
          'Épluchez et coupez la pomme en dés et faites-la cuire à la vapeur.',
          'Une fois cuite, épluchez la banane, coupez-la en rondelles et mixez avec la pomme et le lait.'
        ],
        'description': 'Un dessert ou goûter riche en vitamines.',
        'prepTime': 10,
        'cookTime': 10,
        'texture': 'Purée',
        'difficulty': 'Facile',
        'allergens': ['Lait'],
        'nutrition': {'calories': 150, 'carbs': 25, 'protein': 3, 'fat': 4},
      },
      {
        'title': 'Bouillie aux trois céréales (riz-mil et sorgho)',
        'ageGroup': '6-8 mois',
        'imageUrl': 'assets/images/12m.png',
        'ingredients': ['Riz', 'Mil', 'Sorgho', 'Beurre', 'Lait'],
        'materials': ['Bol', 'Casserole'],
        'instructions': [
          'Diluez les farines dans l\'eau. Mélangez pour écraser les grumeaux.',
          'Versez dans une casserole, portez à ébullition et mélangez jusqu\'à épaississement.',
          'Ajoutez le beurre et le lait avant de servir.'
        ],
        'description': 'Une bouillie consistante pour le petit-déjeuner de bébé.',
        'prepTime': 5,
        'cookTime': 10,
        'texture': 'Bouillie',
        'difficulty': 'Facile',
        'allergens': ['Lait'],
        'nutrition': {'calories': 180, 'carbs': 30, 'protein': 6, 'fat': 4},
      },
      {
        'title': 'Bouillie de maïs blanc à la pomme',
        'ageGroup': '6-8 mois',
        'imageUrl': 'assets/images/13m.png',
        'ingredients': ['Maïs blanc', 'Pomme', 'Lait'],
        'materials': ['Casserole', 'Mixeur'],
        'instructions': [
          'Délayez la farine de maïs dans l\'eau et faites cuire à feu moyen.',
          'Pendant ce temps, mixez la pomme.',
          'Ajoutez la purée de pomme à la bouillie et servez avec le lait.'
        ],
        'description': 'Une bouillie savoureuse pour bébé, dès 6 mois.',
        'prepTime': 10,
        'cookTime': 15,
        'texture': 'Bouillie',
        'difficulty': 'Facile',
        'allergens': ['Lait'],
        'nutrition': {'calories': 160, 'carbs': 25, 'protein': 4, 'fat': 5},
      },
      {
        'title': 'Bouillie de tapioca à la pomme',
        'ageGroup': '6-8 mois',
        'imageUrl': 'assets/images/14m.png',
        'ingredients': ['Tapioca', 'Compote de pomme', 'Lait'],
        'materials': ['Casserole'],
        'instructions': [
          'Dans une casserole, ajoutez l’eau et le tapioca. Mélangez.',
          'Faites cuire jusqu’à ce que les grains deviennent translucides.',
          'Ajoutez la compote de pomme et le lait, mélangez et servez.'
        ],
        'description': 'Une délicieuse recette à base de farine de Tapioca pour bébé.',
        'prepTime': 5,
        'cookTime': 10,
        'texture': 'Bouillie',
        'difficulty': 'Facile',
        'allergens': ['Lait'],
        'nutrition': {'calories': 140, 'carbs': 28, 'protein': 2, 'fat': 3},
      },
      {
        'title': 'Purée de riz à la pâte d’arachide',
        'ageGroup': '6-8 mois',
        'imageUrl': 'assets/images/17m.png',
        'ingredients': ['Riz', 'Pâte d’arachide', 'Jus d’orange'],
        'materials': ['Casserole', 'Mixeur'],
        'instructions': [
          'Faites cuire le riz dans l\'eau jusqu\'à ce qu\'il soit très mou.',
          'Délayez la pâte d\'arachide dans de l\'eau de cuisson et ajoutez-la au riz.',
          'Mixez et ajoutez le jus d’orange avant de servir.'
        ],
        'description': 'Une purée nourrissante pour bébé, riche en saveurs.',
        'prepTime': 10,
        'cookTime': 20,
        'texture': 'Purée',
        'difficulty': 'Facile',
        'allergens': ['Arachide'],
        'nutrition': {'calories': 200, 'carbs': 25, 'protein': 7, 'fat': 8},
      },
      {
        'title': 'Purée de riz aux épinards',
        'ageGroup': '6-8 mois',
        'imageUrl': 'assets/images/18m.png',
        'ingredients': ['Epinards', 'Riz', 'Oignon', 'Maquereau fumé', 'Tomate'],
        'materials': ['Couteau', 'Casserole', 'Mixeur'],
        'instructions': [
          'Faites revenir la tomate et l\'oignon dans l\'huile, ajoutez les épinards et le riz.',
          'Ajoutez le poisson et l\'eau, laissez cuire.',
          'Mixez pour obtenir une purée lisse.'
        ],
        'description': 'Une délicieuse recette de riz aux épinards pour bébé.',
        'prepTime': 15,
        'cookTime': 25,
        'texture': 'Purée',
        'difficulty': 'Moyen',
        'allergens': ['Poisson'],
        'nutrition': {'calories': 170, 'carbs': 18, 'protein': 10, 'fat': 6},
      },
      {
        'title': 'Bouillie de riz – poire - banane',
        'ageGroup': '6-8 mois',
        'imageUrl': 'assets/images/19m.png',
        'ingredients': ['Poire', 'Banane', 'Riz'],
        'materials': ['Couteau', 'Casserole', 'Mixeur'],
        'instructions': [
          'Lavez et coupez les fruits en morceaux. Lavez le riz.',
          'Faites cuire le riz et les fruits dans une casserole avec de l\'eau.',
          'Mixez le tout pour obtenir la consistance souhaitée.'
        ],
        'description': 'Une bouillie aux fruits pour une saveur douce et naturelle.',
        'prepTime': 10,
        'cookTime': 15,
        'texture': 'Bouillie',
        'difficulty': 'Facile',
        'allergens': [],
        'nutrition': {'calories': 150, 'carbs': 30, 'protein': 2, 'fat': 1},
      },
      {
        'title': 'Purée de riz aux légumes – poulet',
        'ageGroup': '7-9 mois',
        'imageUrl': 'assets/images/20m.png',
        'ingredients': ['Riz', 'Carotte', 'Courge', 'Tomate', 'Echalotte', 'Poulet', 'Persil'],
        'materials': ['Couteau', 'Casserole', 'Mixeur'],
        'instructions': [
          'Faites dorer le poulet. Ajoutez les légumes et le persil.',
          'Ajoutez le riz, mélangez, puis ajoutez l\'eau et laissez cuire.',
          'Mixez ensuite pour obtenir une purée lisse.'
        ],
        'description': 'Une purée complète à base de riz, légumes et poulet.',
        'prepTime': 15,
        'cookTime': 25,
        'texture': 'Purée',
        'difficulty': 'Moyen',
        'allergens': [],
        'nutrition': {'calories': 200, 'carbs': 25, 'protein': 12, 'fat': 6},
      },
      {
        'title': 'Purée de courge – carotte - beurre',
        'ageGroup': '6-8 mois',
        'imageUrl': 'assets/images/21m.png',
        'ingredients': ['Courge', 'Carotte', 'Beurre'],
        'materials': ['Couteau', 'Casserole', 'Mixeur'],
        'instructions': [
          'Lavez et coupez les légumes en dés. Faites-les cuire à la vapeur.',
          'Mixez avec le beurre pour obtenir une purée lisse et homogène.'
        ],
        'description': 'Une purée riche en vitamines A, idéale pour les déjeuners.',
        'prepTime': 10,
        'cookTime': 10,
        'texture': 'Purée',
        'difficulty': 'Facile',
        'allergens': ['Lait'],
        'nutrition': {'calories': 80, 'carbs': 10, 'protein': 1, 'fat': 4},
      },
      {
        'title': 'Compote de mangue – made (côcôta)',
        'ageGroup': '8-12 mois',
        'imageUrl': 'assets/images/09a.png',
        'ingredients': ['Mangue', 'Made'],
        'materials': ['Couteau', 'Casserole', 'Mixeur'],
        'instructions': [
          'Préparez le jus de made. Épluchez la mangue et coupez-la en morceaux.',
          'Faites cuire la mangue avec le jus de made sur un feu doux.',
          'Mixez pour obtenir un mélange bien lisse.'
        ],
        'description': 'Une compote avec un goût particulier qui éveille les papilles de bébé.',
        'prepTime': 15,
        'cookTime': 15,
        'texture': 'Purée',
        'difficulty': 'Facile',
        'allergens': [],
        'nutrition': {'calories': 90, 'carbs': 22, 'protein': 1, 'fat': 0.5},
      },
      {
        'title': 'Compote de pomme et mangue',
        'ageGroup': '6-8 mois',
        'imageUrl': 'assets/images/23m.png',
        'ingredients': ['Pomme', 'Mangue'],
        'materials': ['Couteau', 'Casserole', 'Mixeur'],
        'instructions': [
          'Épluchez et coupez les fruits. Faites-les cuire à la vapeur pendant 10 minutes.',
          'Mixez pour obtenir une compote lisse.'
        ],
        'description': 'Une délicieuse purée idéale pour le goûter de bébé.',
        'prepTime': 10,
        'cookTime': 10,
        'texture': 'Purée',
        'difficulty': 'Facile',
        'allergens': [],
        'nutrition': {'calories': 80, 'carbs': 20, 'protein': 0.7, 'fat': 0.3},
      },
      {
        'title': 'Compote de mangue et banane',
        'ageGroup': '6-8 mois',
        'imageUrl': 'assets/images/24m.png',
        'ingredients': ['Mangue', 'Banane'],
        'materials': ['Couteau', 'Casserole', 'Mixeur'],
        'instructions': [
          'Épluchez et coupez les fruits en morceaux. Faites-les cuire à la vapeur ou avec de l\'eau pendant 8 à 10 minutes.',
          'Mixez pour obtenir une purée bien lisse.'
        ],
        'description': 'Une compote de fruits facile à réaliser pour faire le plein de vitamines.',
        'prepTime': 10,
        'cookTime': 10,
        'texture': 'Purée',
        'difficulty': 'Facile',
        'allergens': [],
        'nutrition': {'calories': 110, 'carbs': 28, 'protein': 1, 'fat': 0.5},
      },
      {
        'title': 'Bouillie de blé au beurre',
        'ageGroup': '6-8 mois',
        'imageUrl': 'assets/images/25m.png',
        'ingredients': ['Farine de blé', 'Lait', 'Beurre'],
        'materials': ['Casserole'],
        'instructions': [
          'Dans une casserole, délayez la farine de blé dans l\'eau.',
          'Portez à ébullition et mélangez jusqu\'à épaississement.',
          'Ajoutez le lait et le beurre.'
        ],
        'description': 'Une bouillie au beurre, idéale pour le déjeuner de bébé.',
        'prepTime': 5,
        'cookTime': 10,
        'texture': 'Bouillie',
        'difficulty': 'Facile',
        'allergens': ['Gluten', 'Lait'],
        'nutrition': {'calories': 150, 'carbs': 20, 'protein': 5, 'fat': 6},
      },
      {
        'title': 'Purée de pomme de terre au beurre',
        'ageGroup': '6-8 mois',
        'imageUrl': 'assets/images/26m.png',
        'ingredients': ['Pomme de terre', 'Beurre'],
        'materials': ['Couteau', 'Casserole', 'Mixeur'],
        'instructions': [
          'Lavez et coupez la pomme de terre. Faites-la cuire à l\'eau pendant 10 min.',
          'Mixez les morceaux avec le beurre pour obtenir une purée lisse et homogène.'
        ],
        'description': 'Une purée simple et délicieuse, tous les bébés en raffolent.',
        'prepTime': 10,
        'cookTime': 10,
        'texture': 'Purée',
        'difficulty': 'Facile',
        'allergens': ['Lait'],
        'nutrition': {'calories': 130, 'carbs': 20, 'protein': 2, 'fat': 5},
      },
      {
        'title': 'Purée de carotte à l’orange',
        'ageGroup': '6-8 mois',
        'imageUrl': 'assets/images/27m.png',
        'ingredients': ['Carotte', 'Orange'],
        'materials': ['Couteau', 'Casserole', 'Mixeur'],
        'instructions': [
          'Lavez et pelez la carotte et l\'orange. Pressez le jus de l\'orange.',
          'Faites cuire les rondelles de carotte à la vapeur pendant 10 minutes.',
          'Mixez avec le jus d\'orange pour obtenir une purée lisse.'
        ],
        'description': 'Un mélange surprenant et savoureux pour les papilles de bébé.',
        'prepTime': 10,
        'cookTime': 10,
        'texture': 'Purée',
        'difficulty': 'Facile',
        'allergens': [],
        'nutrition': {'calories': 70, 'carbs': 15, 'protein': 1, 'fat': 0.5},
      },
      {
        'title': 'Bouillie de mil - banane',
        'ageGroup': '6-8 mois',
        'imageUrl': 'assets/images/28m.png',
        'ingredients': ['Mil', 'Banane', 'Lait'],
        'materials': ['Casserole'],
        'instructions': [
          'Diluez la farine de mil dans l\'eau. Portez à ébullition en mélangeant.',
          'Laissez cuire. Ajoutez la banane écrasée et le lait.',
          'Mélangez et servez.'
        ],
        'description': 'Une bouillie avec une saveur pétillante pour le petit-déjeuner.',
        'prepTime': 10,
        'cookTime': 15,
        'texture': 'Bouillie',
        'difficulty': 'Facile',
        'allergens': ['Lait'],
        'nutrition': {'calories': 170, 'carbs': 28, 'protein': 5, 'fat': 3},
      },
      {
        'title': 'Purée de plantain au beurre',
        'ageGroup': '6-8 mois',
        'imageUrl': 'assets/images/29m.png',
        'ingredients': ['Banane plantain', 'Beurre'],
        'materials': ['Casserole', 'Mixeur'],
        'instructions': [
          'Pelez la banane plantain, coupez-la et faites-la cuire.',
          'Mixez avec le beurre et un peu d\'eau de cuisson.'
        ],
        'description': 'Une recette simple et facile à réaliser pour bébé.',
        'prepTime': 5,
        'cookTime': 15,
        'texture': 'Purée',
        'difficulty': 'Facile',
        'allergens': ['Lait'],
        'nutrition': {'calories': 140, 'carbs': 25, 'protein': 1.5, 'fat': 4},
      },
      {
        'title': 'Compote de pomme et baobab au lait',
        'ageGroup': '6-8 mois',
        'imageUrl': 'assets/images/30m.png',
        'ingredients': ['Pomme', 'Baobab', 'Lait'],
        'materials': ['Couteau', 'Casserole', 'Mixeur'],
        'instructions': [
          'Épluchez et coupez la pomme. Faites-la cuire.',
          'Mixez la pomme cuite avec la poudre de baobab et le lait infantile.'
        ],
        'description': 'Une compote délicieuse pour faire le plein de vitamines.',
        'prepTime': 10,
        'cookTime': 10,
        'texture': 'Purée',
        'difficulty': 'Facile',
        'allergens': ['Lait'],
        'nutrition': {'calories': 100, 'carbs': 20, 'protein': 2, 'fat': 2},
      },
      {
        'title': 'Compote de pomme et banane à l’orange',
        'ageGroup': '6-8 mois',
        'imageUrl': 'assets/images/31m.png',
        'ingredients': ['Pomme', 'Banane', 'Orange'],
        'materials': ['Couteau', 'Casserole', 'Mixeur'],
        'instructions': [
          'Épluchez et coupez les fruits en dés. Faites-les cuire dans une casserole avec de l’eau.',
          'Mixez les fruits pour obtenir une compote bien lisse.'
        ],
        'description': 'Une compote fruitée pour faire le plein de vitamine C.',
        'prepTime': 10,
        'cookTime': 15,
        'texture': 'Purée',
        'difficulty': 'Facile',
        'allergens': [],
        'nutrition': {'calories': 130, 'carbs': 30, 'protein': 1, 'fat': 0.5},
      },
      {
        'title': 'Crème de banane au lait',
        'ageGroup': '7-9 mois',
        'imageUrl': 'assets/images/32m.png',
        'ingredients': ['Banane', 'Lait', 'Jus de citron'],
        'materials': ['Bol', 'Mixeur'],
        'instructions': [
          'Épluchez et découpez la banane en rondelles.',
          'Mixez la banane avec le lait et le jus de citron jusqu\'à obtenir une texture très lisse.',
          'Réservez au frais avant de servir.'
        ],
        'description': 'Une petite douceur à partir de 7 mois pour égayer les papilles de bébé.',
        'prepTime': 5,
        'cookTime': 0,
        'texture': 'Purée',
        'difficulty': 'Facile',
        'allergens': ['Lait'],
        'nutrition': {'calories': 140, 'carbs': 25, 'protein': 4, 'fat': 4},
      },
      {
        'title': 'Bouillie de riz au soja au lait',
        'ageGroup': '6-8 mois',
        'imageUrl': 'assets/images/33m.png',
        'ingredients': ['Farine de riz-soja', 'Lait'],
        'materials': ['Casserole'],
        'instructions': [
          'Diluez la farine dans l\'eau. Faites cuire en mélangeant jusqu\'à épaississement.',
          'Retirez du feu, laissez tiédir, puis ajoutez le lait.'
        ],
        'description': 'Une bouillie riche en protéines, idéale pour le petit-déjeuner.',
        'prepTime': 5,
        'cookTime': 10,
        'texture': 'Bouillie',
        'difficulty': 'Facile',
        'allergens': ['Soja', 'Lait'],
        'nutrition': {'calories': 180, 'carbs': 28, 'protein': 8, 'fat': 4},
      },
      {
        'title': 'Purée de pomme de terre, courgette et petits pois au poulet',
        'ageGroup': '7-9 mois',
        'imageUrl': 'assets/images/34m.png',
        'ingredients': ['Courgette', 'Petits pois', 'Pomme de terre', 'Poulet'],
        'materials': ['Couteau', 'Casserole', 'Mixeur'],
        'instructions': [
          'Lavez et coupez les légumes et le poulet en dés.',
          'Faites-les cuire ensemble. Retirez du feu et égouttez.',
          'Mixez les légumes pour obtenir une purée un peu grumeleuse.'
        ],
        'description': 'Un plat complet pour nos bébés à partir de 7 mois.',
        'prepTime': 15,
        'cookTime': 15,
        'texture': 'Mixte',
        'difficulty': 'Moyen',
        'allergens': [],
        'nutrition': {'calories': 160, 'carbs': 18, 'protein': 12, 'fat': 4},
      },
      {
        'title': 'Purée de pomme de terre – œuf',
        'ageGroup': '7-9 mois',
        'imageUrl': 'assets/images/35m.png',
        'ingredients': ['Pomme de terre', 'Oeuf', 'Oignon', 'Tomate', 'Huile'],
        'materials': ['Couteau', 'Casserole', 'Mixeur'],
        'instructions': [
          'Faites cuire les légumes et l\'œuf.',
          'Faites revenir l\'oignon et la tomate dans l\'huile.',
          'Mixez les légumes avec la quantité d\'œuf adéquate.'
        ],
        'description': 'Une purée nourrissante pour la croissance de bébé.',
        'prepTime': 10,
        'cookTime': 15,
        'texture': 'Purée',
        'difficulty': 'Moyen',
        'allergens': ['Oeuf'],
        'nutrition': {'calories': 150, 'carbs': 15, 'protein': 8, 'fat': 6},
      },
      {
        'title': 'Compote banane et cacao',
        'ageGroup': '6-8 mois',
        'imageUrl': 'assets/images/36m.png',
        'ingredients': ['Banane', 'Poudre de cacao'],
        'materials': ['Casserole', 'Mixeur'],
        'instructions': [
          'Faites cuire la banane à la vapeur.',
          'Mixez les morceaux de banane cuits avec le cacao.'
        ],
        'description': 'Une délicieuse compote pour faire découvrir le cacao à bébé.',
        'prepTime': 5,
        'cookTime': 15,
        'texture': 'Purée',
        'difficulty': 'Facile',
        'allergens': [],
        'nutrition': {'calories': 120, 'carbs': 25, 'protein': 2, 'fat': 2},
      },
      {
        'title': 'Purée de pomme de terre et salade',
        'ageGroup': '6-8 mois',
        'imageUrl': 'assets/images/37.mpng.png',
        'ingredients': ['Pomme de terre', 'Salade', 'Beurre'],
        'materials': ['Couteau', 'Casserole', 'Mixeur'],
        'instructions': [
          'Lavez les salades et la pomme de terre. Coupez-les.',
          'Faites-les cuire pendant 15 min.',
          'Mixez avec le beurre pour obtenir une purée lisse et homogène.'
        ],
        'description': 'Bébé peut aussi consommer de la salade !',
        'prepTime': 10,
        'cookTime': 15,
        'texture': 'Purée',
        'difficulty': 'Facile',
        'allergens': ['Lait'],
        'nutrition': {'calories': 110, 'carbs': 18, 'protein': 2, 'fat': 4},
      },
      {
        'title': 'Compote de pomme au lait',
        'ageGroup': '6-8 mois',
        'imageUrl': 'assets/images/38m.png',
        'ingredients': ['Pomme', 'Lait'],
        'materials': ['Couteau', 'Casserole', 'Mixeur'],
        'instructions': [
          'Lavez et coupez la pomme. Faites-la cuire à la vapeur.',
          'Mixez avec le lait infantile 2ème âge.'
        ],
        'description': 'Une compote au lait pour le goûter de bébé.',
        'prepTime': 5,
        'cookTime': 10,
        'texture': 'Purée',
        'difficulty': 'Facile',
        'allergens': ['Lait'],
        'nutrition': {'calories': 90, 'carbs': 18, 'protein': 3, 'fat': 2},
      },
      {
        'title': 'Purée de plantain au poulet',
        'ageGroup': '6-8 mois',
        'imageUrl': 'assets/images/39m.png',
        'ingredients': ['Banane plantain', 'Poulet', 'Tomate', 'Echalotte'],
        'materials': ['Couteau', 'Casserole', 'Mixeur'],
        'instructions': [
          'Faites revenir le poulet avec la tomate et l\'échalote.',
          'Ajoutez la banane plantain et l\'eau, puis laissez cuire.',
          'Mixez pour obtenir une purée bien lisse.'
        ],
        'description': 'Une recette délicieuse avec une saveur africaine.',
        'prepTime': 15,
        'cookTime': 20,
        'texture': 'Purée',
        'difficulty': 'Moyen',
        'allergens': [],
        'nutrition': {'calories': 180, 'carbs': 20, 'protein': 10, 'fat': 6},
      },
      {
        'title': 'Purée de maïs – pomme de terre à la sardine',
        'ageGroup': '7-9 mois',
        'imageUrl': 'assets/images/40m.png',
        'ingredients': ['Maïs', 'Pomme de terre', 'Tomate', 'Oignon', 'Sardine'],
        'materials': ['Couteau', 'Casserole', 'Mixeur'],
        'instructions': [
          'Faites revenir l\'oignon et la tomate. Ajoutez la pomme de terre et l\'eau.',
          'Laissez cuire, puis ajoutez le maïs et la sardine.',
          'Mixez le tout.'
        ],
        'description': 'Un somptueux déjeuner pour nos adorables petits anges de 7 mois.',
        'prepTime': 15,
        'cookTime': 20,
        'texture': 'Purée',
        'difficulty': 'Moyen',
        'allergens': ['Poisson'],
        'nutrition': {'calories': 200, 'carbs': 22, 'protein': 12, 'fat': 8},
      },
      {
        'title': 'Compote de banane et néré',
        'ageGroup': '6-8 mois',
        'imageUrl': 'assets/images/41m.png',
        'ingredients': ['Banane', 'Néré'],
        'materials': ['Couteau', 'Casserole', 'Mixeur'],
        'instructions': [
          'Épluchez et coupez la banane. Faites-la cuire à la vapeur.',
          'Mixez les rondelles de banane avec la poudre de néré pour obtenir une compote lisse et homogène.'
        ],
        'description': 'Une compote au goût particulier qui éveille les papilles de bébé.',
        'prepTime': 5,
        'cookTime': 10,
        'texture': 'Purée',
        'difficulty': 'Facile',
        'allergens': [],
        'nutrition': {'calories': 100, 'carbs': 20, 'protein': 2, 'fat': 1},
      },
      {
        'title': 'Purée de concombre au lait',
        'ageGroup': '6-8 mois',
        'imageUrl': 'assets/images/42m.png',
        'ingredients': ['Concombre', 'Lait', 'Beurre'],
        'materials': ['Couteau', 'Casserole', 'Mixeur'],
        'instructions': [
          'Pelez et épépinez le concombre et coupez-le en morceaux.',
          'Faites-le cuire à la vapeur. Mixez avec le beurre.',
          'Ajoutez le lait progressivement tout en mélangeant.'
        ],
        'description': 'Une délicieuse purée lisse et légère pour nos lapins.',
        'prepTime': 10,
        'cookTime': 10,
        'texture': 'Purée',
        'difficulty': 'Facile',
        'allergens': ['Lait'],
        'nutrition': {'calories': 60, 'carbs': 8, 'protein': 2, 'fat': 3},
      },
      {
        'title': 'Bouillie de maïs et mangue au lait',
        'ageGroup': '6-8 mois',
        'imageUrl': 'assets/images/43m.png',
        'ingredients': ['Farine de maïs', 'Lait', 'Mangue'],
        'materials': ['Casserole', 'Mixeur'],
        'instructions': [
          'Délayez la farine de maïs dans l\'eau et faites cuire.',
          'Pelez la mangue, mixez la pulpe pour obtenir une purée.',
          'Ajoutez la purée de mangue à la bouillie et servez avec le lait.'
        ],
        'description': 'Une bouillie savoureuse pour nos bébés.',
        'prepTime': 10,
        'cookTime': 15,
        'texture': 'Bouillie',
        'difficulty': 'Facile',
        'allergens': ['Lait'],
        'nutrition': {'calories': 180, 'carbs': 30, 'protein': 4, 'fat': 5},
      },
      {
        'title': 'Bouillie de mil et maïs et baobab',
        'ageGroup': '6-8 mois',
        'imageUrl': 'assets/images/44m.png',
        'ingredients': ['Farine de maïs', 'Farine de mil', 'Baobab', 'Lait', 'Beurre'],
        'materials': ['Casserole'],
        'instructions': [
          'Diluez les farines dans l\'eau et portez à ébullition en remuant.',
          'Laissez cuire, puis ajoutez le beurre et le lait.'
        ],
        'description': 'Une bouillie de céréales enrichie à la poudre de baobab pour apporter du tonus à bébé.',
        'prepTime': 5,
        'cookTime': 15,
        'texture': 'Bouillie',
        'difficulty': 'Facile',
        'allergens': ['Lait'],
        'nutrition': {'calories': 190, 'carbs': 30, 'protein': 5, 'fat': 6},
      },
      {
        'title': 'Bouillie de maïs au soja',
        'ageGroup': '6-8 mois',
        'imageUrl': 'assets/images/45m.png',
        'ingredients': ['Maïs', 'Soja', 'Banane'],
        'materials': ['Casserole'],
        'instructions': [
          'Mélangez les farines avec l\'eau. Faites cuire jusqu\'à épaississement.',
          'Écrasez la banane à la fourchette, puis ajoutez-la à la bouillie.'
        ],
        'description': 'Une recette à base de maïs et de soja pour le plaisir de nos bébés !',
        'prepTime': 10,
        'cookTime': 10,
        'texture': 'Bouillie',
        'difficulty': 'Facile',
        'allergens': ['Soja'],
        'nutrition': {'calories': 170, 'carbs': 28, 'protein': 7, 'fat': 4},
      },
      {
        'title': 'Compote pomme et ananas',
        'ageGroup': '6-8 mois',
        'imageUrl': 'assets/images/46m.png',
        'ingredients': ['Pomme', 'Ananas'],
        'materials': ['Couteau', 'Casserole', 'Mixeur'],
        'instructions': [
          'Épluchez et coupez les fruits en petits dés.',
          'Faites-les cuire à l\'eau pendant 10 minutes.',
          'Mixez pour obtenir une compote bien lisse.'
        ],
        'description': 'Une compote pour le plaisir de nos adorables bébés de 6 mois.',
        'prepTime': 10,
        'cookTime': 10,
        'texture': 'Purée',
        'difficulty': 'Facile',
        'allergens': [],
        'nutrition': {'calories': 70, 'carbs': 18, 'protein': 0.5, 'fat': 0.3},
      },
      {
        'title': 'Bouillie d’avoine au souchet',
        'ageGroup': '6-8 mois',
        'imageUrl': 'assets/images/47m.png',
        'ingredients': ['Flocons d’avoine', 'Farine de souchet', 'Lait'],
        'materials': ['Casserole'],
        'instructions': [
          'Versez l\'eau, les flocons d\'avoine et la farine de souchet dans une casserole.',
          'Mélangez et laissez cuire jusqu\'à épaississement.',
          'Ajoutez le lait et c\'est prêt !'
        ],
        'description': 'Une recette à base de bouillie d\'avoine au souchet.',
        'prepTime': 5,
        'cookTime': 10,
        'texture': 'Bouillie',
        'difficulty': 'Facile',
        'allergens': ['Lait'],
        'nutrition': {'calories': 180, 'carbs': 28, 'protein': 6, 'fat': 5},
      },
      {
        'title': 'Compote de mangue',
        'ageGroup': '6-8 mois',
        'imageUrl': 'assets/images/48m.png',
        'ingredients': ['Mangue', 'Eau'],
        'materials': ['Casserole', 'Mixeur'],
        'instructions': [
          'Faites cuire la mangue à la vapeur ou avec de l\'eau.',
          'Écrasez la mangue pour obtenir une purée bien lisse.'
        ],
        'description': 'Une petite douceur pour un goûter savoureux.',
        'prepTime': 5,
        'cookTime': 8,
        'texture': 'Purée',
        'difficulty': 'Facile',
        'allergens': [],
        'nutrition': {'calories': 60, 'carbs': 15, 'protein': 0.8, 'fat': 0.4},
      },
      {
        'title': 'Compote de poire au lait',
        'ageGroup': '6-8 mois',
        'imageUrl': 'assets/images/49m.png',
        'ingredients': ['Poire', 'Lait'],
        'materials': ['Couteau', 'Casserole', 'Mixeur'],
        'instructions': [
          'Épluchez la poire et coupez-la. Faites-la cuire à la vapeur.',
          'Mixez avec le lait infantile 2ème âge.'
        ],
        'description': 'Une petite douceur à offrir au goûter.',
        'prepTime': 5,
        'cookTime': 10,
        'texture': 'Purée',
        'difficulty': 'Facile',
        'allergens': ['Lait'],
        'nutrition': {'calories': 80, 'carbs': 15, 'protein': 3, 'fat': 2},
      },
      {
        'title': 'Purée de courge',
        'ageGroup': '6-8 mois',
        'imageUrl': 'assets/images/50m.png',
        'ingredients': ['Courge', 'Huile végétale', 'Beurre'],
        'materials': ['Couteau', 'Casserole'],
        'instructions': [
          'Faites cuire à la vapeur les morceaux de courge jusqu\'à ce qu\'ils deviennent tendres.',
          'Écrasez-les à l\'aide d\'une fourchette. Ajoutez l\'huile ou le beurre.'
        ],
        'description': 'Une purée simple et facile à réaliser pour bébé.',
        'prepTime': 10,
        'cookTime': 15,
        'texture': 'Purée',
        'difficulty': 'Facile',
        'allergens': ['Lait'],
        'nutrition': {'calories': 50, 'carbs': 8, 'protein': 1, 'fat': 2},
      },
      {
        'title': 'Bouillie de sorgho',
        'ageGroup': '6-8 mois',
        'imageUrl': 'assets/images/51m.png',
        'ingredients': ['Farine de sorgho', 'Banane', 'Lait', 'Beurre'],
        'materials': ['Casserole'],
        'instructions': [
          'Diluez la farine dans l\'eau. Portez à ébullition.',
          'Ajoutez le beurre et la purée de banane ou le lait.'
        ],
        'description': 'Une bouillie délicieuse pour le plaisir de bébé.',
        'prepTime': 5,
        'cookTime': 10,
        'texture': 'Bouillie',
        'difficulty': 'Facile',
        'allergens': ['Lait'],
        'nutrition': {'calories': 160, 'carbs': 28, 'protein': 4, 'fat': 3},
      },
      {
        'title': 'Compote de papaye',
        'ageGroup': '7-9 mois',
        'imageUrl': 'assets/images/52m.png',
        'ingredients': ['Papaye'],
        'materials': ['Mixeur'],
        'instructions': [
          'Écrasez la papaye avec l\'eau pour obtenir une purée bien lisse.',
        ],
        'description': 'Bonne pour la digestion et pour la peau, la papaye est un régal pour bébé.',
        'prepTime': 5,
        'cookTime': 0,
        'texture': 'Purée',
        'difficulty': 'Facile',
        'allergens': [],
        'nutrition': {'calories': 43, 'carbs': 11, 'protein': 0.5, 'fat': 0.3},
      },
      {
        'title': 'Purée de patate douce et carotte',
        'ageGroup': '6-8 mois',
        'imageUrl': 'assets/images/53m.png',
        'ingredients': ['Carotte', 'Patate douce', 'Poulet', 'Beurre'],
        'materials': ['Casserole', 'Mixeur'],
        'instructions': [
          'Faites cuire la patate douce, la carotte et le poulet pendant 15 min.',
          'Mixez avec le beurre pour obtenir une purée lisse.'
        ],
        'description': 'Une purée de patate douce pour le bonheur de nos petits bébés.',
        'prepTime': 10,
        'cookTime': 15,
        'texture': 'Purée',
        'difficulty': 'Moyen',
        'allergens': ['Lait'],
        'nutrition': {'calories': 160, 'carbs': 20, 'protein': 8, 'fat': 5},
      },
      {
        'title': 'Purée de printanière de légumes',
        'ageGroup': '6-8 mois',
        'imageUrl': 'assets/images/54m.png',
        'ingredients': ['Petits pois', 'Carotte', 'Navet', 'Tomate', 'Pomme de terre', 'Beurre'],
        'materials': ['Casserole', 'Mixeur'],
        'instructions': [
          'Faites cuire les légumes dans l\'eau (ou à la vapeur).',
          'Mixez pour obtenir une purée bien lisse.'
        ],
        'description': 'Une recette riche en saveurs qui ne fera qu\'égayer les papilles de bébé.',
        'prepTime': 10,
        'cookTime': 15,
        'texture': 'Purée',
        'difficulty': 'Moyen',
        'allergens': ['Lait'],
        'nutrition': {'calories': 100, 'carbs': 15, 'protein': 3, 'fat': 3},
      },
      {
        'title': 'Bouillie de mil',
        'ageGroup': '6-8 mois',
        'imageUrl': 'assets/images/55m.png',
        'ingredients': ['Farine de mil', 'Beurre', 'Lait'],
        'materials': ['Casserole'],
        'instructions': [
          'Diluez la farine de mil dans l\'eau. Portez à ébullition en mélangeant.',
          'Ajoutez le beurre et le lait.'
        ],
        'description': 'Le mil est une céréale riche qui permet à bébé de bien grandir.',
        'prepTime': 5,
        'cookTime': 10,
        'texture': 'Bouillie',
        'difficulty': 'Facile',
        'allergens': ['Lait'],
        'nutrition': {'calories': 150, 'carbs': 25, 'protein': 4, 'fat': 4},
      },
      {
        'title': 'Purée de légumes',
        'ageGroup': '6-8 mois',
        'imageUrl': 'assets/images/56m.png',
        'ingredients': ['Pomme de terre', 'Haricots verts', 'Tomate', 'Carotte', 'Oignon', 'Beurre'],
        'materials': ['Casserole', 'Mixeur'],
        'instructions': [
          'Faites revenir l\'oignon, la tomate et la carotte dans le beurre.',
          'Ajoutez l\'eau, les pommes de terre et les haricots verts, et laissez cuire.',
          'Mixez le tout jusqu\'à obtention d\'une purée bien lisse.'
        ],
        'description': 'Une purée de légumes pour bébé dès 6 mois.',
        'prepTime': 10,
        'cookTime': 25,
        'texture': 'Purée',
        'difficulty': 'Moyen',
        'allergens': ['Lait'],
        'nutrition': {'calories': 120, 'carbs': 18, 'protein': 4, 'fat': 4},
      },
      {
        'title': 'Purée de haricots verts',
        'ageGroup': '6-8 mois',
        'imageUrl': 'assets/images/57m.png',
        'ingredients': ['Pomme de terre', 'Haricots verts', 'Beurre'],
        'materials': ['Casserole', 'Mixeur'],
        'instructions': [
          'Épluchez la pomme de terre et faites-la cuire avec les haricots verts.',
          'Mixez avec une noisette de beurre avant de servir.'
        ],
        'description': 'Une purée de haricots verts pour profiter des bienfaits des légumes.',
        'prepTime': 10,
        'cookTime': 15,
        'texture': 'Purée',
        'difficulty': 'Facile',
        'allergens': ['Lait'],
        'nutrition': {'calories': 90, 'carbs': 15, 'protein': 3, 'fat': 3},
      },
      {
        'title': 'Riz au gras au poisson',
        'ageGroup': '24+ mois',
        'imageUrl': 'assets/images/riz_au_gras.png',
        'ingredients': ['Riz', 'Maquereau fumé', 'Tomate', 'Carotte', 'Oignon'],
        'materials': ['Couteau', 'Casserole'],
        'instructions': [
          'Faites revenir l\'oignon, la tomate et la carotte. Ajoutez le poisson.',
          'Ajoutez l\'eau et le riz. Laissez cuire à feu doux.'
        ],
        'description': 'Une recette de Riz gras au poisson pour un repas complet.',
        'prepTime': 15,
        'cookTime': 20,
        'texture': 'Morceaux',
        'difficulty': 'Moyen',
        'allergens': ['Poisson'],
        'nutrition': {'calories': 250, 'carbs': 30, 'protein': 15, 'fat': 8},
      },
      {
        'title': 'Pain perdus',
        'ageGroup': '24+ mois',
        'imageUrl': 'assets/images/pain_perdu.png',
        'ingredients': ['Pain', 'Œuf', 'Lait', 'Sucre', 'Beurre', 'Cannelle'],
        'materials': ['Bol', 'Poêle'],
        'instructions': [
          'Dans un bol, battez les œufs et ajoutez le sucre, le lait et la cannelle. Trempez le pain.',
          'Faites fondre le beurre dans une poêle et dorez les tranches de pain des deux côtés.'
        ],
        'description': 'Un goûter simple et délicieux, et ça vous évitera de gâcher du pain.',
        'prepTime': 10,
        'cookTime': 5,
        'texture': 'Morceaux',
        'difficulty': 'Facile',
        'allergens': ['Œuf', 'Lait', 'Gluten'],
        'nutrition': {'calories': 200, 'carbs': 25, 'protein': 8, 'fat': 8},
      },
      {
        'title': 'Couscous au poulet',
        'ageGroup': '24+ mois',
        'imageUrl': 'assets/images/couscous_poulet.png',
        'ingredients': ['Couscous', 'Poulet', 'Oignon', 'Courge', 'Carotte', 'Haricots verts', 'Tomate'],
        'materials': ['Couteau', 'Casserole'],
        'instructions': [
          'Faites revenir le poulet et les légumes. Laissez mijoter.',
          'Faites cuire le couscous à la vapeur et mélangez le tout.'
        ],
        'description': 'Un repas fait maison pour votre nourrisson dès 2 ans.',
        'prepTime': 15,
        'cookTime': 20,
        'texture': 'Morceaux',
        'difficulty': 'Moyen',
        'allergens': ['Gluten'],
        'nutrition': {'calories': 220, 'carbs': 25, 'protein': 15, 'fat': 7},
      },
      {
        'title': 'Abolo poisson frit',
        'ageGroup': '24+ mois',
        'imageUrl': 'assets/images/04e.png',
        'ingredients': ['Riz', 'Farine de riz', 'Farine de blé', 'Maïzena', 'Poisson', 'Tomate', 'Oignon'],
        'materials': ['Couteau', 'Casserole', 'Mixeur'],
        'instructions': [
          'Préparez la pâte d\'abolo en mélangeant les farines et en laissant reposer.',
          'Faites cuire la pâte à la vapeur. Préparez une sauce avec le poisson et les légumes.',
          'Servez l\'abolo avec la sauce.'
        ],
        'description': 'Une recette ivoirienne pour un repas équilibré et digeste.',
        'prepTime': 30,
        'cookTime': 30,
        'texture': 'Morceaux',
        'difficulty': 'Difficile',
        'allergens': ['Poisson', 'Gluten'],
        'nutrition': {'calories': 250, 'carbs': 35, 'protein': 10, 'fat': 8},
      },
      {
        'title': 'Sandwich au saucisson grillé',
        'ageGroup': '60+ mois',
        'imageUrl': 'assets/images/sandwich_saucisson.png',
        'ingredients': ['Pain', 'Saucisson', 'Salade', 'Tomate', 'Oignon', 'Fromage', 'Beurre'],
        'materials': ['Couteau', 'Poêle'],
        'instructions': [
          'Dorez les tranches de pain au beurre. Grillez les rondelles de saucisson.',
          'Montez le sandwich en alternant les ingrédients.'
        ],
        'description': 'Une idée de goûter sympathique pour les enfants de 5 ans et plus.',
        'prepTime': 10,
        'cookTime': 5,
        'texture': 'Morceaux',
        'difficulty': 'Facile',
        'allergens': ['Gluten', 'Lait'],
        'nutrition': {'calories': 300, 'carbs': 20, 'protein': 15, 'fat': 18},
      },
      {
        'title': 'Cocktail ananas - mangue',
        'ageGroup': '24+ mois',
        'imageUrl': 'assets/images/06.epng.png',
        'ingredients': ['Ananas', 'Mangue'],
        'materials': ['Mixeur'],
        'instructions': [
          'Mixez les tranches de mangue avec le jus d\'ananas jusqu\'à obtenir une texture lisse.',
          'Conservez au réfrigérateur avant de servir.'
        ],
        'description': 'Un cocktail naturel digne de leur rang !',
        'prepTime': 5,
        'cookTime': 0,
        'texture': 'Liquide',
        'difficulty': 'Facile',
        'allergens': [],
        'nutrition': {'calories': 100, 'carbs': 25, 'protein': 1, 'fat': 0.5},
      },
      {
        'title': 'Dessert Œuf au lait',
        'ageGroup': '12-18 mois',
        'imageUrl': 'assets/images/oeuf_au_lait.png',
        'ingredients': ['Œuf', 'Lait', 'Muscade', 'Sucre vanillé'],
        'materials': ['Bol', 'Casserole'],
        'instructions': [
          'Battez l\'œuf et ajoutez le lait, le sucre et la muscade.',
          'Faites cuire au bain-marie pendant 15-20 min.'
        ],
        'description': 'Un petit dessert gourmand pour les bébés de 12 mois.',
        'prepTime': 10,
        'cookTime': 20,
        'texture': 'Purée',
        'difficulty': 'Moyen',
        'allergens': ['Œuf', 'Lait'],
        'nutrition': {'calories': 150, 'carbs': 15, 'protein': 8, 'fat': 7},
      },
      {
        'title': 'Crêpe de sorgho',
        'ageGroup': '12-18 mois',
        'imageUrl': 'assets/images/crepes_sorgho.png',
        'ingredients': ['Œuf', 'Lait', 'Farine de sorgho', 'Muscade'],
        'materials': ['Bol', 'Poêle'],
        'instructions': [
          'Mélangez l\'œuf, le lait, le sucre et la muscade. Ajoutez la farine et l\'huile.',
          'Laissez reposer. Versez une louche de pâte dans une poêle et faites cuire.'
        ],
        'description': 'Des crêpes originales et délicieuses pour bébé.',
        'prepTime': 15,
        'cookTime': 5,
        'texture': 'Morceaux',
        'difficulty': 'Facile',
        'allergens': ['Œuf', 'Lait'],
        'nutrition': {'calories': 250, 'carbs': 30, 'protein': 8, 'fat': 10},
      },
      {
        'title': 'Jus de pastèque aux agrumes',
        'ageGroup': '12-18 mois',
        'imageUrl': 'assets/images/jus_pasteque.png',
        'ingredients': ['Pastèque', 'Citron', 'Orange'],
        'materials': ['Mixeur'],
        'instructions': [
          'Retirez la chair de la pastèque et mixez-la.',
          'Ajoutez le jus de citron et le jus d\'orange, mélangez et servez.'
        ],
        'description': 'Un jus frais et vitaminé pour bébé.',
        'prepTime': 10,
        'cookTime': 0,
        'texture': 'Liquide',
        'difficulty': 'Facile',
        'allergens': [],
        'nutrition': {'calories': 80, 'carbs': 20, 'protein': 1, 'fat': 0.2},
      },
      {
        'title': 'Jus de carotte',
        'ageGroup': '12-18 mois',
        'imageUrl': 'assets/images/04c.png',
        'ingredients': ['Clémentine', 'Carotte'],
        'materials': ['Mixeur'],
        'instructions': [
          'Épluchez la carotte et la clémentine. Mixez les deux avec de l\'eau.',
          'Filtrez, ajoutez le sucre et servez.'
        ],
        'description': 'Un jus de carotte et d\'orange pour faire le plein de vitamines.',
        'prepTime': 10,
        'cookTime': 0,
        'texture': 'Liquide',
        'difficulty': 'Facile',
        'allergens': [],
        'nutrition': {'calories': 90, 'carbs': 22, 'protein': 1, 'fat': 0.3},
      },
      {
        'title': 'Bouillie de riz – banane au miel',
        'ageGroup': '12-18 mois',
        'imageUrl': 'assets/images/bouillie_banane.png',
        'ingredients': ['Riz', 'Banane', 'Miel'],
        'materials': ['Casserole', 'Mixeur'],
        'instructions': [
          'Faites cuire le riz. Faites cuire la banane à la vapeur et mixez-la.',
          'Mélangez la compote de banane à la bouillie de riz. Ajoutez le miel.'
        ],
        'description': 'Une recette spéciale prise de poids à base de riz, banane et miel.',
        'prepTime': 15,
        'cookTime': 20,
        'texture': 'Bouillie',
        'difficulty': 'Moyen',
        'allergens': [],
        'nutrition': {'calories': 200, 'carbs': 40, 'protein': 4, 'fat': 2},
      },
      {
        'title': 'Attieke viande hachée',
        'ageGroup': '12-18 mois',
        'imageUrl': 'assets/images/06c.png',
        'ingredients': ['Attiéké', 'Viande hachée', 'Oignon', 'Carotte', 'Persil', 'Ciboulette', 'Tomate', 'Sel', 'Poivre'],
        'materials': ['Couteau', 'Casserole'],
        'instructions': [
          'Faites revenir la viande et l\'oignon. Ajoutez les autres légumes et assaisonnez.',
          'Ajoutez l\'eau et l\'attiéké. Laissez cuire jusqu\'à absorption de l\'eau.'
        ],
        'description': 'Un plat complet pour le Ramadan, idéal pour nos bébés de 1 an.',
        'prepTime': 15,
        'cookTime': 15,
        'texture': 'Morceaux',
        'difficulty': 'Moyen',
        'allergens': [],
        'nutrition': {'calories': 250, 'carbs': 25, 'protein': 15, 'fat': 10},
      },
      {
        'title': 'Sauté de légumes au poulet',
        'ageGroup': '12-18 mois',
        'imageUrl': 'assets/images/07c.png',
        'ingredients': ['Pomme de terre', 'Carotte', 'Poulet'],
        'materials': ['Couteau', 'Casserole', 'Poêle'],
        'instructions': [
          'Cuisez les légumes et le poulet dans l\'eau avec le sel.',
          'Égouttez les légumes et faites-les sauter au beurre. Faites frire le poulet pané.'
        ],
        'description': 'Un plat simple à réaliser pour nos bébés de 1 an.',
        'prepTime': 15,
        'cookTime': 20,
        'texture': 'Morceaux',
        'difficulty': 'Moyen',
        'allergens': [],
        'nutrition': {'calories': 200, 'carbs': 20, 'protein': 15, 'fat': 8},
      },
      {
        'title': 'Placali sauce gombo et poisson',
        'ageGroup': '12-18 mois',
        'imageUrl': 'assets/images/08c.png',
        'ingredients': ['Gombo', 'Manioc', 'Tomate', 'Oignon', 'Poisson fumé'],
        'materials': ['Couteau', 'Casserole'],
        'instructions': [
          'Préparez le placali en délayant la pâte de manioc dans l\'eau.',
          'Dans une autre casserole, préparez la sauce avec le gombo, l\'oignon, la tomate et le poisson.',
          'Servez la sauce avec le placali.'
        ],
        'description': 'Une spécialité ivoirienne pour bébé, idéale dès 12 mois.',
        'prepTime': 20,
        'cookTime': 20,
        'texture': 'Morceaux',
        'difficulty': 'Difficile',
        'allergens': ['Poisson'],
        'nutrition': {'calories': 280, 'carbs': 35, 'protein': 10, 'fat': 12},
      },
      {
        'title': 'Bouillie de mil au tamarin (chat noir)',
        'ageGroup': '12-18 mois',
        'imageUrl': 'assets/images/09c.png',
        'ingredients': ['Mil', 'Tamarin noir', 'Sucre'],
        'materials': ['Casserole'],
        'instructions': [
          'Faites bouillir l\'eau et ajoutez les perles de mil. Laissez cuire.',
          'Incorporez le jus de tamarin et le sucre.'
        ],
        'description': 'Une bouillie pour faire goûter le tamarin à nos adorables bébés de 1 an.',
        'prepTime': 10,
        'cookTime': 15,
        'texture': 'Bouillie',
        'difficulty': 'Facile',
        'allergens': [],
        'nutrition': {'calories': 170, 'carbs': 35, 'protein': 4, 'fat': 1},
      },
      {
        'title': 'Spaghetti et viande hachée',
        'ageGroup': '12-18 mois',
        'imageUrl': 'assets/images/10c.png',
        'ingredients': ['Spaghetti', 'Viande hachée', 'Oignon', 'Carotte', 'Ail', 'Tomate'],
        'materials': ['Casserole', 'Poêle'],
        'instructions': [
          'Faites cuire les spaghettis. Faites revenir la viande et les légumes.',
          'Ajoutez les spaghettis à la sauce et mélangez.'
        ],
        'description': 'Un plat qui ravira les bébés de 12 mois.',
        'prepTime': 15,
        'cookTime': 20,
        'texture': 'Morceaux',
        'difficulty': 'Moyen',
        'allergens': ['Gluten'],
        'nutrition': {'calories': 250, 'carbs': 30, 'protein': 15, 'fat': 8},
      },
      {
        'title': 'Omelette pomme de terre et courge et ciboulette',
        'ageGroup': '12-18 mois',
        'imageUrl': 'assets/images/11c.png',
        'ingredients': ['Pomme de terre', 'Courge', 'Ciboulette', 'Œuf', 'Sel', 'Poivre'],
        'materials': ['Couteau', 'Casserole', 'Poêle'],
        'instructions': [
          'Faites cuire les légumes. Égouttez-les.',
          'Dans un bol, mélangez l\'œuf battu avec les légumes et la ciboulette.',
          'Faites frire l\'omelette dans une poêle.'
        ],
        'description': 'Une délicieuse petite recette pour le petit-déjeuner de bébé.',
        'prepTime': 10,
        'cookTime': 10,
        'texture': 'Morceaux',
        'difficulty': 'Facile',
        'allergens': ['Œuf'],
        'nutrition': {'calories': 180, 'carbs': 12, 'protein': 8, 'fat': 10},
      },
      {
        'title': 'Bouillie d’avoine et banane et miel et lait',
        'ageGroup': '12-18 mois',
        'imageUrl': 'assets/images/12c.png',
        'ingredients': ['Flocons d’avoine', 'Banane', 'Miel', 'Lait'],
        'materials': ['Casserole'],
        'instructions': [
          'Faites cuire les flocons d\'avoine dans l\'eau. Écrasez la banane et ajoutez-la.',
          'Ajoutez le miel et le lait avant de servir.'
        ],
        'description': 'Une recette spéciale prise de poids, adaptée dès 12 mois.',
        'prepTime': 10,
        'cookTime': 10,
        'texture': 'Bouillie',
        'difficulty': 'Facile',
        'allergens': ['Lait'],
        'nutrition': {'calories': 250, 'carbs': 40, 'protein': 6, 'fat': 6},
      },
      {
        'title': 'Baignet de mil ou Gnomis',
        'ageGroup': '12-18 mois',
        'imageUrl': 'assets/images/13c.png',
        'ingredients': ['Riz', 'Farine de mil', 'Farine de blé', 'Banane', 'Sucre', 'Levure', 'Muscade'],
        'materials': ['Bol', 'Poêle'],
        'instructions': [
          'Faites cuire une bouillie de riz épaisse. Laissez tiédir.',
          'Mélangez la bouillie de riz avec les farines, la purée de banane, le sucre et les épices.',
          'Laissez reposer la pâte puis faites frire les galettes.'
        ],
        'description': 'Un goûter simple que vous pouvez faire à la maison pour nos adorables bébés.',
        'prepTime': 20,
        'cookTime': 10,
        'texture': 'Morceaux',
        'difficulty': 'Difficile',
        'allergens': ['Gluten'],
        'nutrition': {'calories': 350, 'carbs': 50, 'protein': 8, 'fat': 12},
      },
      {
        'title': 'Cookies de noël',
        'ageGroup': '15-18 mois',
        'imageUrl': 'assets/images/14c.png',
        'ingredients': ['Farine de blé', 'Sucre', 'Beurre', 'Œufs'],
        'materials': ['Saladier', 'Four'],
        'instructions': [
          'Mélangez les jaunes d\'œufs et le sucre, puis ajoutez la farine, le beurre et le sel.',
          'Malaxez la pâte, découpez les formes et badigeonnez avec un jaune d\'œuf.',
          'Faites cuire au four.'
        ],
        'description': 'Des cookies pour le plaisir de nos bout\'chous, dès 15 mois.',
        'prepTime': 20,
        'cookTime': 25,
        'texture': 'Morceaux',
        'difficulty': 'Moyen',
        'allergens': ['Œuf', 'Gluten', 'Lait'],
        'nutrition': {'calories': 400, 'carbs': 45, 'protein': 8, 'fat': 20},
      },
      {
        'title': 'Couscous aux légumes et poulet',
        'ageGroup': '8-12 mois',
        'imageUrl': 'assets/images/couscous_poulet_legumes.png',
        'ingredients': ['Couscous', 'Poulet', 'Navet', 'Courgette', 'Courge', 'Oignon', 'Curry'],
        'materials': ['Couteau', 'Casserole'],
        'instructions': [
          'Faites revenir l\'oignon et le poulet. Ajoutez les légumes, le couscous et le curry.',
          'Ajoutez l\'eau et laissez cuire. Écrasez légèrement à la fourchette.'
        ],
        'description': 'Un repas original pour nos bébés de 8 mois.',
        'prepTime': 15,
        'cookTime': 20,
        'texture': 'Mixte',
        'difficulty': 'Moyen',
        'allergens': ['Gluten'],
        'nutrition': {'calories': 200, 'carbs': 25, 'protein': 10, 'fat': 7},
      },
      {
        'title': 'Purée de riz à l’œuf et persil',
        'ageGroup': '8-12 mois',
        'imageUrl': 'assets/images/puree_riz_oeuf.png',
        'ingredients': ['Riz', 'Œuf', 'Persil', 'Beurre'],
        'materials': ['Casserole'],
        'instructions': [
          'Faites cuire le riz avec l\'eau et le persil.',
          'Ajoutez le beurre, puis l\'œuf dur écrasé à la fourchette.'
        ],
        'description': 'Une délicieuse purée de riz à l\'œuf et au persil pour bébé.',
        'prepTime': 10,
        'cookTime': 15,
        'texture': 'Mixte',
        'difficulty': 'Facile',
        'allergens': ['Œuf', 'Lait'],
        'nutrition': {'calories': 180, 'carbs': 20, 'protein': 8, 'fat': 6},
      },
      {
        'title': 'Purée d’igname - poisson',
        'ageGroup': '9-12 mois',
        'imageUrl': 'assets/images/05a.png',
        'ingredients': ['Igname', 'Poisson fumé', 'Tomate', 'Oignon'],
        'materials': ['Couteau', 'Casserole'],
        'instructions': [
          'Faites revenir l\'oignon et la tomate. Ajoutez le poisson.',
          'Faites cuire l\'igname et écrasez le tout à la fourchette.'
        ],
        'description': 'Une recette délicieuse à base d\'igname pour bébé.',
        'prepTime': 15,
        'cookTime': 20,
        'texture': 'Morceaux',
        'difficulty': 'Moyen',
        'allergens': ['Poisson'],
        'nutrition': {'calories': 150, 'carbs': 20, 'protein': 8, 'fat': 4},
      },
      {
        'title': 'Purée de lentilles aux légumes',
        'ageGroup': '8-12 mois',
        'imageUrl': 'assets/images/puree_lentilles.png',
        'ingredients': ['Lentilles', 'Carotte', 'Oignon', 'Tomate', 'Curry'],
        'materials': ['Casserole', 'Mixeur'],
        'instructions': [
          'Faites cuire les lentilles. Faites revenir les légumes avec le coulis de tomate.',
          'Ajoutez les lentilles cuites et le curry, puis mixez.'
        ],
        'description': 'Une purée de lentilles aux légumes idéale pour un déjeuner riche en protéines.',
        'prepTime': 15,
        'cookTime': 20,
        'texture': 'Mixte',
        'difficulty': 'Moyen',
        'allergens': [],
        'nutrition': {'calories': 180, 'carbs': 25, 'protein': 10, 'fat': 5},
      },
      {
        'title': 'Vermicelle de riz au poulet',
        'ageGroup': '8-12 mois',
        'imageUrl': 'assets/images/15a.png',
        'ingredients': ['Vermicelles de riz', 'Poulet', 'Oignon', 'Carotte', 'Céleri', 'Curry'],
        'materials': ['Casserole'],
        'instructions': [
          'Faites revenir l\'oignon, le poulet et la carotte. Ajoutez les épices et l\'eau.',
          'Laissez cuire, puis ajoutez les vermicelles.'
        ],
        'description': 'Une délicieuse vermicelle de riz au poulet idéale pour un déjeuner riche en protéines.',
        'prepTime': 15,
        'cookTime': 15,
        'texture': 'Morceaux',
        'difficulty': 'Moyen',
        'allergens': [],
        'nutrition': {'calories': 190, 'carbs': 25, 'protein': 12, 'fat': 4},
      },
      {
        'title': 'Purée de courge – pomme de terre et poulet',
        'ageGroup': '8-12 mois',
        'imageUrl': 'assets/images/16a.png',
        'ingredients': ['Courge', 'Pomme de terre', 'Poulet', 'Echalote'],
        'materials': ['Casserole', 'Mixeur'],
        'instructions': [
          'Faites revenir l\'échalote et le poulet. Ajoutez les légumes et l\'eau.',
          'Faites cuire, puis écrasez ou mixez pour obtenir la texture souhaitée.'
        ],
        'description': 'Une purée qui fera frémir les papilles de bébé.',
        'prepTime': 10,
        'cookTime': 15,
        'texture': 'Mixte',
        'difficulty': 'Facile',
        'allergens': [],
        'nutrition': {'calories': 170, 'carbs': 18, 'protein': 10, 'fat': 6},
      },
      {
        'title': 'Purée de platain et agneau',
        'ageGroup': '8-12 mois',
        'imageUrl': 'assets/images/17.apng.png',
        'ingredients': ['Banane plantain', 'Agneau', 'Courgette', 'Tomate', 'Echalote'],
        'materials': ['Couteau', 'Casserole'],
        'instructions': [
          'Faites revenir les dés d\'échalote, de tomate et d\'agneau.',
          'Ajoutez la banane plantain, la courgette et l\'eau. Laissez cuire.',
          'Écrasez à la fourchette pour obtenir une purée avec des grumeaux.'
        ],
        'description': 'Une recette pour nos bébés de 8 mois qui se régaleront à la fête de tabaski.',
        'prepTime': 15,
        'cookTime': 20,
        'texture': 'Mixte',
        'difficulty': 'Moyen',
        'allergens': [],
        'nutrition': {'calories': 220, 'carbs': 20, 'protein': 12, 'fat': 10},
      },
      {
        'title': 'Petites pâtes – coulis de tomate et fromage',
        'ageGroup': '9-12 mois',
        'imageUrl': 'assets/images/18a.png',
        'ingredients': ['Pâtes', 'Tomate', 'Fromage', 'Persil', 'Echalotte'],
        'materials': ['Casserole'],
        'instructions': [
          'Faites cuire les pâtes. Préparez le coulis de tomate.',
          'Faites revenir l\'échalote, ajoutez le coulis et le persil.',
          'Ajoutez les pâtes et le fromage et mélangez.'
        ],
        'description': 'Une recette délicieuse pour le plaisir de nos bébés de 9 mois.',
        'prepTime': 15,
        'cookTime': 15,
        'texture': 'Mixte',
        'difficulty': 'Moyen',
        'allergens': ['Lait'],
        'nutrition': {'calories': 200, 'carbs': 25, 'protein': 8, 'fat': 8},
      },
      {
        'title': 'Riz aux légumes – œuf',
        'ageGroup': '9-12 mois',
        'imageUrl': 'assets/images/19a.png',
        'ingredients': ['Riz', 'Œuf', 'Courge', 'Courgette', 'Oignon', 'Carotte'],
        'materials': ['Casserole'],
        'instructions': [
          'Faites revenir les légumes. Ajoutez l\'eau et laissez cuire.',
          'Ajoutez le riz cuit et l\'œuf bouilli et le sel.'
        ],
        'description': 'Une délicieuse recette pour nos petits chous !',
        'prepTime': 15,
        'cookTime': 15,
        'texture': 'Mixte',
        'difficulty': 'Moyen',
        'allergens': ['Œuf'],
        'nutrition': {'calories': 220, 'carbs': 28, 'protein': 10, 'fat': 7},
      },
      {
        'title': 'Bouillie de flocons d’avoine',
        'ageGroup': '9-12 mois',
        'imageUrl': 'assets/images/20a.png',
        'ingredients': ['Flocons d’avoine', 'Œuf', 'Lait'],
        'materials': ['Casserole'],
        'instructions': [
          'Faites cuire les flocons d\'avoine dans l\'eau.',
          'Ajoutez l\'œuf en fin de cuisson et mélangez. Ajoutez le lait avant de servir.'
        ],
        'description': 'Une bouillie de flocons d’avoine agrémentée d’œuf pour le plaisir de nos bébés.',
        'prepTime': 5,
        'cookTime': 10,
        'texture': 'Bouillie',
        'difficulty': 'Facile',
        'allergens': ['Œuf', 'Lait'],
        'nutrition': {'calories': 180, 'carbs': 20, 'protein': 8, 'fat': 7},
      },
      {
        'title': 'Vermicelle au maquereau',
        'ageGroup': '9-12 mois',
        'imageUrl': 'assets/images/21a.png',
        'ingredients': ['Oignon', 'Carotte', 'Tomate', 'Maquereau', 'Vermicelles'],
        'materials': ['Casserole'],
        'instructions': [
          'Faites revenir les légumes. Ajoutez le maquereau, l\'eau et le sel.',
          'Laissez cuire, puis ajoutez les vermicelles.'
        ],
        'description': 'Une recette à tester pour nos boud\'chous: les vermicelles au maquereau.',
        'prepTime': 15,
        'cookTime': 20,
        'texture': 'Morceaux',
        'difficulty': 'Moyen',
        'allergens': ['Poisson'],
        'nutrition': {'calories': 200, 'carbs': 25, 'protein': 12, 'fat': 6},
      },
      // RECETTES MANQUANTES AJOUTÉES
      {
        'title': 'Bouillie de riz',
        'ageGroup': '6-8 mois',
        'imageUrl': 'assets/images/16m.png',
        'ingredients': ['Farine de riz', 'Beurre', 'Lait', 'Eau'],
        'materials': ['Bol', 'Casserole'],
        'instructions': [
          'Diluez la farine de riz dans l\'eau, en écrasant les grumeaux.',
          'Versez dans une casserole et portez à ébullition pendant 5 à 8 minutes en mélangeant jusqu\'à épaississement.',
          'Retirez du feu, ajoutez le beurre et le lait, puis mélangez.'
        ],
        'description': 'Une délicieuse et simple recette à base de riz pour bébé.',
        'prepTime': 5,
        'cookTime': 8,
        'texture': 'Bouillie',
        'difficulty': 'Facile',
        'allergens': ['Lait'],
        'nutrition': {'calories': 140, 'carbs': 22, 'protein': 3, 'fat': 4},
      },
      {
        'title': 'Compote mangue – chat noir',
        'ageGroup': '6-8 mois',
        'imageUrl': 'assets/images/22m.png',
        'ingredients': ['Mangue', 'Tamarin noir', 'Eau'],
        'materials': ['Couteau', 'Casserole', 'Mixeur'],
        'instructions': [
          'Décortiquez les "chats noirs" (tamarin) et trempez-les dans l\'eau chaude pendant 1 minute.',
          'Mélangez pour recueillir le jus, puis filtrez.',
          'Épluchez et coupez la mangue en morceaux.',
          'Faites cuire la mangue avec le jus de tamarin à feu doux pendant 10-15 minutes.',
          'Mixez pour obtenir un mélange lisse.'
        ],
        'description': 'Une compote avec un goût acidulé qui éveille les papilles de bébé.',
        'prepTime': 15,
        'cookTime': 15,
        'texture': 'Purée',
        'difficulty': 'Facile',
        'allergens': [],
        'nutrition': {'calories': 90, 'carbs': 22, 'protein': 1, 'fat': 0.5},
      },
      {
        'title': 'Purée de riz - carotte',
        'ageGroup': '8-12 mois',
        'imageUrl': 'assets/images/07a.png',
        'ingredients': ['Riz', 'Carotte', 'Beurre'],
        'materials': ['Couteau', 'Casserole', 'Mixeur'],
        'instructions': [
          'Lavez le riz. Épluchez et coupez la carotte en petits dés.',
          'Mettez le riz et la carotte dans une casserole avec 350 ml d’eau et portez à ébullition.',
          'Laissez bien cuire, puis écrasez à la fourchette ou mixez.',
          'Ajoutez le beurre et mélangez avant de servir.'
        ],
        'description': 'Une délicieuse purée de riz à la carotte pour bébé.',
        'prepTime': 10,
        'cookTime': 20,
        'texture': 'Mixte',
        'difficulty': 'Facile',
        'allergens': ['Lait'],
        'nutrition': {'calories': 150, 'carbs': 25, 'protein': 3, 'fat': 4},
      },
      {
        'title': 'Purée de riz - carotte – poulet - ciboulette',
        'ageGroup': '9-12 mois',
        'imageUrl': 'assets/images/08a.png',
        'ingredients': ['Riz', 'Carotte', 'Poulet', 'Ciboulette', 'Huile végétale', 'Sel', 'Poivre', 'Eau'],
        'materials': ['Couteau', 'Casserole'],
        'instructions': [
          'Coupez la carotte, la ciboulette et le poulet.',
          'Faites dorer le poulet dans l\'huile, puis ajoutez la carotte et la ciboulette.',
          'Ajoutez le riz, mélangez jusqu\'à ce qu\'il soit translucide, puis ajoutez l\'eau.',
          'Laissez mijoter à feu doux jusqu\'à ce que le riz soit pâteux.'
        ],
        'description': 'Un plat complet et savoureux pour les bébés plus grands.',
        'prepTime': 15,
        'cookTime': 25,
        'texture': 'Morceaux',
        'difficulty': 'Moyen',
        'allergens': [],
        'nutrition': {'calories': 210, 'carbs': 28, 'protein': 12, 'fat': 5},
      },
      {
        'title': 'Petites pâtes en sauce tomate',
        'ageGroup': '9-12 mois',
        'imageUrl': 'assets/images/10a.png',
        'ingredients': ['Pâtes', 'Tomates', 'Echalotte', 'Huile végétale'],
        'materials': ['Couteau', 'Casserole'],
        'instructions': [
          'Faites cuire les pâtes. Faites cuire les tomates et réduisez-les en coulis.',
          'Faites revenir l\'échalote dans l\'huile, ajoutez le coulis de tomate et laissez mijoter.',
          'Ajoutez les pâtes égouttées et mélangez.'
        ],
        'description': 'Une belle découverte que nos petits aimeront à coup sûr.',
        'prepTime': 10,
        'cookTime': 15,
        'texture': 'Morceaux',
        'difficulty': 'Facile',
        'allergens': ['Gluten'],
        'nutrition': {'calories': 180, 'carbs': 30, 'protein': 5, 'fat': 4},
      },
      {
        'title': 'Bouillie au tapioca – lait de coco et mangue',
        'ageGroup': '8-12 mois',
        'imageUrl': 'assets/images/11a.png',
        'ingredients': ['Lait de coco', 'Tapioca', 'Compote de mangue', 'Eau'],
        'materials': ['Casserole'],
        'instructions': [
          'Faites bouillir l\'eau et ajoutez le tapioca. Cuire 5 minutes jusqu\'à ce qu\'il soit translucide.',
          'Ajoutez le lait de coco et laissez la bouillie s\'épaissir en mélangeant.',
          'Incorporez la compote de mangue et retirez du feu.'
        ],
        'description': 'Une bouillie exotique et douce pour le plaisir de bébé.',
        'prepTime': 5,
        'cookTime': 10,
        'texture': 'Bouillie',
        'difficulty': 'Facile',
        'allergens': [],
        'nutrition': {'calories': 220, 'carbs': 35, 'protein': 3, 'fat': 8},
      },
      {
        'title': 'Mouliné de carotte – pomme de terre et semoule de blé',
        'ageGroup': '8-12 mois',
        'imageUrl': 'assets/images/12a.png',
        'ingredients': ['Carotte', 'Pomme de terre', 'Semoule de blé', 'Lait'],
        'materials': ['Casserole', 'Mixeur'],
        'instructions': [
          'Faites cuire la semoule de blé selon les instructions et réservez.',
          'Faites cuire la carotte et la pomme de terre à la vapeur pendant 10-15 minutes.',
          'Mixez les légumes avec la semoule, le lait et un peu d\'eau de cuisson pour obtenir la texture désirée.'
        ],
        'description': 'Un délicieux mouliné pour le dîner de bébé.',
        'prepTime': 15,
        'cookTime': 15,
        'texture': 'Mixte',
        'difficulty': 'Moyen',
        'allergens': ['Gluten', 'Lait'],
        'nutrition': {'calories': 170, 'carbs': 28, 'protein': 5, 'fat': 4},
      },
      {
        'title': 'Vermicelles au lait',
        'ageGroup': '8-12 mois',
        'imageUrl': 'assets/images/13a.png',
        'ingredients': ['Vermicelles', 'Lait', 'Eau'],
        'materials': ['Casserole'],
        'instructions': [
          'Faites bouillir l\'eau, ajoutez les vermicelles et laissez cuire 10 minutes.',
          'Retirez du feu, ajoutez le lait et mélangez bien avant de servir.'
        ],
        'description': 'Les vermicelles ne se mangent pas que salés ! Une douceur pour toute la famille.',
        'prepTime': 5,
        'cookTime': 10,
        'texture': 'Mixte',
        'difficulty': 'Facile',
        'allergens': ['Gluten', 'Lait'],
        'nutrition': {'calories': 160, 'carbs': 25, 'protein': 6, 'fat': 4},
      },
      {
        'title': 'Petites pâtes au fromages et persil',
        'ageGroup': '9-12 mois',
        'imageUrl': 'assets/images/pates_fromage.png',
        'ingredients': ['Pâtes', 'Beurre', 'Fromage', 'Persil', 'Sel'],
        'materials': ['Casserole'],
        'instructions': [
          'Faites cuire les pâtes jusqu\'à ce qu\'elles soient fondantes. Égouttez.',
          'Remettez-les dans la casserole sur feu doux.',
          'Ajoutez le beurre, le sel, le fromage et le persil haché.',
          'Remuez jusqu\'à ce que le fromage fonde et servez.'
        ],
        'description': 'Miam Miam ! Des pâtes au fromage pour le plaisir de bébé.',
        'prepTime': 10,
        'cookTime': 10,
        'texture': 'Morceaux',
        'difficulty': 'Facile',
        'allergens': ['Gluten', 'Lait'],
        'nutrition': {'calories': 220, 'carbs': 28, 'protein': 8, 'fat': 8},
      },
      {
        'title': 'Bouillie d’avoine – œuf',
        'ageGroup': '8-12 mois',
        'imageUrl': 'assets/images/04a.png',
        'ingredients': ['Œuf', 'Flocons d\'avoine', 'Eau', 'Lait'],
        'materials': ['Casserole'],
        'instructions': [
          'Faites cuire les flocons d\'avoine dans l\'eau pendant 7-10 minutes.',
          'Cassez l\'œuf et ajoutez-le directement à la bouillie sur le feu.',
          'Mélangez vigoureusement pour incorporer l\'œuf et laissez cuire une minute de plus.',
          'Servez avec le lait.'
        ],
        'description': 'Une bouillie riche qui fera prendre du poids à bébé.',
        'prepTime': 5,
        'cookTime': 12,
        'texture': 'Bouillie',
        'difficulty': 'Facile',
        'allergens': ['Œuf', 'Lait'],
        'nutrition': {'calories': 200, 'carbs': 22, 'protein': 10, 'fat': 8},
      },
    ];

    final collectionRef = FirebaseFirestore.instance.collection('recipes');
    final batch = FirebaseFirestore.instance.batch();

    for (var recipeData in recipes) {
      final newDocRef = collectionRef.doc();
      batch.set(newDocRef, {
        ...recipeData,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();

    scaffoldMessenger.showSnackBar(
      const SnackBar(
        content: Text('✅ Les recettes initiales ont été ajoutées avec succès !'),
        backgroundColor: Colors.green,
      ),
    );
  } catch (e) {
    print('❌ Erreur lors de l\'ajout des recettes: $e');
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text('Erreur lors de l\'ajout des recettes: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}