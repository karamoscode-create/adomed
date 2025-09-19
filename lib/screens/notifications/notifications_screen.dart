// lib/screens/notifications/notifications_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:adomed_app/theme/app_theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _currentUser = FirebaseAuth.instance.currentUser;
  
  // ✅ 1. ON UTILISE UN FUTURE AU LIEU D'UN STREAM
  // Cela permet de ne récupérer les données qu'une seule fois.
  late Future<QuerySnapshot> _notificationsFuture;

  @override
  void initState() {
    super.initState();
    
    if (_currentUser != null) {
      // On lance la récupération des données
      _notificationsFuture = _fetchNotifications();
      // On lance la mise à jour en arrière-plan, sans attendre la fin
      _markNotificationsAsRead();
    }
  }

  // Cette fonction récupère les notifications une seule fois
  Future<QuerySnapshot> _fetchNotifications() {
    return FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: _currentUser!.uid)
        .orderBy('timestamp', descending: true)
        .limit(30)
        .get(); // .get() au lieu de .snapshots()
  }

  // Cette fonction met à jour le statut en arrière-plan
  Future<void> _markNotificationsAsRead() async {
    if (_currentUser == null) return;

    final notificationsRef = FirebaseFirestore.instance.collection('notifications');
    final unreadNotifications = await notificationsRef
        .where('userId', isEqualTo: _currentUser!.uid)
        .where('isRead', isEqualTo: false)
        .get();

    if (unreadNotifications.docs.isEmpty) return;

    final batch = FirebaseFirestore.instance.batch();
    for (final doc in unreadNotifications.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    
    await batch.commit();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Notifications')),
        body: const Center(child: Text("Veuillez vous connecter.")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: true,
      ),
      // ✅ 2. ON UTILISE UN FUTUREBUILDER
      // Il construit l'interface à partir du résultat de notre Future.
      body: FutureBuilder<QuerySnapshot>(
        future: _notificationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
             return const Center(child: Text("Erreur de chargement des notifications."));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Aucune notification pour le moment.'),
                ],
              ),
            );
          }

          // La liste est maintenant statique et ne disparaîtra pas.
          final notifications = snapshot.data!.docs;

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              final data = notification.data() as Map<String, dynamic>;
              
              // On vérifie le statut "lu" de la notification au moment de l'ouverture de l'écran.
              final isReadInitially = data['isRead'] ?? false;
              final timestamp = (data['timestamp'] as Timestamp).toDate();

              return Dismissible(
                key: Key(notification.id),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) async {
                  await FirebaseFirestore.instance
                      .collection('notifications')
                      .doc(notification.id)
                      .delete();
                },
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                child: Container(
                  // L'apparence dépend du statut initial
                  color: isReadInitially ? AppColors.cardColor : AppColors.primary.withOpacity(0.05),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isReadInitially ? Colors.grey.shade300 : AppColors.primary,
                      child: Icon(Icons.notifications, color: isReadInitially ? Colors.grey.shade600 : Colors.white),
                    ),
                    title: Text(
                      data['message'] ?? 'Nouvelle notification',
                      style: TextStyle(fontWeight: isReadInitially ? FontWeight.normal : FontWeight.bold),
                    ),
                    subtitle: Text(DateFormat('dd MMM yyyy à HH:mm', 'fr_FR').format(timestamp)),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}