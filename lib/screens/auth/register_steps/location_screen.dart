// lib/screens/auth/register_steps/location_screen.dart

import 'package:flutter/material.dart';
import 'package:adomed_app/theme/app_theme.dart';
import 'package:country_state_city_picker/country_state_city_picker.dart';
import 'contact_info_screen.dart';

class LocationScreen extends StatefulWidget {
  final String fullName;
  final String dateOfBirth;

  const LocationScreen({
    super.key,
    required this.fullName,
    required this.dateOfBirth,
  });

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  String? countryValue;
  String? cityValue;
  String? stateValue;

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
                              'Inscription (Étape 2/4)',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimaryColor),
                            ),
                          ),
                          const SizedBox(width: 48),
                        ],
                      ),
                    ),

                    // Contenu principal
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Où habitez-vous ?', style: Theme.of(context).textTheme.headlineSmall),
                            const SizedBox(height: 8),
                            Text('Ces informations nous aident à vous localiser en cas d\'urgence.', style: Theme.of(context).textTheme.bodyMedium),
                            const SizedBox(height: 40),

                            // Le widget de sélection de pays/ville
                            SelectState(
                              style: Theme.of(context).textTheme.bodyLarge,
                              onCountryChanged: (value) {
                                setState(() {
                                  countryValue = value;
                                });
                              },
                              onStateChanged:(value) {
                                setState(() {
                                  stateValue = value;
                                });
                              },
                              onCityChanged: (value) {
                                setState(() {
                                  cityValue = value;
                                });
                              },
                            ),
                            
                            const SizedBox(height: 60),

                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: InkWell(
                                onTap: () {
                                  if (countryValue != null && cityValue != null) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ContactInfoScreen(
                                          fullName: widget.fullName,
                                          dateOfBirth: widget.dateOfBirth,
                                          country: countryValue!,
                                          city: cityValue!,
                                        ),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Veuillez sélectionner un pays et une ville.'))
                                    );
                                  }
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: AppColors.primaryGradient,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Center(
                                    child: Text('Continuer', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              ),
                            ),
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
}