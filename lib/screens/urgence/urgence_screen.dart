// lib/screens/urgence/urgence_screen.dart
import 'package:flutter/material.dart';
import 'package:adomed_app/theme/app_theme.dart';
import 'package:iconsax/iconsax.dart';
import 'cat_urgence_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'urgence_models.dart';
import 'package:cached_network_image/cached_network_image.dart';

class UrgenceScreen extends StatelessWidget {
  const UrgenceScreen({super.key});

  final List<UrgenceCategory> _categories = const [
    UrgenceCategory(
      name: 'Arrêt Cardio-Respiratoire',
      icon: Icons.monitor_heart_outlined,
      imageUrl: 'https://images.unsplash.com/photo-1579752945203-9118c7edc316?q=80&w=2940&auto=format&fit=crop',
      description: 'Reconnaître et agir face à un arrêt cardiaque. La réanimation cardio-pulmonaire (RCP) peut sauver une vie.',
    ),
    UrgenceCategory(
      name: 'Traumatismes & Accidents',
      icon: Icons.personal_injury_outlined,
      imageUrl: 'https://images.unsplash.com/photo-1598282366835-f7166164f9b8?q=80&w=2940&auto=format&fit=crop',
      description: 'Gestes de premiers secours pour les fractures, entorses, et blessures graves.',
    ),
    UrgenceCategory(
      name: 'Brûlures',
      icon: Icons.local_fire_department_outlined,
      imageUrl: 'https://images.unsplash.com/photo-1616766488349-f07f5a34241e?q=80&w=2940&auto=format&fit=crop',
      description: 'Refroidir, protéger et alerter en cas de brûlures thermiques ou chimiques.',
    ),
    UrgenceCategory(
      name: 'Intoxications & Empoisonnements',
      icon: Icons.science_outlined,
      imageUrl: 'https://images.unsplash.com/photo-1577789490184-2a6230f82f6e?q=80&w=2940&auto=format&fit=crop',
      description: 'Que faire face à l\'ingestion de substances toxiques ou à l\'empoisonnement.',
    ),
    UrgenceCategory(
      name: 'Noyades & Asphyxies',
      icon: Icons.waves_outlined,
      imageUrl: 'https://images.unsplash.com/photo-1534005885741-9c60e0a5879a?q=80&w=2940&auto=format&fit=crop',
      description: 'Actions urgentes pour les victimes de noyade ou d\'obstruction des voies respiratoires.',
    ),
    UrgenceCategory(
      name: 'Urgences Neurologiques',
      icon: Icons.psychology_outlined,
      imageUrl: 'https://images.unsplash.com/photo-1627960714243-7f28ed9836ae?q=80&w=2940&auto=format&fit=crop',
      description: 'Identifier et réagir aux accidents vasculaires cérébraux (AVC) ou crises d\'épilepsie.',
    ),
    UrgenceCategory(
      name: 'Autres Urgences',
      icon: Icons.more_horiz_outlined,
      imageUrl: 'https://images.unsplash.com/photo-1576091160550-21735c249419?q=80&w=2940&auto=format&fit=crop',
      description: 'Gestion des malaises, chocs, réactions allergiques sévères, etc.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // --- NOUVEAUTÉ : Liste des couleurs pour les catégories ---
    final List<Color> categoryColors = [
      Colors.red.shade600,
      Colors.blue.shade700,
      Colors.green.shade600,
      Colors.orange.shade800,
      Colors.purple.shade600,
      Colors.teal.shade500,
    ];

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
                    Padding(
                      padding: const EdgeInsets.fromLTRB(4, 20, 4, 10),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimaryColor),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          const Expanded(
                            child: Text(
                              'CAT d\'Urgence',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimaryColor,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Iconsax.call, color: AppTheme.textPrimaryColor),
                            tooltip: "Contacter le support",
                            onPressed: () {
                              const String phoneNumber = "+2250704044643";
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text("Contacter le support"),
                                    content: const Text("Choisissez une option :"),
                                    actions: <Widget>[
                                      TextButton(
                                        child: const Text("WhatsApp"),
                                        onPressed: () async {
                                          Navigator.of(context).pop();
                                          final Uri whatsappUri = Uri.parse("https://wa.me/$phoneNumber");
                                          if (await canLaunchUrl(whatsappUri)) {
                                            await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
                                          } else {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text("Impossible d'ouvrir WhatsApp.")),
                                            );
                                          }
                                        },
                                      ),
                                      TextButton(
                                        child: const Text("Appel"),
                                        onPressed: () async {
                                          Navigator.of(context).pop();
                                          final Uri phoneUri = Uri.parse("tel:$phoneNumber");
                                          if (await canLaunchUrl(phoneUri)) {
                                            await launchUrl(phoneUri);
                                          } else {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text("Impossible de lancer l'appel.")),
                                            );
                                          }
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _categories.length,
                        itemBuilder: (context, index) {
                          final category = _categories[index];
                          // --- MODIFICATION : On choisit une couleur basée sur l'index ---
                          final itemColor = categoryColors[index % categoryColors.length];

                          return _CategoryCard(
                            category: category,
                            // On passe la couleur au widget de la carte
                            color: itemColor,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CatUrgencesScreen(category: category),
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


// --- MODIFICATION DU WIDGET _CategoryCard POUR ACCEPTER UNE COULEUR ---
class _CategoryCard extends StatelessWidget {
  final UrgenceCategory category;
  final VoidCallback onTap;
  final Color color; // Nouveau paramètre pour la couleur

  const _CategoryCard({
    required this.category,
    required this.onTap,
    required this.color, // Ajouté au constructeur
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      margin: const EdgeInsets.only(bottom: 20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 150,
              width: double.infinity,
              child: CachedNetworkImage(
                imageUrl: category.imageUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[200],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[200],
                  child: const Center(child: Icon(Icons.broken_image, color: Colors.red)),
                ),
              ),
            ),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          // --- MODIFICATION : Utilisation de la couleur passée en paramètre ---
                          color: color,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    category.description!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[800],
                        ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 15),
                  Align(
                    alignment: Alignment.bottomRight,
                    // --- MODIFICATION : Utilisation de la couleur pour l'icône également ---
                    child: Icon(Icons.arrow_forward_ios, size: 20, color: color),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}