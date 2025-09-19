// lib/screens/suivi_medical/imc_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:adomed_app/theme/app_theme.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:intl/intl.dart';
import 'article_screen.dart';
import 'imc_history_screen.dart';

class ImcScreen extends StatefulWidget {
  const ImcScreen({super.key});

  @override
  State<ImcScreen> createState() => _ImcScreenState();
}

class _ImcScreenState extends State<ImcScreen> {
  double _poids = 70.0;
  double _taille = 170.0;
  double _imc = 0;
  
  User? _currentUser;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    _calculateImc();
  }

  void _calculateImc() {
    if (_taille > 0) {
      final double tailleEnMetres = _taille / 100;
      final double imcValue = _poids / (tailleEnMetres * tailleEnMetres);
      setState(() => _imc = imcValue);
    }
  }

  Map<String, dynamic> _getInterpretation(double imc) {
    if (imc < 18.5) {
      return {
        'state': 'Insuffisance pondérale', 'color': Colors.blue.shade300,
        'recommendations': [
          {'title': 'Consultez un professionnel', 'content': 'Parlez-en à un médecin ou un nutritionniste pour évaluer les causes et envisager un régime adapté.'},
          {'title': 'Enrichissez votre alimentation', 'content': 'Ajoutez des collations saines et caloriques comme des oléagineux et des fruits secs.'},
        ]
      };
    }
    if (imc < 25) {
      return {
        'state': 'Corpulence normale', 'color': Colors.green,
        'recommendations': [
          {'title': 'Maintenez vos habitudes', 'content': 'Excellent ! Continuez avec une alimentation équilibrée et une activité physique régulière.'},
        ]
      };
    }
    if (imc < 30) {
      return {
        'state': 'Surpoids', 'color': Colors.orange.shade700,
        'recommendations': [
          {'title': 'Ajustez votre alimentation', 'content': 'Une perte de poids modérée peut améliorer votre santé. Pensez à réduire les sucres et les graisses saturées.'},
          {'title': 'Intégrez plus d\'exercice', 'content': 'Essayez d\'intégrer au moins 30 minutes de marche rapide dans votre quotidien.'},
        ]
      };
    }
    return {
      'state': 'Obésité', 'color': Colors.red,
      'recommendations': [
        {'title': 'Consultation médicale indispensable', 'content': 'Votre santé peut être en danger. Il est important de consulter un professionnel pour une prise en charge adaptée.'},
        {'title': 'Évitez les régimes drastiques', 'content': 'Les régimes "miracles" sont inefficaces. Un plan doit être établi avec un médecin.'},
      ]
    };
  }

  Future<void> _saveImcResult() async {
    if (_currentUser == null) return;
    setState(() => _isSaving = true);
    try {
      await FirebaseFirestore.instance.collection('users').doc(_currentUser!.uid).collection('imc_history').add({
        'poids': _poids,
        'taille': _taille,
        'imc': _imc,
        'interpretation': _getInterpretation(_imc)['state'],
        'date': Timestamp.now(),
      });
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Résultat sauvegardé !'), backgroundColor: Colors.green));
    } catch (e) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur : $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
          ),
          Padding(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 20),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
              child: Container(
                color: AppTheme.backgroundColor.withOpacity(0.95),
                child: Column(
                  children: [
                    _buildAppBar(),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.all(16.0),
                        children: [
                          _buildInputSliders(),
                          const SizedBox(height: 24),
                          _buildImcGauge(),
                          const SizedBox(height: 24),
                          _buildInterpretationCard(),
                          const SizedBox(height: 24),
                          _buildHistorySection(),
                          const SizedBox(height: 24),
                          _buildRecommendedReading(),
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

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 20, 16, 10),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimaryColor),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const Expanded(
            child: Text("Calculateur de l'IMC", textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimaryColor)),
          ),
          IconButton(
            icon: Icon(_isSaving ? Icons.pending : Icons.save_outlined, color: AppTheme.textPrimaryColor),
            onPressed: _isSaving ? null : _saveImcResult,
            tooltip: 'Sauvegarder',
          ),
        ],
      ),
    );
  }

  Widget _buildInputSliders() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            _buildSliderRow('Poids', _poids, 'kg', 30, 200, (val) => setState(() { _poids = val; _calculateImc(); })),
            const SizedBox(height: 16),
            _buildSliderRow('Taille', _taille, 'cm', 100, 250, (val) => setState(() { _taille = val; _calculateImc(); })),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSliderRow(String label, double value, String unit, double min, double max, ValueChanged<double> onChanged) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: Theme.of(context).textTheme.titleMedium),
            Text('${value.toStringAsFixed(unit == 'kg' ? 1 : 0)} $unit', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: ((max - min) * 2).toInt(),
          label: value.toStringAsFixed(unit == 'kg' ? 1 : 0),
          onChanged: onChanged,
        ),
      ],
    );
  }
  
  Widget _buildImcGauge() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SfRadialGauge(
          title: GaugeTitle(text: 'Votre IMC', textStyle: Theme.of(context).textTheme.titleLarge!),
          axes: <RadialAxis>[
            RadialAxis(
              minimum: 10,
              maximum: 50,
              ranges: <GaugeRange>[
                GaugeRange(startValue: 10, endValue: 18.5, color: Colors.blue.shade300, label: 'Maigreur'),
                GaugeRange(startValue: 18.5, endValue: 25, color: Colors.green, label: 'Normal'),
                GaugeRange(startValue: 25, endValue: 30, color: Colors.yellow.shade700, label: 'Surpoids'),
                GaugeRange(startValue: 30, endValue: 40, color: Colors.orange, label: 'Obésité'),
                GaugeRange(startValue: 40, endValue: 50, color: Colors.red, label: 'Sévère'),
              ],
              pointers: <GaugePointer>[
                NeedlePointer(value: _imc, enableAnimation: true)
              ],
              annotations: <GaugeAnnotation>[
                GaugeAnnotation(
                  widget: Text(_imc.toStringAsFixed(1), style: Theme.of(context).textTheme.headlineSmall),
                  angle: 90,
                  positionFactor: 0.5,
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInterpretationCard() {
    final interpretation = _getInterpretation(_imc);
    final state = interpretation['state'] as String;
    final recommendations = interpretation['recommendations'] as List<Map<String, String>>;
    final color = interpretation['color'] as Color;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ExpansionTile(
        leading: Icon(Icons.info_outline, color: color, size: 28),
        title: Text('État : $state', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: color)),
        subtitle: const Text('Voir les conseils exclusifs'),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: recommendations.map((rec) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.check_circle_outline, color: Colors.green),
                  title: Text(rec['title']!, style: Theme.of(context).textTheme.titleMedium),
                  subtitle: Text(rec['content']!),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildHistorySection() {
     return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Historique récent', style: Theme.of(context).textTheme.titleLarge),
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ImcHistoryScreen())), 
              child: const Text('Voir tout'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 120,
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('users').doc(_currentUser?.uid).collection('imc_history').orderBy('date', descending: true).limit(5).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Card(child: Center(child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Aucun historique pour le moment.', textAlign: TextAlign.center),
                )));
              }
              final docs = snapshot.data!.docs;
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final data = docs[index].data() as Map<String, dynamic>;
                  final date = (data['date'] as Timestamp).toDate();
                  final imcValue = (data['imc'] as double?) ?? 0.0;
                  
                  return Card(
                    child: Container(
                      width: 140,
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(imcValue.toStringAsFixed(1), style: Theme.of(context).textTheme.headlineSmall),
                          const Text('IMC'),
                          const SizedBox(height: 8),
                          Text(DateFormat('dd/MM/yy').format(date), style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
   }

  Widget _buildRecommendedReading() {
    final articles = [
      {
        'title': 'Comprendre le surpoids et l\'obésité', 'icon': Icons.info_outline, 'color': Colors.orange,
        'content': [
          {'subtitle': 'Qu\'est-ce que le surpoids ?', 'text': 'Le surpoids et l\'obésité sont une accumulation anormale de graisse corporelle qui peut nuire à la santé. L\'IMC est un outil simple pour évaluer cette condition.'},
        ]
      },
      {
        'title': '5 astuces pour une alimentation saine', 'icon': Icons.restaurant_menu, 'color': Colors.green,
        'content': [
          {'subtitle': 'Mangez varié', 'text': 'Consommez une grande variété de fruits, légumes, et protéines maigres pour obtenir tous les nutriments nécessaires.'},
        ]
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Lecture recommandée', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        ...articles.map((article) {
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: (article['color'] as Color).withOpacity(0.1),
                foregroundColor: article['color'] as Color,
                child: Icon(article['icon'] as IconData),
              ),
              title: Text(article['title'] as String),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ArticleScreen(
                  title: article['title'] as String,
                  imagePath: 'assets/images/articles/placeholder.png', // Image générique
                  content: article['content'] as List<Map<String, String>>,
                )));
              },
            ),
          );
        }).toList(),
      ],
    );
  }
}