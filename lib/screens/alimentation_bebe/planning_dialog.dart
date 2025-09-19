// lib/screens/alimentation_bebe/planning_dialog.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'recipe_model.dart';

class PlanningSelectionDialog extends StatefulWidget {
  final Recipe recipe;

  const PlanningSelectionDialog({super.key, required this.recipe});

  @override
  State<PlanningSelectionDialog> createState() => _PlanningSelectionDialogState();
}

class _PlanningSelectionDialogState extends State<PlanningSelectionDialog> {
  final List<String> daysOfWeek = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
  final List<String> mealTimes = ['Petit-déjeuner', 'Déjeuner', 'Goûter', 'Dîner'];
  String _selectedDay = 'Lundi';
  String _selectedMealTime = 'Déjeuner';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ajouter au planning',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            'Recette : ${widget.recipe.title}',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          const Text('Choisissez un jour :'),
          DropdownButton<String>(
            value: _selectedDay,
            isExpanded: true,
            items: daysOfWeek.map((String day) {
              return DropdownMenuItem<String>(
                value: day,
                child: Text(day),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedDay = newValue;
                });
              }
            },
          ),
          const SizedBox(height: 16),
          const Text('Choisissez un repas :'),
          DropdownButton<String>(
            value: _selectedMealTime,
            isExpanded: true,
            items: mealTimes.map((String meal) {
              return DropdownMenuItem<String>(
                value: meal,
                child: Text(meal),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedMealTime = newValue;
                });
              }
            },
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  _saveToPlanning(context, widget.recipe, _selectedDay, _selectedMealTime);
                  Navigator.pop(context);
                },
                child: const Text('Ajouter'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // === MODIFICATION : Ajout de la gestion de la date d'expiration ===
  Future<void> _saveToPlanning(BuildContext context, Recipe recipe, String day, String mealTime) async {
    final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final planningDocRef = FirebaseFirestore.instance.collection('plannings').doc(currentUserId);

    try {
      final batch = FirebaseFirestore.instance.batch();

      // On ajoute ou remplace la recette pour ce jour et ce repas
      batch.set(
        planningDocRef.collection('weekly_planning').doc('$day-$mealTime'),
        {
          'recipeId': recipe.id,
          'day': day,
          'mealTime': mealTime,
          'addedAt': FieldValue.serverTimestamp(),
        }
      );

      // Si c'est le premier ajout manuel, on définit la date d'expiration
      final planningDoc = await planningDocRef.get();
      if (!planningDoc.exists) {
        final expiryDate = DateTime.now().add(const Duration(days: 7));
        batch.set(planningDocRef, {'expiresAt': Timestamp.fromDate(expiryDate)});
      }
      
      await batch.commit();

      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ ${recipe.title} a été ajouté à votre planning !'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erreur lors de l\'ajout au planning: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}