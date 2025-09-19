// lib/screens/suivi_medical/glycemie_history_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:adomed_app/theme/app_theme.dart';

class GlycemieHistoryScreen extends StatelessWidget {
  const GlycemieHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique de Glycémie'),
        backgroundColor: AppColors.primary,
      ),
      body: userId == null
          ? const Center(child: Text("Utilisateur non connecté."))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .collection('glycemie_history')
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
                    final value = (data['glycemie_mmolL'] as double?) ?? 0.0;
                    final interpretation = data['interpretation'] as String? ?? 'N/A';
                    final date = (data['date'] as Timestamp).toDate();

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(value.toStringAsFixed(1)),
                        ),
                        title: Text('Glycémie : ${value.toStringAsFixed(1)} mmol/L'),
                        subtitle: Text('$interpretation\n${DateFormat('d MMM yyyy, HH:mm', 'fr_FR').format(date)}'),
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