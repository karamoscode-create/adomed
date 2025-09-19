// lib/screens/chat/discussions_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'chat_screen.dart';

class DiscussionsScreen extends StatelessWidget {
  const DiscussionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Discussions avec Diokara"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // ✅ REQUÊTE MODIFIÉE : Ne récupère que les discussions de type "diokara"
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('discussions')
            .where('type', isEqualTo: 'diokara') // Le filtre crucial
            .orderBy('last_updated', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Erreur de chargement des discussions.'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Aucune discussion avec Diokara.'));
          }

          final discussions = snapshot.data!.docs;

          return ListView.builder(
            itemCount: discussions.length,
            itemBuilder: (context, index) {
              final discussionData = discussions[index].data() as Map<String, dynamic>;
              final discussionId = discussions[index].id;
              
              final title = discussionData['title'] ?? 'Discussion';
              final timestamp = discussionData['last_updated'] as Timestamp?;
              final date = timestamp != null ? DateFormat('dd/MM/yyyy', 'fr_FR').format(timestamp.toDate()) : '';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  leading: const CircleAvatar(child: Text('D')),
                  title: Text(title, style: Theme.of(context).textTheme.titleMedium),
                  subtitle: Text("Dernier message: $date"),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(
                          chatWith: 'Diokara',
                          conversationId: discussionId,
                        ),
                      ),
                    );
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