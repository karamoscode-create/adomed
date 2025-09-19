// lib/screens/suivi_medical/reminder_screen.dart

import 'package:flutter/material.dart';
import 'package:adomed_app/theme/app_theme.dart';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  TimeOfDay? _selectedTime;

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Programmer un rappel'),
        backgroundColor: AppColors.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Programmez une alarme pour ne pas oublier votre prochaine mesure.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 32),
            Card(
              child: InkWell(
                onTap: _selectTime,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(Icons.alarm, size: 40, color: AppColors.primary),
                      Text(
                        _selectedTime?.format(context) ?? 'Choisir une heure',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _selectedTime == null ? null : () {
                // NOTE : La logique pour programmer la notification réelle n'est pas implémentée.
                // Cela nécessite une configuration plus avancée du package flutter_local_notifications.
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Rappel programmé pour ${_selectedTime!.format(context)} ! (Ceci est une simulation)')),
                );
                Navigator.pop(context);
              },
              child: const Text('Enregistrer le rappel'),
            ),
          ],
        ),
      ),
    );
  }
}