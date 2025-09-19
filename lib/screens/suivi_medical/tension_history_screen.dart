// lib/screens/suivi_medical/tension_history_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:adomed_app/theme/app_theme.dart';

class TensionHistoryScreen extends StatelessWidget {
  const TensionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique de Tension'),
        backgroundColor: AppColors.primary,
      ),
      body: userId == null
          ? const Center(child: Text("Utilisateur non connecté."))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .collection('tension_history')
                  .orderBy('date', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('Aucun historique trouvé.'));
                }

                final records = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: records.length,
                  itemBuilder: (context, index) {
                    final data = records[index].data() as Map<String, dynamic>;
                    final systolique = data['systolique'] as int? ?? 0;
                    final diastolique = data['diastolique'] as int? ?? 0;
                    final interpretation = data['interpretation'] as String? ?? 'N/A';
                    final date = (data['date'] as Timestamp).toDate();

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text('$systolique\n$diastolique', textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
                        ),
                        title: Text('Tension : $systolique/$diastolique mmHg'),
                        subtitle: Text('$interpretation\n${DateFormat('EEEE d MMMM yyyy, HH:mm', 'fr_FR').format(date)}'),
                        isThreeLine: true,
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}