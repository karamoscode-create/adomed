// lib/screens/bilans/packs_analyse_screen.dart

import 'package:flutter/material.dart';
import 'package:adomed_app/theme/app_theme.dart';
import 'package:adomed_app/screens/bilans/confirmation_bilan_screen.dart';

class PacksAnalyseScreen extends StatelessWidget {
  const PacksAnalyseScreen({super.key});

  final List<Map<String, dynamic>> packs = const [
    {
      'title': 'Pack "Check-Up Complet" (Bilan de Routine)',
      'price': 58900,
      'originalPrice': 67000,
      'analyses': ['NFS', 'CRP', 'Ionogramme (Sodium, Potassium, Chlore)', 'Calcium, Magnésium', 'Glycémie à jeun', 'Créatinine, Urée', 'Bilan Lipidique (Cholestérol Total, HDL, LDL, Triglycérides)', 'Bilan Hépatique (TGO, TGP)', 'Analyse d\'urines (ECBU)'],
    },
    {
      'title': 'Pack "Cœur & Artères" (Bilan Cardiovasculaire)',
      'price': 32000,
      'originalPrice': 36000,
      'analyses': ['Cholestérol Total, HDL, LDL, Triglycérides', 'Transaminases (TGO, TGP)', 'Glycémie à jeun', 'CRP', 'Urée, Créatinine', 'Ionogramme'],
    },
    {
      'title': 'Pack "Diabète & Métabolisme" (Bilan diabétique)',
      'price': 38000,
      'originalPrice': 43000,
      'analyses': ['Glycémie à jeun', 'HbA1c', 'Bilan Lipidique (Cholestérol Total, HDL, LDL, Triglycérides)', 'Bilan rénal (Urée, Créatinine)', 'Ionogramme (Sodium, Potassium, Chlore)'],
    },
    {
      'title': 'Pack "Fertilité Masculine" (Projet bébé)',
      'price': 60500,
      'originalPrice': 71000,
      'analyses': ['Spermogramme + Spermocytogramme', 'Electrophorèse de l’Hb', 'Groupe sanguin ABO', 'Hépatite B & C (AgHBs, AgHBC)', 'Prélèvement Urétral + ATB', 'VIH', 'Syphilis'],
    },
    {
      'title': 'Pack "Fertilité Féminine" (Projet bébé)',
      'price': 55000,
      'originalPrice': 61000,
      'analyses': ['Electrophorèse de l’Hb', 'Groupe sanguin ABO', 'Hépatite B & C (AgHBs, AgHBC)', 'Prélèvement Vaginal + ATB', 'VIH', 'Syphilis', 'Toxoplasmose', 'Rubéole'],
    },
    {
      'title': 'Pack "Dépistage des IST"',
      'price': 31500,
      'originalPrice': 37000,
      'analyses': ['VIH (SRV)', 'Hépatite B & C (AgHBs, AgHBC)', 'Syphilis (BW)', 'ECBU (pour les infections urinaires)'],
    },
    // MODIFIÉ : Ce pack a été mis à jour selon votre image.
    {
      'title': 'Pack "Bilan prénatal" Grossesse & Préconception',
      'price': 40500,
      'originalPrice': 48500,
      'analyses': [
        'Groupe Sanguin et Rhésus',
        'Toxoplasmose, Rubéole',
        'Syphilis, VIH-SIDA, Hépatite B',
        'Glycémie à jeûne',
        'Électrophorèse de l\'Hb',
        'ECBU',
        'NFS'
      ],
    },
    {
      'title': 'Pack "Thyroïde & Fatigue" – spéciale énergie',
      'price': 71000,
      'originalPrice': 83500,
      'analyses': ['TSH', 'T3 et T4', 'NFS', 'Urée, créatinine', 'Ionogramme (sodium, potassium, chlore)', 'Calcium, Magnésium'],
    },
    {
      'title': 'Pack "Foie & Détox" – spécial vitalité',
      'price': 40000,
      'originalPrice': 45000,
      'analyses': ['TGO, TGP, Gamma GT, Bilirubine Totale et Conjuguée', 'Phosphatases Alcalines (PAL)', 'Protides Totaux et Albumine', 'Triglycérides'],
    },
    {
      'title': 'Pack "Os & Articulations" – spécial confort mobile',
      'price': 32500,
      'originalPrice': 38500,
      'analyses': ['Calcium et Phosphore', 'Vitamine D', 'Acide Urique', 'Urée, Créatinine', 'NFS', 'CRP'],
    },
    {
      'title': 'Pack "Prénuptial (H+ F)" – spécial mariage',
      'price': 74000,
      'originalPrice': 87000,
      'analyses': ['Electrophorèse de l’Hb', 'Groupe sanguin ABO', 'VIH, Hépatite B & C, Syphilis', 'Rubéole (Femme)', 'Spermogramme + Spermocytogramme (Homme)'],
    },
    {
      'title': 'Pack "Stress & sommeil" – spécial bien-être',
      'price': 35500,
      'originalPrice': 41500,
      'analyses': ['Magnésium, Calcium', 'Urée, Créatinine', 'Transaminases (TGP, TGO)', 'Glycémie', 'TSH', 'NFS'],
    },
    {
      'title': 'Pack "Femme 40 ans +" – spécial maturité',
      'price': 78500,
      'originalPrice': 92500,
      'analyses': ['NFS', 'CRP', 'TSH', 'Bilan lipidique (Triglycérides, cholestérol HDL et LDL)', 'Glycémie', 'FSH, Estradiol (dosage hormonal)', 'Calcium, Vitamine D'],
    },
    {
      'title': 'Pack "Performance sportive" – spécial sportifs',
      'price': 45000,
      'originalPrice': 50500,
      'analyses': ['NFS', 'Magnésium, Calcium', 'Urée, Créatinémie', 'Ionogramme (sodium, potassium, chlore)', 'Bilan hépatique (transaminases)', 'CPK - Muscles (Créatine Phosphokinase)', 'Testostérone (hommes)'],
    },
    {
      'title': 'Pack "Paternité" – spécial test d’ADN',
      'price': 200000,
      'originalPrice': 500000,
      'analyses': ['Test ADN de paternité'],
    },
  ];

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
                      padding: const EdgeInsets.fromLTRB(4, 20, 16, 10),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimaryColor),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          const Expanded(
                            child: Text(
                              'Packs d’analyse',
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
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: packs.length,
                        itemBuilder: (_, i) {
                          final pack = packs[i];
                          return Card(
                            clipBehavior: Clip.antiAlias,
                            elevation: 2,
                            margin: const EdgeInsets.only(bottom: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: const BoxDecoration(
                                    gradient: AppColors.primaryGradient,
                                  ),
                                  child: Text(
                                    pack['title'],
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Analyses incluses :', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 8),
                                      ...pack['analyses'].map<Widget>((a) => Padding(
                                        padding: const EdgeInsets.only(bottom: 4.0),
                                        child: Text('• $a', style: Theme.of(context).textTheme.bodyMedium),
                                      )).toList(),
                                      const SizedBox(height: 12),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(top: 4.0),
                                            child: Text('Prix du Pack :', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                                          ),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Text('${pack['price']} FCFA', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary)),
                                              if (pack['originalPrice'] != null)
                                                Text(
                                                  'au lieu de ${pack['originalPrice']} FCFA',
                                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                    decoration: TextDecoration.lineThrough,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      SizedBox(
                                        width: double.infinity,
                                        height: 50,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => ConfirmationBilanScreen(
                                                  selectedAnalyses: pack['analyses'].map<Map<String, dynamic>>((a) => {'name': a, 'price': 0}).toList(),
                                                  totalPrice: pack['price'] as int,
                                                  packName: pack['title'] as String,
                                                ),
                                              ),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            padding: EdgeInsets.zero,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: Ink(
                                            decoration: BoxDecoration(
                                              gradient: AppColors.primaryGradient,
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Container(
                                              alignment: Alignment.center,
                                              child: const Text(
                                                'Commander',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
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