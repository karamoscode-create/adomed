// lib/screens/dossier/dossier_medical_screen.dart
import 'package:flutter/material.dart';
import 'package:adomed_app/theme/app_theme.dart';
import 'resultats_screen.dart';
import 'ordonnances_screen.dart';
import 'historique_screen.dart';

class DossierMedicalScreen extends StatefulWidget {
  final int initialTabIndex;

  const DossierMedicalScreen({super.key, this.initialTabIndex = 0});

  @override
  State<DossierMedicalScreen> createState() => _DossierMedicalScreenState();
}

class _DossierMedicalScreenState extends State<DossierMedicalScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: 3, vsync: this, initialIndex: widget.initialTabIndex);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // === MODIFICATION : Structure visuelle améliorée ===
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
                              'Dossier Médical',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimaryColor),
                            ),
                          ),
                          const SizedBox(width: 48), // Pour centrer le titre
                        ],
                      ),
                    ),
                    // Barre d'onglets
                    TabBar(
                      controller: _tabController,
                      indicatorColor: AppTheme.primaryColor,
                      labelColor: AppTheme.primaryColor,
                      unselectedLabelColor: Colors.grey,
                      tabs: const [
                        Tab(text: 'Résultats'),
                        Tab(text: 'Ordonnances'),
                        Tab(text: 'Historique'),
                      ],
                    ),
                    // Vues des onglets
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: const [
                          ResultatsScreen(),
                          OrdonnancesScreen(),
                          HistoriqueScreen(),
                        ],
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