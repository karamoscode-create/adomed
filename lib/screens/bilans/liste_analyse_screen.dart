// lib/screens/bilans/liste_analyse_screen.dart

import 'package:flutter/material.dart';
import 'package:adomed_app/theme/app_theme.dart';
import 'confirmation_bilan_screen.dart';

class ListeAnalyseScreen extends StatefulWidget {
  const ListeAnalyseScreen({super.key});

  @override
  State<ListeAnalyseScreen> createState() => _ListeAnalyseScreenState();
}

class _ListeAnalyseScreenState extends State<ListeAnalyseScreen> {
  final List<Map<String, dynamic>> _allAnalyses = [
    // Bilan Général & Systémique
    {'name': 'Electrophorèse de l’Hb', 'price': 7000, 'selected': false, 'category': 'Bilan Général & Systémique'},
    {'name': 'NFS (Numération Formule Sanguine)', 'price': 3500, 'selected': false, 'category': 'Bilan Général & Systémique'},
    {'name': 'VS (Vitesse de Sédimentation)', 'price': 3000, 'selected': false, 'category': 'Bilan Général & Systémique'},
    {'name': 'CRP (Protéine C Réactive)', 'price': 5000, 'selected': false, 'category': 'Bilan Général & Systémique'},
    {'name': 'Ionogramme (Sodium, Potassium, Chlore)', 'price': 8000, 'selected': false, 'category': 'Bilan Général & Systémique'},
    {'name': 'Glycémie', 'price': 2000, 'selected': false, 'category': 'Bilan Général & Systémique'},
    {'name': 'HbA1c (Hémoglobine Glyquée)', 'price': 16000, 'selected': false, 'category': 'Bilan Général & Systémique'},
    {'name': 'Électrophorèse des Protéines', 'price': 12000, 'selected': false, 'category': 'Bilan Général & Systémique'},
    // Bilan Rénal (Système Urinaire)
    {'name': 'Urée, Créatinine', 'price': 4000, 'selected': false, 'category': 'Bilan Rénal (Système Urinaire)'},
    {'name': 'Acide Urique', 'price': 3000, 'selected': false, 'category': 'Bilan Rénal (Système Urinaire)'},
    {'name': 'ECBU + Antibiogramme', 'price': 16000, 'selected': false, 'category': 'Bilan Rénal (Système Urinaire)'},
    {'name': 'Micro-albuminurie', 'price': 4000, 'selected': false, 'category': 'Bilan Rénal (Système Urinaire)'},
    // Bilan Hépatique (Foie)
    {'name': 'Transaminases (TGO/ASAT, TGP/ALAT)', 'price': 4000, 'selected': false, 'category': 'Bilan Hépatique (Foie)'},
    {'name': 'Gamma GT', 'price': 7000, 'selected': false, 'category': 'Bilan Hépatique (Foie)'},
    {'name': 'Bilirubine (Totale et Conjuguée)', 'price': 8000, 'selected': false, 'category': 'Bilan Hépatique (Foie)'},
    {'name': 'PAL (Phosphatases Alcalines)', 'price': 5000, 'selected': false, 'category': 'Bilan Hépatique (Foie)'},
    {'name': 'Protides Totaux', 'price': 12000, 'selected': false, 'category': 'Bilan Hépatique (Foie)'},
    {'name': 'Albumine', 'price': 4000, 'selected': false, 'category': 'Bilan Hépatique (Foie)'},
    // Bilan Lipidique (Risque Cardiovasculaire)
    {'name': 'Cholestérol Total', 'price': 4000, 'selected': false, 'category': 'Bilan Lipidique (Risque Cardiovasculaire)'},
    {'name': 'Cholestérol HDL', 'price': 3000, 'selected': false, 'category': 'Bilan Lipidique (Risque Cardiovasculaire)'},
    {'name': 'Cholestérol LDL', 'price': 3000, 'selected': false, 'category': 'Bilan Lipidique (Risque Cardiovasculaire)'},
    {'name': 'Triglycérides', 'price': 3000, 'selected': false, 'category': 'Bilan Lipidique (Risque Cardiovasculaire)'},
    // Bilan Thyroïdien
    {'name': 'TSH', 'price': 20000, 'selected': false, 'category': 'Bilan Thyroïdien'},
    {'name': 'T3 & T4', 'price': 40000, 'selected': false, 'category': 'Bilan Thyroïdien'},
    // Bilan Infectieux & Sérologies
    {'name': 'GE (Goutte Epaisse)', 'price': 2500, 'selected': false, 'category': 'Bilan Infectieux & Sérologies'},
    {'name': 'Widal & Felix', 'price': 5000, 'selected': false, 'category': 'Bilan Infectieux & Sérologies'},
    {'name': 'BW (Syphilis)', 'price': 5000, 'selected': false, 'category': 'Bilan Infectieux & Sérologies'},
    {'name': 'SRV (VIH/SIDA)', 'price': 2000, 'selected': false, 'category': 'Bilan Infectieux & Sérologies'},
    {'name': 'HBsAg (Hépatite B)', 'price': 7000, 'selected': false, 'category': 'Bilan Infectieux & Sérologies'},
    {'name': 'VHC (Hépatite C)', 'price': 7000, 'selected': false, 'category': 'Bilan Infectieux & Sérologies'},
    {'name': 'Toxoplasmose', 'price': 5000, 'selected': false, 'category': 'Bilan Infectieux & Sérologies'},
    {'name': 'Rubéole', 'price': 5000, 'selected': false, 'category': 'Bilan Infectieux & Sérologies'},
    {'name': 'ASLO', 'price': 5000, 'selected': false, 'category': 'Bilan Infectieux & Sérologies'},
    {'name': 'BHCG', 'price': 20000, 'selected': false, 'category': 'Bilan Infectieux & Sérologies'},
    {'name': 'Prélèvement urétrale + Antibiogramme', 'price': 20000, 'selected': false, 'category': 'Bilan Infectieux & Sérologies'},
    {'name': 'Prélèvement vaginale + Antibiogramme', 'price': 20000, 'selected': false, 'category': 'Bilan Infectieux & Sérologies'},
    // Bilan Inflammatoire & Immunitaire
    {'name': 'CRP (Protéine C Réactive)', 'price': 5000, 'selected': false, 'category': 'Bilan Inflammatoire & Immunitaire'},
    {'name': 'VS (Vitesse de Sédimentation)', 'price': 3000, 'selected': false, 'category': 'Bilan Inflammatoire & Immunitaire'},
    {'name': 'Électrophorèse des Protéines', 'price': 12000, 'selected': false, 'category': 'Bilan Inflammatoire & Immunitaire'},
    {'name': 'ASLO', 'price': 5000, 'selected': false, 'category': 'Bilan Inflammatoire & Immunitaire'},
    // Bilan de la Fertilité (Homme)
    {'name': 'Spermogramme + Spermocytogramme', 'price': 20000, 'selected': false, 'category': 'Bilan de la Fertilité (Homme)'},
    {'name': 'Spermoculture + Antibiogramme', 'price': 20000, 'selected': false, 'category': 'Bilan de la Fertilité (Homme)'},
    // Bilan Digestif & Pancréatique
    {'name': 'Lipasémie', 'price': 12000, 'selected': false, 'category': 'Bilan Digestif & Pancréatique'},
    {'name': 'KOP (Examen Parasitologique des Selles)', 'price': 4000, 'selected': false, 'category': 'Bilan Digestif & Pancréatique'},
    {'name': 'Coproculture', 'price': 8000, 'selected': false, 'category': 'Bilan Digestif & Pancréatique'},
    // Bilan Coagulation
    {'name': 'TP (Temps de Prothrombine) / INR', 'price': 4000, 'selected': false, 'category': 'Bilan Coagulation'},
    {'name': 'TCA (Temps de Céphaline Activée)', 'price': 4000, 'selected': false, 'category': 'Bilan Coagulation'},
    {'name': 'Fibrinémie', 'price': 4000, 'selected': false, 'category': 'Bilan Coagulation'},
    {'name': 'TP & TCA & Fibrinémie', 'price': 12000, 'selected': false, 'category': 'Bilan Coagulation'},
    // Autres Dosages Spécifiques
    {'name': 'PSA', 'price': 15000, 'selected': false, 'category': 'Autres Dosages Spécifiques'},
    {'name': 'ACE (Antigène Carcino-Embryonnaire)', 'price': 30000, 'selected': false, 'category': 'Autres Dosages Spécifiques'},
    {'name': 'Groupe Rhésus', 'price': 3000, 'selected': false, 'category': 'Autres Dosages Spécifiques'},
    {'name': 'Calcium (Ca) & Magnésium (Mg)', 'price': 8000, 'selected': false, 'category': 'Autres Dosages Spécifiques'},
    {'name': 'Calcium (Ca)', 'price': 4000, 'selected': false, 'category': 'Autres Dosages Spécifiques'},
    {'name': 'Magnésium (Mg)', 'price': 4000, 'selected': false, 'category': 'Autres Dosages Spécifiques'},
  ];

  final Map<String, List<Map<String, dynamic>>> _analysesByCategory = {};

  @override
  void initState() {
    super.initState();
    // Grouper les analyses par catégorie
    for (var analyse in _allAnalyses) {
      final category = analyse['category'] as String;
      if (!_analysesByCategory.containsKey(category)) {
        _analysesByCategory[category] = [];
      }
      _analysesByCategory[category]!.add(analyse);
    }
  }

  void _onSelectionChanged(int index, bool? value) {
    setState(() => _allAnalyses[index]['selected'] = value ?? false);
  }

  void _next() {
    final selected = _allAnalyses.where((e) => e['selected']).toList();
    if (selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner au moins une analyse.'))
      );
      return;
    }

    final total = selected.fold<int>(0, (sum, e) => sum + (e['price'] as int));

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ConfirmationBilanScreen(
          selectedAnalyses: selected,
          totalPrice: total,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // MODIFICATION : La structure de l'écran est maintenant un Stack
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
                    // En-tête personnalisé remplaçant l'AppBar
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
                              'Analyses à la demande',
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

                    // Le contenu principal est dans un Expanded pour être scrollable
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: _analysesByCategory.keys.map((category) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                  category,
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                ),
                              ),
                              ..._analysesByCategory[category]!.map((analyse) {
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: CheckboxListTile(
                                    value: analyse['selected'],
                                    onChanged: (val) {
                                      final index = _allAnalyses.indexOf(analyse);
                                      _onSelectionChanged(index, val);
                                    },
                                    title: Text(analyse['name'], style: Theme.of(context).textTheme.bodyLarge),
                                    secondary: Text('${analyse['price']} FCFA', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.primary)),
                                    activeColor: AppColors.primary,
                                  ),
                                );
                              }).toList(),
                            ],
                          );
                        }).toList(),
                      ),
                    ),

                    // Le bouton est maintenant le dernier élément de la Column
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                      child: InkWell(
                        onTap: _next,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Text('Continuer', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
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