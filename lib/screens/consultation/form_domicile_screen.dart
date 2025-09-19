import 'package:flutter/material.dart'; // <-- CORRECT
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // Pour formater la date

class FormDomicileScreen extends StatefulWidget {
  const FormDomicileScreen({super.key});

  @override
  State<FormDomicileScreen> createState() => _FormDomicileScreenState();
}

class _FormDomicileScreenState extends State<FormDomicileScreen> {
  // Les variables pour le formulaire Stepper restent les mêmes
  int _currentStep = 0;
  final bool _isLoading = false;
  final _formKeys = [GlobalKey<FormState>(), GlobalKey<FormState>(), GlobalKey<FormState>()];
  final _nomController = TextEditingController();
  String? _selectedService;

  @override
  void dispose() {
    _nomController.dispose();
    super.dispose();
  }

  // La logique de soumission reste la même
  Future<void> _submitAppointment() async {
    // ... (votre code de soumission existant)
  }

  // Widget pour afficher une ligne dans l'historique
  Widget _buildHistoryTile(Map<String, dynamic> appointmentData) {
    final title = appointmentData['title'] ?? 'Rendez-vous';
    final status = appointmentData['status'] ?? 'Inconnu';
    final timestamp = appointmentData['date'] as Timestamp?;
    final date = timestamp != null ? DateFormat('dd/MM/yyyy à HH:mm', 'fr_FR').format(timestamp.toDate()) : 'Date inconnue';

    IconData icon;
    Color color;

    switch (status) {
      case 'En attente':
        icon = Icons.hourglass_top_outlined;
        color = Colors.orange;
        break;
      case 'Validé':
        icon = Icons.check_circle_outline;
        color = Colors.green;
        break;
      case 'Terminé':
        icon = Icons.lock_outline;
        color = Colors.grey;
        break;
      default:
        icon = Icons.help_outline;
        color = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title),
        subtitle: Text('Statut: $status\nLe $date'),
        isThreeLine: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text("Veuillez vous connecter.")));
    }

    const services = ['Prise de sang', 'Injection', 'Pansement', 'Suivi de tension', 'Autre'];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Consultation à Domicile"),
      ),
      // ✅ MODIFIÉ : On utilise un StreamBuilder pour lire les demandes en temps réel
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('appointments')
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text("Erreur de chargement des données."));
          }

          final appointments = snapshot.data?.docs ?? [];
          // ✅ Vérifie s'il y a une demande en attente
          final hasPendingAppointment = appointments.any((doc) => doc['status'] == 'En attente');

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ Affiche soit le formulaire, soit un message d'information
                if (hasPendingAppointment)
                  Card(
                    color: Colors.orange.shade50,
                    child: const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.orange),
                          SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              "Vous avez déjà une demande en attente. Vous pourrez faire une nouvelle demande une fois celle-ci traitée.",
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Stepper(
                    // Le code de votre Stepper reste ici, inchangé
                    type: StepperType.vertical,
                    currentStep: _currentStep,
                    onStepContinue: () {
                      if (_formKeys[_currentStep].currentState!.validate()) {
                        if (_currentStep < 2) {
                          setState(() => _currentStep += 1);
                        } else {
                          _submitAppointment();
                        }
                      }
                    },
                    onStepCancel: () {
                      if (_currentStep > 0) {
                        setState(() => _currentStep -= 1);
                      }
                    },
                    controlsBuilder: (context, details) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: _isLoading 
                          ? const Center(child: CircularProgressIndicator())
                          : Row(
                              children: [
                                ElevatedButton(
                                  onPressed: details.onStepContinue,
                                  child: Text(_currentStep == 2 ? 'Valider' : 'Suivant'),
                                ),
                                if (_currentStep > 0)
                                  TextButton(
                                    onPressed: details.onStepCancel,
                                    child: const Text('Retour'),
                                  ),
                              ],
                            ),
                      );
                    },
                    steps: [
                      Step(
                        title: const Text('Informations Personnelles'),
                        content: Form(
                          key: _formKeys[0],
                          child: TextFormField(
                            controller: _nomController,
                            decoration: const InputDecoration(labelText: 'Nom complet'),
                            validator: (value) => value == null || value.isEmpty ? 'Ce champ est requis' : null,
                          ),
                        ),
                        isActive: _currentStep >= 0,
                      ),
                      Step(
                        title: const Text('Détails de la Consultation'),
                        content: Form(
                          key: _formKeys[1],
                          child: DropdownButtonFormField<String>(
                            initialValue: _selectedService,
                            items: services.map((String service) {
                              return DropdownMenuItem<String>(
                                value: service,
                                child: Text(service),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedService = newValue;
                              });
                            },
                            decoration: const InputDecoration(labelText: "Service d'intervention"),
                            validator: (value) => value == null ? 'Veuillez choisir un service' : null,
                          ),
                        ),
                        isActive: _currentStep >= 1,
                      ),
                      Step(
                        title: const Text('Récapitulatif et Validation'),
                        content: Form(
                          key: _formKeys[2],
                          child: const Center(
                            child: Text('Veuillez vérifier vos informations avant de valider.'),
                          ),
                        ),
                        isActive: _currentStep >= 2,
                      ),
                    ],
                  ),

                const SizedBox(height: 24),
                // ✅ Affiche la section historique si des demandes existent
                if (appointments.isNotEmpty) ...[
                  Text("Historique de mes demandes", style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: appointments.length,
                    itemBuilder: (context, index) {
                      final appointmentData = appointments[index].data() as Map<String, dynamic>;
                      return _buildHistoryTile(appointmentData);
                    },
                  ),
                ]
              ],
            ),
          );
        },
      ),
    );
  }
}