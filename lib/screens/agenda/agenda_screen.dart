// lib/screens/agenda/agenda_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:adomed_app/theme/app_theme.dart';
import 'package:iconsax/iconsax.dart';

class Appointment {
  final String title;
  final DateTime date;
  final String status;
  final String type;

  Appointment({
    required this.title,
    required this.date,
    required this.status,
    required this.type,
  });

  factory Appointment.fromMap(Map<String, dynamic> data, String defaultType) {
    return Appointment(
      title: data['title'] ?? data['doctorName'] ?? data['subject'] ?? data['type'] ?? 'Rendez-vous',
      date: (data['date'] as Timestamp).toDate(),
      status: data['status'] ?? 'En attente',
      type: data['type'] ?? defaultType,
    );
  }
}

class AgendaScreen extends StatefulWidget {
  const AgendaScreen({super.key});

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  late Future<List<Appointment>> _appointmentsFuture;

  @override
  void initState() {
    super.initState();
    _appointmentsFuture = _fetchAppointments();
  }

  Future<List<Appointment>> _fetchAppointments() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    List<Appointment> allAppointments = [];

    try {
      // 1. Récupérer les RDV génériques
      final genericAppointmentsSnap = await FirebaseFirestore.instance.collection('users').doc(user.uid).collection('appointments').get();
      allAppointments.addAll(genericAppointmentsSnap.docs.map((doc) => Appointment.fromMap(doc.data(), 'Rendez-vous')));

      // 2. Récupérer les consultations
      final consultationsSnap = await FirebaseFirestore.instance.collection('consultations').where('userId', isEqualTo: user.uid).get();
      allAppointments.addAll(consultationsSnap.docs.map((doc) => Appointment.fromMap(doc.data(), 'Consultation')));

      // 3. Récupérer les demandes d'avis
      final avisSnap = await FirebaseFirestore.instance.collection('demandes_avis').where('userId', isEqualTo: user.uid).get();
      allAppointments.addAll(avisSnap.docs.map((doc) => Appointment.fromMap(doc.data(), 'Avis médical')));
      
      // NOUVEAU : 4. Récupérer les bilans médicaux
      final bilansSnap = await FirebaseFirestore.instance.collection('bilans').where('uid', isEqualTo: user.uid).get();
      allAppointments.addAll(bilansSnap.docs.map((doc) => Appointment.fromMap(doc.data(), 'Bilan Médical')));

      // 5. Trier la liste complète par date
      allAppointments.sort((a, b) => b.date.compareTo(a.date));

    } catch (e) {
      print("Erreur lors de la récupération des rendez-vous: $e");
      return [];
    }

    return allAppointments;
  }

  Map<String, dynamic> _getStyle(Appointment appointment) {
    String status = appointment.status.toLowerCase();
    String type = appointment.type;
    
    // Style par défaut
    var style = {'color': Colors.grey, 'icon': Iconsax.calendar_1};

    // Style par statut
    if (status == 'confirmé' || status == 'validé' || status == 'ok') {
      style = {'color': Colors.green, 'icon': Iconsax.tick_circle};
    } else if (status == 'en attente' || status == 'pending') {
      style = {'color': Colors.orange, 'icon': Iconsax.clock};
    } else if (status == 'annulé') {
      style = {'color': Colors.red, 'icon': Iconsax.close_circle};
    }
    
    // On peut surcharger l'icône par type de RDV
    if (type == 'Bilan Médical') {
      style['icon'] = Iconsax.clipboard_text;
    } else if (type == 'Consultation') {
      style['icon'] = Iconsax.health;
    }

    return style;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Container(decoration: const BoxDecoration(gradient: AppColors.primaryGradient)),
          Padding(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 20),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
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
                            child: Text('Mes rendez-vous', textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimaryColor)),
                          ),
                           // Bouton pour rafraîchir manuellement
                          IconButton(
                            icon: const Icon(Icons.refresh, color: AppTheme.textPrimaryColor),
                            onPressed: () => setState(() => _appointmentsFuture = _fetchAppointments()),
                          )
                        ],
                      ),
                    ),
                    Expanded(
                      child: FutureBuilder<List<Appointment>>(
                        future: _appointmentsFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (snapshot.hasError) {
                            return const Center(child: Text("Une erreur s'est produite."));
                          }
                          
                          final appointments = snapshot.data ?? [];

                          if (appointments.isEmpty) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(20.0),
                                child: Text(
                                  'Vous n\'avez aucun rendez-vous programmé.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey, fontSize: 16),
                                ),
                              ),
                            );
                          }
                          
                          return RefreshIndicator(
                            onRefresh: () {
                              setState(() => _appointmentsFuture = _fetchAppointments());
                              return _appointmentsFuture;
                            },
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: appointments.length,
                              itemBuilder: (context, index) {
                                final appointment = appointments[index];
                                final style = _getStyle(appointment);
                                
                                return Card(
                                  elevation: 2,
                                  margin: const EdgeInsets.only(bottom: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 25,
                                          backgroundColor: (style['color'] as Color).withOpacity(0.1),
                                          child: Icon(style['icon'], color: style['color'], size: 24),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(appointment.title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                                              const SizedBox(height: 4),
                                              Text(DateFormat('dd MMMM yyyy', 'fr_FR').format(appointment.date), style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.secondaryText)),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Chip(
                                          label: Text(
                                            appointment.status,
                                            style: TextStyle(color: style['color'], fontWeight: FontWeight.bold)
                                          ),
                                          backgroundColor: (style['color'] as Color).withOpacity(0.1),
                                          side: BorderSide.none,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
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
}