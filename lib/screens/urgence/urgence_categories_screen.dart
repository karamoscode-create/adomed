// lib/screens/urgence/urgence_categories_screen.dart

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:adomed_app/theme/app_theme.dart';
import 'cat_urgence_screen.dart';
import 'numeros_urgence_screen.dart';
import 'urgence_models.dart';

class UrgenceCategoriesScreen extends StatefulWidget {
  const UrgenceCategoriesScreen({super.key});

  @override
  State<UrgenceCategoriesScreen> createState() => _UrgenceCategoriesScreenState();
}

class _UrgenceCategoriesScreenState extends State<UrgenceCategoriesScreen> {
  final List<UrgenceCategory> _allCategories = const [
    UrgenceCategory(name: 'Arrêt Cardio-Respiratoire', icon: Iconsax.heart_add),
    UrgenceCategory(name: 'Traumatismes & Accidents', icon: Iconsax.personalcard),
    UrgenceCategory(name: 'Brûlures', icon: Iconsax.activity),
    UrgenceCategory(name: 'Intoxications & Empoisonnements', icon: Iconsax.document_text),
    UrgenceCategory(name: 'Noyades & Asphyxies', icon: Iconsax.cloud_snow),
    UrgenceCategory(name: 'Urgences Neurologiques', icon: Iconsax.profile_circle),
    UrgenceCategory(name: 'Autres Urgences', icon: Iconsax.more),
  ];

  List<UrgenceCategory> _filteredCategories = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredCategories = _allCategories;
    _searchController.addListener(_filterCategories);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterCategories);
    _searchController.dispose();
    super.dispose();
  }

  void _filterCategories() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCategories = _allCategories.where((category) {
        return category.name.toLowerCase().contains(query);
      }).toList();
    });
  }

  Future<void> _launchPhoneCall(String number) async {
    final Uri url = Uri(scheme: 'tel', path: number);
    if (!await launchUrl(url)) {
      // Gérer l'erreur si l'appel ne peut pas être lancé
      debugPrint('Impossible de lancer l\'appel au $number');
    }
  }

  @override
  Widget build(BuildContext context) {
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
                      padding: const EdgeInsets.fromLTRB(4, 20, 4, 10),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimaryColor),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          const Expanded(
                            child: Text(
                              'CAT d\'urgence',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimaryColor,
                              ),
                            ),
                          ),
                          // Actions de l'ancienne AppBar
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Iconsax.call, color: AppTheme.textPrimaryColor),
                                onPressed: () => _launchPhoneCall('002250704044643'), // Numéro d'adomed
                                tooltip: 'Appel d\'urgence',
                              ),
                              IconButton(
                                icon: const Icon(Iconsax.headphone, color: AppTheme.textPrimaryColor),
                                onPressed: () {
                                   Navigator.push(context, MaterialPageRoute(builder: (context) => const NumerosUrgencesScreen()));
                                },
                                tooltip: "Numéros d'urgence",
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Barre de recherche
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Rechercher une urgence...',
                          prefixIcon: const Icon(Iconsax.search_normal_1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ),
                    
                    // Liste des catégories
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filteredCategories.length,
                        itemBuilder: (context, index) {
                          final category = _filteredCategories[index];
                          return _CategoryCard(
                            category: category,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => CatUrgencesScreen(category: category)),
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

class _CategoryCard extends StatelessWidget {
  final UrgenceCategory category;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(category.icon, color: AppColors.primary, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  category.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Icon(Iconsax.arrow_right_3, size: 20, color: Colors.grey.shade600),
            ],
          ),
        ),
      ),
    );
  }
}