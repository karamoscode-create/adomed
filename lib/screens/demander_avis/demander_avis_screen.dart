// lib/screens/demander_avis/demander_avis_screen.dart

import 'package:flutter/material.dart';
import 'package:adomed_app/screens/chat/chat_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:adomed_app/theme/app_theme.dart';
import 'package:intl/intl.dart';

const List<String> signesEtSymptomes = [
  'Absence d’urine', 'Aménorrhée (Absence de règles)', 'Anorexie (Perte d’appétit)',
  'Ballonnement au ventre', 'Baisse de l’audition', 'Besoins urinaires nocturnes',
  'Bouton sur la peau', 'Chute de cheveux anormale (Alopécie)', 'Céphalées (Maux de tête persistants)',
  'Cœur rapide', 'Constipation', 'Convulsions', 'Crachats sanglants (Hémoptysie)',
  'Cyanose (Coloration bleue de la peau)', 'Démangeaisons', 'Diarrhée',
  'Difficulté à parler', 'Difficulté à respirer', 'Digestion difficile',
  'Diminution des urines', 'Difficulté à uriner', 'Douleur à la poitrine',
  'Douleur à l’œil', 'Douleur au ventre', 'Douleur en avalant la nourriture', 'Douleurs musculaires',
  'Douleur nerveuse', 'Douleurs pendant les rapports', 'Écoulement auriculaire (Oreille)',
  'Écoulement vaginal/urétral', 'Envies douloureuses d’aller à la selle', 'Essoufflement',
  'Écoulement de lait dans les seins', 'Émission de sang dans les selles', 'Faim excessive',
  'Fatigue persistante', 'Fertilité (désir de maternité)', 'Fièvre',
  'Fourmillements au corps', 'Gaz dans le ventre (Flatulence excessive)', 'Gonflement du corps (Œdèmes)',
  'Incontinence urinaire/fécale', 'Insomnie', 'Ictère (yeux jaune)',
  'Lombalgie (Douleur lombaire/hanche)', 'Mouvements anormaux', 'Nausées/Vomissements',
  'Perte de connaissances', 'Problème d’urine', 'Raideur articulaire', 'Règles douloureuses',
  'Respiration rapide', 'Rhume (nez)', 'Sang dans les urines', 'Saignement des gencives',
  'Saignement de nez', 'Salivation excessive', 'Sensation de vertige/Étourdissement',
  'Soif excessive', 'Toux', 'Transpiration excessive', 'Tremblements',
  'Troubles de la mémoire', 'Trouble du langage', 'Troubles de la vision',
  'Uriner fréquemment', 'Vomissement de sang', 'Autres symptômes',
];

class DemanderAvisScreen extends StatefulWidget {
  const DemanderAvisScreen({super.key});

  @override
  State<DemanderAvisScreen> createState() => _DemanderAvisScreenState();
}

class _DemanderAvisScreenState extends State<DemanderAvisScreen> {
  bool isPremium = true;
  String? _selectedSubject;
  String? _selectedUrgency;
  final TextEditingController _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _showPrerequisitesForm(BuildContext context, String chatTarget) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (BuildContext context, StateSetter modalSetState) {
          return Form(
            key: _formKey,
            child: Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 16, right: 16, top: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Informations préalables", style: Theme.of(ctx).textTheme.titleLarge),
                  const SizedBox(height: 24),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Symptôme principal', border: OutlineInputBorder()),
                    value: _selectedSubject,
                    isExpanded: true,
                    hint: const Text('Choisissez un symptôme'),
                    items: signesEtSymptomes.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      modalSetState(() => _selectedSubject = newValue);
                    },
                    validator: (value) => value == null ? 'Veuillez choisir un symptôme' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Niveau d\'urgence', border: OutlineInputBorder()),
                    value: _selectedUrgency,
                    hint: const Text('Évaluez l\'urgence'),
                    items: ['Faible', 'Moyen', 'Élevé'].map((String value) {
                      return DropdownMenuItem<String>(value: value, child: Text(value));
                    }).toList(),
                    onChanged: (String? newValue) {
                      modalSetState(() => _selectedUrgency = newValue);
                    },
                    validator: (value) => value == null ? 'Veuillez choisir un niveau d\'urgence' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'Décrivez votre problème (optionnel)', border: OutlineInputBorder()),
                    maxLines: 4,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: InkWell(
                      onTap: () async {
                        if (_formKey.currentState!.validate()) {
                          Navigator.pop(ctx);
                          final userId = FirebaseAuth.instance.currentUser!.uid;
                          await FirebaseFirestore.instance.collection('users').doc(userId).collection('discussions').add({
                            'title': 'Demande pour: $_selectedSubject',
                            'last_updated': Timestamp.now(),
                            'with': chatTarget,
                            'type': 'medecin',
                            'status': 'pending',
                            'request_subject': _selectedSubject,
                            'request_urgency': _selectedUrgency,
                            'request_description': _descriptionController.text,
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Votre demande a été envoyée et est en cours de validation.'),
                              backgroundColor: Colors.green,
                            ),
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
                          child: Text("Envoyer la demande", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showSubscriptionDialog(BuildContext context) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text("Abonnement requis"),
      content: const Text("Veuillez choisir une offre d'abonnement pour discuter directement avec nos médecins certifiés."),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Annuler")),
        ElevatedButton(onPressed: () {}, child: const Text("Choisir un abonnement")),
      ],
    ));
  }

  Future<void> _startChatWithDiokara(BuildContext context) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final existingConvo = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('discussions')
        .where('with', isEqualTo: 'Diokara')
        .limit(1)
        .get();

    String conversationId;
    if (existingConvo.docs.isNotEmpty) {
      conversationId = existingConvo.docs.first.id;
    } else {
      final newConversationDoc = await FirebaseFirestore.instance.collection('users').doc(userId).collection('discussions').add({
        'title': 'Conversation avec Diokara',
        'last_updated': Timestamp.now(),
        'with': 'Diokara',
        'type': 'diokara',
        'status': 'active',
      });
      conversationId = newConversationDoc.id;
    }

    if(mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            chatWith: 'Diokara',
            conversationId: conversationId,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

     if (userId == null) {
      return const Scaffold(
        body: Center(
          child: Text("Veuillez vous connecter."),
        ),
      );
    }

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
                              "Demander un avis",
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
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .doc(userId)
                            .collection('discussions')
                            .where('type', isEqualTo: 'medecin')
                            .where('status', isEqualTo: 'pending')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          final pendingRequests = snapshot.data?.docs ?? [];
                          final hasPendingRequest = pendingRequests.isNotEmpty;

                          return SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Choisir son interlocuteur", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.black87)),
                                const SizedBox(height: 24),
                                
                                _buildDiokaraCard(context),
                                
                                const SizedBox(height: 20),
                                
                                _buildMedecinCard(context, hasPendingRequest: hasPendingRequest),

                                const SizedBox(height: 32),

                                if (hasPendingRequest)
                                  _buildPendingRequestSection(context, pendingRequests.first),
                              ],
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

  Widget _buildDiokaraCard(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), spreadRadius: 0, blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _startChatWithDiokara(context),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Container(width: 56, height: 56, decoration: BoxDecoration(color: const Color(0xFF4CAF50), borderRadius: BorderRadius.circular(28)), child: const Icon(Icons.psychology, color: Colors.white, size: 28)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Diokara", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87)),
                      const SizedBox(height: 4),
                      const Text("Posez une question à notre assistant DIOKARA !", style: TextStyle(fontSize: 14, color: Colors.black54, height: 1.3)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFF4CAF50).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                        child: const Text("Tarif: gratuit", style: TextStyle(fontSize: 12, color: Color(0xFF4CAF50), fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey, size: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMedecinCard(BuildContext context, {required bool hasPendingRequest}) {
    return Opacity(
      opacity: hasPendingRequest ? 0.5 : 1.0,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), spreadRadius: 0, blurRadius: 10, offset: const Offset(0, 2))],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              if (hasPendingRequest) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Vous avez déjà une demande en cours de validation.')),
                );
                return;
              }
              if (isPremium) { 
                _showPrerequisitesForm(context, 'un Médecin'); 
              } else { 
                _showSubscriptionDialog(context); 
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Container(width: 56, height: 56, decoration: BoxDecoration(color: const Color(0xFF2196F3), borderRadius: BorderRadius.circular(28)), child: const Icon(Icons.medical_services, color: Colors.white, size: 28)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Médecin", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87)),
                        const SizedBox(height: 4),
                        const Text("Posez votre question à un médecin certifié Adomed !", style: TextStyle(fontSize: 14, color: Colors.black54, height: 1.3)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: const Color(0xFFFF9800).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                          child: const Text("Tarif: nécessite un abonnement", style: TextStyle(fontSize: 12, color: Color(0xFFFF9800), fontWeight: FontWeight.w500)),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey, size: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPendingRequestSection(BuildContext context, DocumentSnapshot requestDoc) {
    final data = requestDoc.data() as Map<String, dynamic>;
    final subject = data['request_subject'] ?? 'Sujet non défini';
    final timestamp = data['last_updated'] as Timestamp?;
    final date = timestamp != null ? DateFormat('dd/MM/yyyy à HH:mm', 'fr_FR').format(timestamp.toDate()) : 'Date inconnue';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Votre demande en cours", style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            leading: const Icon(Icons.hourglass_top_outlined, color: Colors.orange),
            title: Text("Demande pour: $subject"),
            subtitle: Text("Envoyée le $date"),
            trailing: const Chip(
              label: Text('En attente'),
              backgroundColor: Colors.orange,
              labelStyle: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}