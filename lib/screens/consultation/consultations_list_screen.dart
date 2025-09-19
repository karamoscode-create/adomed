// consultations_list_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:adomed_app/screens/chat/chat_screen.dart';

class ConsultationsListScreen extends StatelessWidget {
  const ConsultationsListScreen({super.key});

  Widget _buildStatusChip(String status) {
    Color color;
    String label;
    IconData icon;

    switch (status) {
      case 'active':
        color = Colors.green;
        label = 'Active';
        icon = Icons.check_circle_outline;
        break;
      case 'closed':
        color = Colors.grey;
        label = 'Terminée';
        icon = Icons.lock_outline;
        break;
      case 'validated':
        color = Colors.blue;
        label = 'Validée';
        icon = Icons.check_circle_outline;
        break;
      case 'pending':
      default:
        color = Colors.orange;
        label = 'En attente';
        icon = Icons.hourglass_top_outlined;
        break;
    }

    return Chip(
      avatar: Icon(icon, color: Colors.white, size: 16),
      label: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      labelPadding: const EdgeInsets.only(left: 4, right: 8),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Mes Consultations")),
        body: const Center(child: Text("Utilisateur non connecté.")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mes Consultations"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('discussions')
            .where('type', isEqualTo: 'medecin')
            .orderBy('last_updated', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Erreur de chargement des consultations.'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Text(
                  'Aucune demande de consultation pour le moment. Vous pouvez en faire une depuis l\'écran des services.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final consultations = snapshot.data!.docs;

          return ListView.builder(
            itemCount: consultations.length,
            itemBuilder: (context, index) {
              final discussionData = consultations[index].data() as Map<String, dynamic>;
              final discussionId = consultations[index].id;
              
              final title = discussionData['title'] ?? 'Consultation';
              final interlocuteur = discussionData['with'] ?? 'Médecin';
              final timestamp = discussionData['last_updated'] as Timestamp?;
              final date = timestamp != null ? DateFormat('dd/MM/yyyy', 'fr_FR').format(timestamp.toDate()) : 'Date inconnue';
              final status = discussionData['status'] ?? 'pending';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.medical_services_outlined),
                  ),
                  title: Text(title, style: Theme.of(context).textTheme.titleMedium),
                  subtitle: Text("Avec: $interlocuteur • $date"),
                  trailing: _buildStatusChip(status),
                  onTap: () {
                    if (status == 'active' || status == 'closed') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            chatWith: interlocuteur,
                            conversationId: discussionId,
                          ),
                        ),
                      );
                    } else if (status == 'validated') {
                      // TODO: Naviguer vers l'écran de paiement
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Votre demande a été validée ! Veuillez procéder au paiement.')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Cette demande est toujours en attente de validation.')),
                      );
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
