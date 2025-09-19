// lib/screens/profil/commandes_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:adomed_app/theme/app_theme.dart';

// Modèle de données pour une commande
class Order {
  final String id;
  final double totalPrice;
  final DateTime date;
  final String status;
  final List<dynamic> items;

  Order({
    required this.id,
    required this.totalPrice,
    required this.date,
    required this.status,
    required this.items,
  });

  factory Order.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Order(
      id: doc.id,
      totalPrice: (data['totalPrice'] ?? 0.0).toDouble(),
      date: (data['date'] as Timestamp).toDate(),
      status: data['status'] ?? 'En attente',
      items: data['items'] ?? [],
    );
  }
}

class CommandesScreen extends StatefulWidget {
  const CommandesScreen({super.key});

  @override
  State<CommandesScreen> createState() => _CommandesScreenState();
}

class _CommandesScreenState extends State<CommandesScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;

  // Fonction pour obtenir la couleur et l'icône en fonction du statut
  Map<String, dynamic> _getStatusStyle(String status) {
    switch (status.toLowerCase()) {
      case 'livré':
        return {'color': Colors.green, 'icon': Icons.check_circle_outline};
      case 'en cours':
        return {'color': Colors.orange, 'icon': Icons.local_shipping_outlined};
      case 'annulé':
        return {'color': Colors.red, 'icon': Icons.cancel_outlined};
      default: // 'en attente'
        return {'color': Colors.blue, 'icon': Icons.hourglass_top_outlined};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10),
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
                              'Mes Commandes',
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
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .doc(currentUser?.uid)
                            .collection('orders')
                            .orderBy('date', descending: true)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                            return const Center(
                              child: Text(
                                'Vous n\'avez passé aucune commande.',
                                style: TextStyle(color: Colors.grey, fontSize: 16),
                              ),
                            );
                          }

                          final orders = snapshot.data!.docs.map((doc) => Order.fromFirestore(doc)).toList();

                          return ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: orders.length,
                            itemBuilder: (context, index) {
                              final order = orders[index];
                              final statusStyle = _getStatusStyle(order.status);
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: ExpansionTile(
                                  leading: Icon(statusStyle['icon'], color: statusStyle['color']),
                                  title: Text('Commande du ${DateFormat('dd/MM/yyyy').format(order.date)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Text('Total : ${order.totalPrice.toStringAsFixed(0)} FCFA'),
                                  trailing: Chip(
                                    label: Text(
                                      order.status,
                                      style: TextStyle(color: statusStyle['color'], fontWeight: FontWeight.bold),
                                    ),
                                    backgroundColor: statusStyle['color'].withOpacity(0.1),
                                    side: BorderSide.none,
                                  ),
                                  children: order.items.map<Widget>((item) {
                                    return ListTile(
                                      dense: true,
                                      title: Text(item['name'] ?? 'Produit inconnu'),
                                      trailing: Text('Qté: ${item['quantity']}'),
                                    );
                                  }).toList(),
                                ),
                              );
                            },
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