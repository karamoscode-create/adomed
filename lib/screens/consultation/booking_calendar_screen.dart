// lib/screens/consultation/booking_calendar_screen.dart
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'booking_summary_screen.dart';

// NOUVEAUTÉ : La liste des symptômes est maintenant organisée par spécialité.
const Map<String, List<String>> symptomesParSpecialite = {
  'Généraliste': [
    'Anorexie (Perte d’appétit)', 'Fatigue persistante', 'Fièvre', 'Insomnie',
    'Nausées/Vomissements', 'Perte de connaissances', 'Soif excessive', 'Toux',
    'Rhume (nez)', 'Maux de gorge', 'Frilosité'
  ],
  'Cardiologue': [
    'Cœur rapide', 'Douleur à la poitrine', 'Essoufflement', 'Gonflement du corps (Œdèmes)',
    'Sensation de vertige/Étourdissement', 'Cyanose (Coloration bleue de la peau)', 'Sueurs nocturnes'
  ],
  'Dentiste': [
    'Douleur dentaire', 'Saignement des gencives', 'Mauvaise haleine'
  ],
  'Dermatologue': [
    'Bouton sur la peau', 'Chute de cheveux anormale (Alopécie)', 'Démangeaisons',
    'Peau sèche et irritée', 'Taches sur la peau', 'Rougeurs de la peau'
  ],
  'Gastro-entérologue': [
    'Ballonnement au ventre', 'Constipation', 'Diarrhée', 'Digestion difficile',
    'Douleur au ventre', 'Émission de sang dans les selles', 'Gaz dans le ventre (Flatulence)',
    'Nausées/Vomissements', 'Vomissement de sang', 'Ictère (yeux jaunes)'
  ],
  'Gynécologue': [
    'Aménorrhée (Absence de règles)', 'Douleurs pendant les rapports', 'Écoulement vaginal/urétral',
    'Fertilité (désir de maternité)', 'Règles douloureuses', 'Règles abondantes',
    'Écoulement de lait dans les seins', 'Vaginite'
  ],
  'Neurologue': [
    'Céphalées (Maux de tête persistants)', 'Convulsions', 'Difficulté à parler',
    'Fourmillements au corps', 'Mouvements anormaux', 'Perte de connaissances',
    'Sensation de vertige/Étourdissement', 'Tremblements', 'Troubles de la mémoire',
    'Trouble du langage', 'Troubles de l’équilibre'
  ],
  'Ophtalmologiste': [
    'Baisse de la vision', 'Douleur à l’œil', 'Troubles de la vision', 'Vision floue',
    'Yeux rouges', 'Sensibilité à la lumière'
  ],
  'Orthopédiste-Traumatologue': [
    'Douleurs musculaires', 'Raideur articulaire', 'Lombalgie (Douleur lombaire)'
  ],
  'Pédiatre': [
    'Fièvre', 'Toux', 'Diarrhée', 'Vomissements', 'Éruption cutanée', 'Difficulté à respirer'
  ],
  'Pneumologue - Allergologue': [
    'Crachats sanglants (Hémoptysie)', 'Difficulté à respirer', 'Essoufflement',
    'Respiration rapide', 'Toux'
  ],
  'Psychologue': [
    'Insomnie', 'Manque de concentration', 'Troubles de la mémoire', 'Anxiété'
  ],
  'Rhumatologue': [
    'Douleurs musculaires', 'Raideur articulaire', 'Lombalgie (Douleur lombaire)'
  ],
  'Urologue': [
    'Absence d’urine', 'Besoins urinaires nocturnes', 'Diminution des urines',
    'Difficulté à uriner', 'Incontinence urinaire/fécale', 'Problème d’urine',
    'Sang dans les urines', 'Trouble de l’érection'
  ],
  'ORL': [
    'Baisse de l’audition', 'Écoulement auriculaire (Oreille)', 'Saignement de nez',
    'Rhume (nez)', 'Maux de gorge', 'Sensation de vertige/Étourdissement'
  ],
};


class BookingCalendarScreen extends StatefulWidget {
  final Map<String, dynamic> medecin;

  const BookingCalendarScreen({super.key, required this.medecin});

  @override
  State<BookingCalendarScreen> createState() => _BookingCalendarScreenState();
}

class _BookingCalendarScreenState extends State<BookingCalendarScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  String? _selectedHour;
  String? _selectedSymptom;

  // NOUVEAUTÉ : Une liste qui sera remplie dynamiquement
  late List<String> _symptomListForSpecialty;

  final List<String> _availableHours = [
    '07:00', '08:00', '09:00', '10:00', '11:00', '12:00',
    '14:00', '15:00', '16:00', '17:00', '18:00', '19:00'
  ];

  @override
  void initState() {
    super.initState();
    // NOUVEAUTÉ : On remplit la liste des symptômes au démarrage de l'écran
    String specialty = widget.medecin['speciality'] ?? 'Généraliste';
    // On cherche la liste pour le spécialiste, sinon on prend celle du généraliste par défaut.
    _symptomListForSpecialty = symptomesParSpecialite[specialty] ?? symptomesParSpecialite['Généraliste']!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choisir une date'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // MODIFICATION : Le Dropdown utilise maintenant la liste filtrée
                DropdownButtonFormField<String>(
                  value: _selectedSymptom,
                  hint: const Text('Motif de la consultation'),
                  isExpanded: true,
                  items: _symptomListForSpecialty.map((String value) { // Utilise la nouvelle liste
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                  onChanged: (newValue) => setState(() => _selectedSymptom = newValue),
                  validator: (value) => value == null ? 'Veuillez choisir un motif' : null,
                  decoration: const InputDecoration(
                    labelText: "Symptôme principal",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(),
                TableCalendar(
                  locale: 'fr_FR',
                  firstDay: DateTime.now(),
                  lastDay: DateTime.now().add(const Duration(days: 30)),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selected, focused) {
                    setState(() {
                      _selectedDay = selected;
                      _focusedDay = focused;
                      _selectedHour = null;
                    });
                  },
                  calendarStyle: CalendarStyle(
                    selectedDecoration: const BoxDecoration(
                      color: Color(0xFF1E9BBA),
                      shape: BoxShape.circle,
                    ),
                    todayDecoration: BoxDecoration(
                      color: const Color(0xFF1E9BBA).withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                  ),
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                  ),
                ),
                const Divider(),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Choisissez votre horaire',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                GridView.count(
                  crossAxisCount: 4,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: _availableHours.map((hour) {
                    final isSelected = _selectedHour == hour;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedHour = hour),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF1E9BBA)
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          hour,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _selectedHour != null && _selectedSymptom != null
          ? FloatingActionButton.extended(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BookingSummaryScreen(
                        medecin: widget.medecin,
                        date: _selectedDay,
                        hour: _selectedHour!,
                        symptom: _selectedSymptom!,
                      ),
                    ),
                  );
                }
              },
              label: const Text('Continuer'),
              backgroundColor: const Color(0xFF1E9BBA),
            )
          : null,
    );
  }
}