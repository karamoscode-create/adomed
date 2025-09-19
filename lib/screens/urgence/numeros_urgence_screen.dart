// lib/screens/urgence/numeros_urgence_screen.dart
import 'package:flutter/material.dart';
import 'package:adomed_app/theme/app_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyContact {
  final IconData icon;
  final String title;
  final String number;
  final String? note;
  EmergencyContact({required this.icon, required this.title, required this.number, this.note});
}

class NumerosUrgencesScreen extends StatefulWidget {
  const NumerosUrgencesScreen({super.key});

  @override
  State<NumerosUrgencesScreen> createState() => _NumerosUrgencesScreenState();
}

class _NumerosUrgencesScreenState extends State<NumerosUrgencesScreen> {
  late Future<List<EmergencyContact>> _emergencyNumbersFuture;

  // La liste complète des numéros reste inchangée
  final Map<String, List<EmergencyContact>> _countryEmergencyNumbers = {
    'Algérie': [
      EmergencyContact(icon: Icons.local_police_outlined, title: "Police", number: "17"),
      EmergencyContact(icon: Icons.local_fire_department_outlined, title: "Pompiers", number: "14"),
      EmergencyContact(icon: Icons.medical_services_outlined, title: "SAMU", number: "16"),
      EmergencyContact(icon: Icons.local_hospital_outlined, title: "Assistance médicale", number: "115"),
    ],
    'Égypte': [
      EmergencyContact(icon: Icons.local_police_outlined, title: "Police", number: "122"),
      EmergencyContact(icon: Icons.local_fire_department_outlined, title: "Pompiers", number: "180"),
      EmergencyContact(icon: Icons.local_hospital_outlined, title: "Ambulance", number: "123"),
    ],
    'Maroc': [
      EmergencyContact(icon: Icons.local_police_outlined, title: "Police", number: "19"),
      EmergencyContact(icon: Icons.local_fire_department_outlined, title: "Protection Civile (Pompiers)", number: "15"),
      EmergencyContact(icon: Icons.local_hospital_outlined, title: "SAMU (grandes villes)", number: "141"),
    ],
    'Tunisie': [
      EmergencyContact(icon: Icons.local_police_outlined, title: "Police de secours", number: "197"),
      EmergencyContact(icon: Icons.local_fire_department_outlined, title: "Pompier", number: "198"),
      EmergencyContact(icon: Icons.medical_services_outlined, title: "SAMU (secours médicaux)", number: "190"),
    ],
    'Djibouti': [
      EmergencyContact(icon: Icons.local_hospital_outlined, title: "Ambulance", number: "19"),
      EmergencyContact(icon: Icons.local_police_outlined, title: "Police", number: "17"),
      EmergencyContact(icon: Icons.local_fire_department_outlined, title: "Pompiers", number: "18"),
    ],
    'Éthiopie': [
      EmergencyContact(icon: Icons.local_hospital_outlined, title: "Ambulance", number: "92"),
      EmergencyContact(icon: Icons.local_police_outlined, title: "Police", number: "91"),
      EmergencyContact(icon: Icons.local_fire_department_outlined, title: "Pompiers", number: "93"),
    ],
    'Kenya': [
      EmergencyContact(icon: Icons.emergency_outlined, title: "Toutes les urgences", number: "999"),
    ],
    'Madagascar': [
      EmergencyContact(icon: Icons.local_hospital_outlined, title: "Ambulance", number: "124"),
      EmergencyContact(icon: Icons.local_police_outlined, title: "Police", number: "117"),
      EmergencyContact(icon: Icons.local_fire_department_outlined, title: "Pompiers", number: "118"),
      EmergencyContact(icon: Icons.directions_car_outlined, title: "Accidents de circulation", number: "3600"),
    ],
    'Malawi': [
      EmergencyContact(icon: Icons.local_hospital_outlined, title: "Ambulance", number: "998"),
      EmergencyContact(icon: Icons.local_police_outlined, title: "Police", number: "997"),
      EmergencyContact(icon: Icons.local_fire_department_outlined, title: "Pompiers", number: "999"),
    ],
    'Mozambique': [
      EmergencyContact(icon: Icons.local_hospital_outlined, title: "Ambulance", number: "117"),
      EmergencyContact(icon: Icons.local_police_outlined, title: "Police", number: "119"),
      EmergencyContact(icon: Icons.local_fire_department_outlined, title: "Pompiers", number: "198"),
    ],
    'Rwanda': [
      EmergencyContact(icon: Icons.local_hospital_outlined, title: "Ambulance", number: "912"),
      EmergencyContact(icon: Icons.emergency_outlined, title: "Police et Pompiers", number: "112"),
    ],
    'Somalie': [
      EmergencyContact(icon: Icons.local_hospital_outlined, title: "Ambulance", number: "999", note: "Numéros peuvent être non fiables."),
      EmergencyContact(icon: Icons.local_police_outlined, title: "Police", number: "888", note: "Numéros peuvent être non fiables."),
      EmergencyContact(icon: Icons.local_fire_department_outlined, title: "Pompiers", number: "555", note: "Numéros peuvent être non fiables."),
    ],
    'Soudan du Sud': [
      EmergencyContact(icon: Icons.local_police_outlined, title: "Police", number: "777", note: "Joignable uniquement à Juba."),
    ],
    'Tanzanie': [
      EmergencyContact(icon: Icons.local_hospital_outlined, title: "Ambulance", number: "115", note: "Les numéros peuvent ne pas être fiables. Essayez les numéros locaux."),
      EmergencyContact(icon: Icons.local_police_outlined, title: "Police", number: "112", note: "Les numéros peuvent ne pas être fiables. Essayez les numéros locaux."),
      EmergencyContact(icon: Icons.local_fire_department_outlined, title: "Pompiers", number: "114", note: "Les numéros peuvent ne pas être fiables. Essayez les numéros locaux."),
    ],
    'Ouganda': [
      EmergencyContact(icon: Icons.local_police_outlined, title: "Police", number: "999"),
    ],
    'Zambie': [
      EmergencyContact(icon: Icons.emergency_outlined, title: "Toutes les urgences", number: "999"),
    ],
    'Zimbabwe': [
      EmergencyContact(icon: Icons.local_hospital_outlined, title: "Ambulance", number: "994"),
      EmergencyContact(icon: Icons.local_police_outlined, title: "Police", number: "777-777"),
      EmergencyContact(icon: Icons.local_fire_department_outlined, title: "Pompiers", number: "993"),
    ],
    'Angola': [
      EmergencyContact(icon: Icons.local_hospital_outlined, title: "Ambulance", number: "112"),
      EmergencyContact(icon: Icons.local_police_outlined, title: "Police", number: "113"),
      EmergencyContact(icon: Icons.local_fire_department_outlined, title: "Pompiers", number: "115"),
    ],
    'Cameroun': [
      EmergencyContact(icon: Icons.local_hospital_outlined, title: "Ambulance", number: "112"),
      EmergencyContact(icon: Icons.local_police_outlined, title: "Police", number: "117"),
      EmergencyContact(icon: Icons.local_fire_department_outlined, title: "Pompiers", number: "118"),
      EmergencyContact(icon: Icons.medication_outlined, title: "SAMU", number: "119"),
    ],
    'République centrafricaine': [
      EmergencyContact(icon: Icons.emergency_outlined, title: "Toutes les urgences", number: "117"),
    ],
    'Tchad': [
      EmergencyContact(icon: Icons.local_police_outlined, title: "Police", number: "17", note: "Numéros peuvent être non fiables."),
      EmergencyContact(icon: Icons.local_fire_department_outlined, title: "Pompiers", number: "18", note: "Numéros peuvent être non fiables."),
    ],
    'République démocratique du Congo': [
      EmergencyContact(icon: Icons.warning_amber_outlined, title: "Aucun service disponible", number: "N/A"),
    ],
    'République du Congo': [
      EmergencyContact(icon: Icons.emergency_outlined, title: "Toutes les urgences", number: "112", note: "Délai de réponse long."),
    ],
    'Bénin': [
      EmergencyContact(icon: Icons.local_police_outlined, title: "Police", number: "117"),
      EmergencyContact(icon: Icons.local_fire_department_outlined, title: "Pompiers", number: "118"),
      EmergencyContact(icon: Icons.emergency_outlined, title: "Secours urgents", number: "911"),
    ],
    'Burkina Faso': [
      EmergencyContact(icon: Icons.local_police_outlined, title: "Police Nationale", number: "17"),
      EmergencyContact(icon: Icons.local_fire_department_outlined, title: "Sapeurs Pompiers", number: "18"),
      EmergencyContact(icon: Icons.medical_services_outlined, title: "Urgence Médicale", number: "112"),
    ],
    'Gambie': [
      EmergencyContact(icon: Icons.local_hospital_outlined, title: "Ambulance", number: "116", note: "Équipes manquent souvent de ressources."),
      EmergencyContact(icon: Icons.local_police_outlined, title: "Police", number: "117"),
      EmergencyContact(icon: Icons.local_fire_department_outlined, title: "Pompiers", number: "118"),
    ],
    'Ghana': [
      EmergencyContact(icon: Icons.local_hospital_outlined, title: "Ambulance", number: "193"),
      EmergencyContact(icon: Icons.local_police_outlined, title: "Police", number: "191"),
      EmergencyContact(icon: Icons.local_fire_department_outlined, title: "Pompiers", number: "192"),
    ],
    'Guinée': [
      EmergencyContact(icon: Icons.local_police_outlined, title: "Gendarmerie Nationale", number: "122", note: "Numéro de Conakry."),
    ],
    'Guinée-Bissau': [
      EmergencyContact(icon: Icons.local_hospital_outlined, title: "Ambulance", number: "119"),
      EmergencyContact(icon: Icons.local_police_outlined, title: "Police", number: "121"),
      EmergencyContact(icon: Icons.local_fire_department_outlined, title: "Pompiers", number: "180"),
    ],
    'Côte d\'Ivoire': [
      EmergencyContact(icon: Icons.local_police_outlined, title: "Police", number: "170"),
      EmergencyContact(icon: Icons.local_fire_department_outlined, title: "Pompiers", number: "180"),
      EmergencyContact(icon: Icons.medical_services_outlined, title: "SAMU", number: "185"),
      EmergencyContact(icon: Icons.message_outlined, title: "SOS Médecin", number: "0322445353"),
      EmergencyContact(icon: Icons.electrical_services_outlined, title: "CIE (Électricité)", number: "179"),
      EmergencyContact(icon: Icons.water_drop_outlined, title: "SODECI (Eau)", number: "175"),
    ],
    'Libéria': [
      EmergencyContact(icon: Icons.emergency_outlined, title: "Toutes les urgences", number: "911", note: "Numéro peu fiable."),
    ],
    'Mali': [
      EmergencyContact(icon: Icons.local_hospital_outlined, title: "Ambulance", number: "15"),
      EmergencyContact(icon: Icons.local_police_outlined, title: "Police", number: "17"),
      EmergencyContact(icon: Icons.local_fire_department_outlined, title: "Pompiers", number: "18"),
    ],
    'Mauritanie': [
      EmergencyContact(icon: Icons.local_hospital_outlined, title: "Ambulance", number: "118", note: "Délai de réponse long."),
      EmergencyContact(icon: Icons.local_police_outlined, title: "Police", number: "117"),
      EmergencyContact(icon: Icons.security_outlined, title: "Gendarmerie", number: "116"),
      EmergencyContact(icon: Icons.emergency_outlined, title: "Accidents de circulation", number: "117"),
    ],
    'Niger': [
      EmergencyContact(icon: Icons.local_police_outlined, title: "Police", number: "17"),
      EmergencyContact(icon: Icons.local_fire_department_outlined, title: "Ambulance et Pompiers", number: "18"),
    ],
    'Nigéria': [
      EmergencyContact(icon: Icons.emergency_outlined, title: "Ambulance et Police", number: "199"),
    ],
    'Sénégal': [
      EmergencyContact(icon: Icons.local_police_outlined, title: "Police", number: "17"),
      EmergencyContact(icon: Icons.local_fire_department_outlined, title: "Ambulance et Pompiers", number: "18"),
    ],
    'Sierra Leone': [
      EmergencyContact(icon: Icons.emergency_outlined, title: "Ambulance et Police", number: "999"),
      EmergencyContact(icon: Icons.local_fire_department_outlined, title: "Pompiers", number: "019"),
    ],
    'Togo': [
      EmergencyContact(icon: Icons.local_police_outlined, title: "Police", number: "117"),
    ],
    'Canada': [
      EmergencyContact(icon: Icons.emergency_outlined, title: "Police de secours", number: "911"),
    ],
    'États-Unis': [
      EmergencyContact(icon: Icons.emergency_outlined, title: "Police de secours", number: "911"),
    ],
    'Haïti': [
      EmergencyContact(icon: Icons.local_police_outlined, title: "Police", number: "114"),
      EmergencyContact(icon: Icons.local_fire_department_outlined, title: "Pompiers", number: "115"),
      EmergencyContact(icon: Icons.medical_services_outlined, title: "Croix rouge", number: "118"),
    ],
    'France': [
      EmergencyContact(icon: Icons.local_police_outlined, title: "Police secours", number: "17"),
      EmergencyContact(icon: Icons.medical_services_outlined, title: "SAMU", number: "15"),
      EmergencyContact(icon: Icons.local_fire_department_outlined, title: "Sapeurs-pompiers", number: "18"),
      EmergencyContact(icon: Icons.emergency_outlined, title: "Numéro d'urgence Européen", number: "112"),
    ],
  };

  @override
  void initState() {
    super.initState();
    _emergencyNumbersFuture = _fetchUserCountryAndNumbers();
  }

  Future<List<EmergencyContact>> _fetchUserCountryAndNumbers() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return _countryEmergencyNumbers['Côte d\'Ivoire']!;
    }
    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final userData = userDoc.data();
      final String userCountry = userData?['country'] ?? 'Côte d\'Ivoire';
      return _countryEmergencyNumbers[userCountry] ?? _countryEmergencyNumbers['Côte d\'Ivoire']!;
    } catch (e) {
      debugPrint('Error fetching user country: $e');
      return _countryEmergencyNumbers['Côte d\'Ivoire']!;
    }
  }
  
  Future<void> _launchCaller(String number) async {
    final Uri url = Uri(scheme: 'tel', path: number);
    if (!await launchUrl(url)) {
      if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Impossible de lancer l\'appel au $number')),
        );
      }
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
                      padding: const EdgeInsets.fromLTRB(4, 20, 16, 10),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimaryColor),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          const Expanded(
                            child: Text(
                              "Numéros d'urgence",
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

                    // Contenu principal
                    Expanded(
                      child: FutureBuilder<List<EmergencyContact>>(
                        future: _emergencyNumbersFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Center(child: Text("Impossible de charger les numéros d'urgence."));
                          }
                          final contacts = snapshot.data!;
                          return ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                            itemCount: contacts.length,
                            itemBuilder: (context, index) {
                              final contact = contacts[index];
                              return _buildEmergencyTile(
                                context,
                                icon: contact.icon,
                                title: contact.title,
                                number: contact.number,
                                color: Theme.of(context).colorScheme.primary,
                                note: contact.note,
                              );
                            },
                            separatorBuilder: (context, index) => const Divider(indent: 16, endIndent: 16),
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

  Widget _buildEmergencyTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String number,
    required Color color,
    String? note,
  }) {
    return ListTile(
      leading: Icon(icon, color: color, size: 30),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            number,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (note != null)
            Text(
              note,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.red.shade700,
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
      trailing: const Icon(Icons.phone_forwarded_outlined, color: AppColors.primary),
      onTap: () => _launchCaller(number),
    );
  }
}