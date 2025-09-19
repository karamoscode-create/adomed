// lib/screens/consultation/consultation_screen.dart

import 'package:flutter/material.dart';
import 'package:adomed_app/theme/app_theme.dart';
import 'package:adomed_app/screens/consultation/medecin_list_screen.dart';

class ConsultationScreen extends StatefulWidget {
  const ConsultationScreen({super.key});

  @override
  State<ConsultationScreen> createState() => _ConsultationScreenState();
}

class _ConsultationScreenState extends State<ConsultationScreen> {
  // ===== MODIFICATION : Liste des spécialités mise à jour et triée par ordre alphabétique =====
  final List<Map<String, String>> specialities = [
    {'name': 'Cardiologue', 'image_path': 'assets/images/services/cardiologue.png'},
    {'name': 'Chirurgie pédiatrique', 'image_path': 'assets/images/services/generaliste.png'}, // Image à remplacer
    {'name': 'Dentiste', 'image_path': 'assets/images/services/dentiste.png'},
    {'name': 'Dermatologue', 'image_path': 'assets/images/services/dermatologue.png'},
    {'name': 'Diététicien Nutritionniste', 'image_path': 'assets/images/services/generaliste.png'}, // Image à remplacer
    {'name': 'Endocrinologue', 'image_path': 'assets/images/services/endocrinologue.png'},
    {'name': 'Gastro-entérologue', 'image_path': 'assets/images/services/gastro.png'},
    {'name': 'Généraliste', 'image_path': 'assets/images/services/generaliste.png'},
    {'name': 'Gériatre', 'image_path': 'assets/images/services/generaliste.png'}, // Image à remplacer
    {'name': 'Gynécologue', 'image_path': 'assets/images/services/gynecologue.png'},
    {'name': 'Médecin de sport', 'image_path': 'assets/images/services/generaliste.png'}, // Image à remplacer
    {'name': 'Médecin du travail / Expert médico-légal', 'image_path': 'assets/images/services/generaliste.png'}, // Image à remplacer
    {'name': 'Néphrologue', 'image_path': 'assets/images/services/generaliste.png'}, // Image à remplacer
    {'name': 'Neurochirurgien', 'image_path': 'assets/images/services/generaliste.png'}, // Image à remplacer
    {'name': 'Neurologue', 'image_path': 'assets/images/services/neurologue.png'},
    {'name': 'Oncologue', 'image_path': 'assets/images/services/generaliste.png'}, // Image à remplacer
    {'name': 'Ophtalmologiste', 'image_path': 'assets/images/services/ophtalmo.png'}, // Nom mis à jour
    {'name': 'ORL', 'image_path': 'assets/images/services/generaliste.png'}, // Image à remplacer
    {'name': 'Orthopédiste-Traumatologue', 'image_path': 'assets/images/services/orthopediste.png'}, // Nom mis à jour
    {'name': 'Orthophoniste', 'image_path': 'assets/images/services/generaliste.png'}, // Image à remplacer
    {'name': 'Pédiatre', 'image_path': 'assets/images/services/pediatre.png'},
    {'name': 'Pneumologue - Allergologue', 'image_path': 'assets/images/services/pneumologue.png'}, // Nom mis à jour
    {'name': 'Proctologue', 'image_path': 'assets/images/services/generaliste.png'}, // Image à remplacer
    {'name': 'Psychiatre', 'image_path': 'assets/images/services/generaliste.png'}, // Image à remplacer
    {'name': 'Psychologue', 'image_path': 'assets/images/services/psychologue.png'},
    {'name': 'Radiologue', 'image_path': 'assets/images/services/radiologue.png'},
    {'name': 'Rhumatologue', 'image_path': 'assets/images/services/rhumatologue.png'},
    {'name': 'Santé publique', 'image_path': 'assets/images/services/generaliste.png'}, // Image à remplacer
    {'name': 'Sexologue', 'image_path': 'assets/images/services/generaliste.png'}, // Image à remplacer
    {'name': 'Urologue', 'image_path': 'assets/images/services/urologue.png'},
  ];

  @override
  Widget build(BuildContext context) {
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
                              'Consulter un médecin',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimaryColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 48),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Choisissez une spécialité",
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 16),
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 1.0,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                ),
                                itemCount: specialities.length,
                                itemBuilder: (context, index) {
                                  return Card(
                                    clipBehavior: Clip.antiAlias,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 5,
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => MedecinListScreen(speciality: specialities[index]['name']!),
                                          ),
                                        );
                                      },
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          Image.asset(
                                            specialities[index]['image_path']!,
                                            fit: BoxFit.cover,
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Colors.black.withOpacity(0.50),
                                            ),
                                          ),
                                          Center(
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text(
                                                specialities[index]['name']!,
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18,
                                                  shadows: [
                                                    Shadow(
                                                      blurRadius: 4.0,
                                                      color: Colors.black54,
                                                      offset: Offset(2.0, 2.0),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
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
}