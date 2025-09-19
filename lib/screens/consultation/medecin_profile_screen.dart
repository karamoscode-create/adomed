import 'package:flutter/material.dart';
import 'package:adomed_app/theme/app_theme.dart';
import 'booking_calendar_screen.dart';
import '../call/call_screen.dart';

class MedecinProfileScreen extends StatelessWidget {
  final Map<String, dynamic> medecin;

  const MedecinProfileScreen({super.key, required this.medecin});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(medecin['name'] ?? 'Profil du Médecin'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ... (Section Photo + Nom, restylée avec le thème)
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: medecin['photo'] != null
                        ? ClipOval(child: Image.network(medecin['photo'], fit: BoxFit.cover, width: 100, height: 100,))
                        : const Icon(Icons.person, size: 50, color: AppColors.primary),
                  ),
                  const SizedBox(height: 16),
                  Text(medecin['name'] ?? 'N/A', style: Theme.of(context).textTheme.headlineSmall),
                  Text(medecin['speciality'] ?? 'N/A', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primary)),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // ... (Infos, Présentation, Jours, restylés avec le thème)
            
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CallScreen())),
                // ✅ Le style des boutons est hérité ou défini pour correspondre au thème
                child: const Text('Appeler maintenant'),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BookingCalendarScreen(medecin: medecin))),
                child: const Text('Programmer l\'appel'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}