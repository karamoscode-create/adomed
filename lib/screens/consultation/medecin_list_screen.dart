import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:adomed_app/theme/app_theme.dart';

// NOUVEAU : La carte des symptômes par spécialité est maintenant ici.
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


class MedecinListScreen extends StatefulWidget {
  final String speciality;
  const MedecinListScreen({super.key, required this.speciality});

  @override
  State<MedecinListScreen> createState() => _MedecinListScreenState();
}

class _MedecinListScreenState extends State<MedecinListScreen> {
  String? _selectedSymptom;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String? _selectedHour;
  String? _selectedMode;

  // NOUVEAU : La liste des symptômes à afficher, qui sera initialisée.
  late List<String> _symptomsForDisplay;
  
  // SUPPRIMÉ : L'ancienne longue liste statique a été enlevée.
  // final List<String> signesEtSymptomes = [ ... ];

  final List<String> _hours = [ '08:00', '08:30', '09:00', '09:30', '10:00', '10:30', '11:00', '11:30', '14:00', '14:30', '15:00', '15:30', '16:00'];

  @override
  void initState() {
    super.initState();
    // NOUVEAU : Au démarrage de l'écran, on sélectionne la bonne liste de symptômes
    // en fonction de la spécialité reçue. Si la spécialité n'est pas trouvée,
    // on utilise la liste du Généraliste par défaut.
    _symptomsForDisplay = symptomesParSpecialite[widget.speciality] ?? symptomesParSpecialite['Généraliste']!;
  }

  void _sendWhatsAppMessage() async {
    const phoneNumber = '2250704044643';

    if (_selectedSymptom == null ||
        _selectedDay == null ||
        _selectedHour == null ||
        _selectedMode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez remplir tous les champs.')));
      return;
    }

    final formattedDate = DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(_selectedDay!);
    final message = "Bonjour, j'aimerais prendre un rendez-vous.\n\n"
        "Spécialité: ${widget.speciality}\n" // NOUVEAU : Ajout de la spécialité au message
        "Motif: $_selectedSymptom\n"
        "Mode: $_selectedMode\n"
        "Date: $formattedDate\n"
        "Heure: $_selectedHour\n\n"
        "Merci.";
    
    final Uri whatsappUrl = Uri.parse(
        'whatsapp://send?phone=$phoneNumber&text=${Uri.encodeComponent(message)}');

    try {
      if (!await launchUrl(whatsappUrl)) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Impossible de lancer WhatsApp. Est-elle installée ?')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Une erreur est survenue: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isFormComplete = _selectedSymptom != null && _selectedDay != null && _selectedHour != null && _selectedMode != null;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
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
                color: AppTheme.cardColor.withOpacity(0.85),
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
                          Expanded(
                            child: Text(
                              // MODIFIÉ : Le titre inclut maintenant la spécialité
                              'Rendez-vous - ${widget.speciality}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
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
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          children: [
                            _buildSectionCard(
                              title: 'Quel est le motif de votre consultation ?',
                              icon: Icons.medical_services_outlined,
                              child: _buildSymptomSelector(),
                            ),
                            _buildSectionCard(
                              title: 'Choisissez une date',
                              icon: Icons.calendar_today_outlined,
                              child: _buildCalendar(),
                            ),
                            _buildSectionCard(
                              title: 'Sélectionnez une heure',
                              icon: Icons.access_time_outlined,
                              child: _buildTimeSlots(),
                            ),
                            _buildSectionCard(
                              title: 'Comment souhaitez-vous consulter ?',
                              icon: Icons.settings_remote_outlined,
                              child: _buildConsultationModePicker(),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                      child: InkWell(
                        onTap: isFormComplete ? _sendWhatsAppMessage : null,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: isFormComplete ? AppColors.primaryGradient : null,
                            color: isFormComplete ? null : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: isFormComplete ? [
                                BoxShadow(
                                    color: AppColors.primary.withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                )
                            ] : null,
                          ),
                          child: const Center(
                            child: Text(
                              'Confirmer le rendez-vous',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
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

  Widget _buildSectionCard({required String title, required IconData icon, required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 5)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimaryColor)),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildSymptomSelector() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Sélectionnez un symptôme',
        filled: true,
        fillColor: AppTheme.backgroundColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      value: _selectedSymptom,
      isExpanded: true,
      // MODIFIÉ : On utilise la nouvelle liste de symptômes filtrée
      items: _symptomsForDisplay.map((symptom) {
        return DropdownMenuItem<String>(value: symptom, child: Text(symptom, overflow: TextOverflow.ellipsis));
      }).toList(),
      onChanged: (newValue) { setState(() { _selectedSymptom = newValue; }); },
    );
  }
  
  Widget _buildCalendar() {
    return TableCalendar(
      locale: 'fr_FR',
      focusedDay: _focusedDay,
      firstDay: DateTime.now(),
      lastDay: DateTime.now().add(const Duration(days: 90)),
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      onDaySelected: (selectedDay, focusedDay) { setState(() { _selectedDay = selectedDay; _focusedDay = focusedDay; }); },
      headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true, titleTextStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold), leftChevronIcon: Icon(Icons.chevron_left, color: AppTheme.primaryColor), rightChevronIcon: Icon(Icons.chevron_right, color: AppTheme.primaryColor)),
      calendarStyle: CalendarStyle(
        todayDecoration: BoxDecoration(color: AppTheme.primaryLightColor, shape: BoxShape.circle),
        todayTextStyle: const TextStyle(color: AppTheme.primaryColor),
        selectedDecoration: const BoxDecoration(color: AppTheme.primaryColor, shape: BoxShape.circle),
        selectedTextStyle: const TextStyle(color: Colors.white),
      ),
    );
  }
  
  Widget _buildTimeSlots() {
    return Wrap(
      spacing: 12.0,
      runSpacing: 12.0,
      children: _hours.map((hour) {
        final isSelected = _selectedHour == hour;
        return InkWell(
          onTap: () { setState(() { _selectedHour = hour; }); },
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primaryColor : AppTheme.backgroundColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300, width: 1.5),
            ),
            child: Text(hour, style: TextStyle(color: isSelected ? Colors.white : AppTheme.textPrimaryColor, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
          ),
        );
      }).toList(),
    );
  }
  
  Widget _buildConsultationModePicker() {
    return Row(
      children: [
        Expanded(child: _buildModeOption(title: 'À domicile', icon: Icons.home_outlined, isSelected: _selectedMode == 'À domicile', onTap: () => setState(() => _selectedMode = 'À domicile'))),
        const SizedBox(width: 16),
        Expanded(child: _buildModeOption(title: 'En ligne', icon: Icons.videocam_outlined, isSelected: _selectedMode == 'En ligne', onTap: () => setState(() => _selectedMode = 'En ligne'))),
      ],
    );
  }

  Widget _buildModeOption({ required String title, required IconData icon, required bool isSelected, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryLightColor : AppTheme.backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppTheme.primaryColor : Colors.transparent, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondaryColor, size: 30),
            const SizedBox(height: 8),
            Text(title, style: TextStyle(color: isSelected ? AppTheme.primaryColor : AppTheme.textPrimaryColor, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}