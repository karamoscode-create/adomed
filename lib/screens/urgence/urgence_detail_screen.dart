// lib/screens/urgence/urgence_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:adomed_app/theme/app_theme.dart';
import 'package:adomed_app/screens/urgence/numeros_urgence_screen.dart';
import 'package:adomed_app/screens/urgence/urgence_models.dart';
import 'package:iconsax/iconsax.dart';

class UrgenceDetailScreen extends StatelessWidget {
  final UrgenceCategory category;
  const UrgenceDetailScreen({super.key, required this.category});

  void _showSubscriptionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Abonnement requis"),
        content: const Text("Vous n'avez souscrit à aucun abonnement, veuillez choisir une offre d'abonnement pour joindre directement notre assistance."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Plus tard")),
          ElevatedButton(onPressed: () {}, child: const Text("S'abonner maintenant")),
        ],
      ),
    );
  }

  void _showCallTypeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Choisir le mode d'appel"),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(icon: const Icon(Icons.call, size: 40, color: Colors.blue), onPressed: () {}),
            IconButton(icon: const Icon(Icons.videocam, size: 40, color: Colors.blue), onPressed: () {}),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.transparent,
      // On retire le FAB d'ici pour le mettre dans le Stack
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
                      padding: const EdgeInsets.fromLTRB(4, 20, 4, 10),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimaryColor),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          Expanded(
                            child: Text(
                              category.name,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimaryColor,
                              ),
                            ),
                          ),
                          // Action de l'ancienne AppBar
                          IconButton(
                            icon: const Icon(Iconsax.headphone, color: AppTheme.textPrimaryColor),
                            tooltip: "Numéros d'urgence",
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const NumerosUrgencesScreen()),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    // Contenu principal
                    Expanded(
                      child: user == null
                          ? const Center(child: Text("Utilisateur non connecté."))
                          : SingleChildScrollView(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Comment traiter : ${category.name.toLowerCase()}',
                                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 24),
                                  // ... Le reste de votre contenu de détail irait ici ...
                                  // Pour l'instant, c'est vide comme dans votre fichier original
                                ],
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Le FloatingActionButton est maintenant positionné dans le Stack pour flotter par-dessus tout
          if (user != null)
            Positioned(
              bottom: 30,
              left: 40,
              right: 40,
              child: StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return FloatingActionButton.extended(
                      onPressed: () {},
                      label: const Text("Chargement..."),
                      icon: const Icon(Icons.call_outlined),
                    );
                  }
                  if (snapshot.hasError) {
                    return FloatingActionButton.extended(
                      onPressed: () {},
                      label: const Text("Erreur de données"),
                      icon: const Icon(Icons.error_outline),
                    );
                  }
                  
                  final userData = snapshot.data?.data() as Map<String, dynamic>?;
                  final bool isSubscribed = userData?['isSubscribed'] ?? false;

                  return FloatingActionButton.extended(
                    onPressed: () {
                      if (isSubscribed) {
                        _showCallTypeDialog(context);
                      } else {
                        _showSubscriptionDialog(context);
                      }
                    },
                    label: const Text("Joindre le centre d'appel", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    icon: const Icon(Icons.call_outlined, color: Colors.white),
                    backgroundColor: Colors.transparent, // Le fond vient du dégradé
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ).addGradient(AppColors.primaryGradient); // Helper pour le dégradé
                },
              ),
            ),
        ],
      ),
    );
  }
}

// L'extension pour le dégradé du FAB (vous pouvez la laisser ici ou la mettre dans un fichier séparé)
extension GradientWidget on Widget {
  Widget addGradient(Gradient gradient) {
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(15)),
      child: Container(
        decoration: BoxDecoration(gradient: gradient),
        child: this,
      ),
    );
  }
}