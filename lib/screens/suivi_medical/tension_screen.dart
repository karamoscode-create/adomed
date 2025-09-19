// lib/screens/suivi_medical/tension_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:adomed_app/theme/app_theme.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'article_screen.dart';
import 'tension_history_screen.dart';

class TensionScreen extends StatefulWidget {
  const TensionScreen({super.key});

  @override
  State<TensionScreen> createState() => _TensionScreenState();
}

class _TensionScreenState extends State<TensionScreen> {
  double _systolique = 120.0;
  double _diastolique = 80.0;
  double _pouls = 70.0;
  DateTime _selectedDateTime = DateTime.now();
  String? _selectedNote;
  
  User? _currentUser;
  bool _isSaving = false;
  
  final List<String> _notes = ['Après le repas', 'Avant le repas', 'Stressé', 'Au repos', 'Après médicament', 'Avant médicament', 'Bras gauche', 'Bras droit'];

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
  }

  Map<String, dynamic> _getInterpretation() {
    if (_systolique < 90 || _diastolique < 60) {
      return {
        'state': 'Hypotension',
        'color': Colors.blue.shade300,
        'recommendations': [
          {'title': 'Reposez-vous et hydratez-vous', 'content': 'Si vous ressentez des vertiges, allongez-vous et surélevez vos jambes. Buvez de l\'eau pour aider à stabiliser votre tension.'},
          {'title': 'Consultez si persistant', 'content': 'Si les symptômes de vertige ou de faiblesse persistent, il est conseillé d\'en parler à votre médecin.'}
        ]
      };
    }
    if (_systolique < 120 && _diastolique < 80) {
      return {
        'state': 'Normale',
        'color': Colors.green,
        'recommendations': [
          {'title': 'Continuez comme ça !', 'content': 'Votre tension est idéale. Maintenez une alimentation équilibrée et une activité physique régulière pour préserver votre santé cardiovasculaire.'},
        ]
      };
    }
    if (_systolique < 140 || _diastolique < 90) {
      return {
        'state': 'Hypertension légère',
        'color': Colors.orange.shade700,
        'recommendations': [
          {'title': 'Modifiez votre mode de vie', 'content': 'Votre tension est élevée. Il est conseillé de réduire votre consommation de sel, d\'éviter le stress et de pratiquer une activité physique.'},
          {'title': 'Consultez votre médecin', 'content': 'Un suivi régulier avec votre médecin est important pour contrôler l\'évolution et discuter des prochaines étapes.'},
        ]
      };
    }
    return {
      'state': 'Hypertension sévère',
      'color': Colors.red,
      'recommendations': [
        {'title': 'Action Médicale Requise', 'content': 'Une tension très élevée peut être dangereuse. Si vous avez des maux de tête intenses, des troubles de la vision ou une douleur à la poitrine, consultez un médecin sans attendre.'},
      ]
    };
  }

  Future<void> _saveTensionResult() async {
    if (_currentUser == null) return;
    setState(() => _isSaving = true);
    try {
      await FirebaseFirestore.instance.collection('users').doc(_currentUser!.uid).collection('tension_history').add({
        'systolique': _systolique.toInt(),
        'diastolique': _diastolique.toInt(),
        'pouls': _pouls.toInt(),
        'interpretation': _getInterpretation()['state'],
        'note': _selectedNote,
        'date': Timestamp.fromDate(_selectedDateTime),
      });
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mesure sauvegardée !'), backgroundColor: Colors.green));
    } catch (e) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur : $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _selectDateTime() async {
    final DateTime? date = await showDatePicker(context: context, initialDate: _selectedDateTime, firstDate: DateTime(2000), lastDate: DateTime.now());
    if (date == null) return;
    final TimeOfDay? time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_selectedDateTime));
    if (time == null) return;
    setState(() => _selectedDateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute));
  }
  
  void _showNotePicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: _notes.map((note) => ListTile(
              title: Text(note),
              onTap: () {
                setState(() => _selectedNote = note);
                Navigator.of(context).pop();
              },
            )).toList(),
          ),
        );
      },
    );
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
                          _buildGaugeCard(),
                          const SizedBox(height: 24),
                          _buildInterpretationCard(),
                          const SizedBox(height: 24),
                          _buildHistorySection(),
                          const SizedBox(height: 24),
                          _buildRecommendedReading(),
                          const SizedBox(height: 24),
                          _buildDateTimePicker(),
                          const SizedBox(height: 16),
                          _buildNotePickerTile(),
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
            child: Text('Suivi de Tension', textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimaryColor)),
          ),
          IconButton(
            icon: Icon(_isSaving ? Icons.pending : Icons.save_outlined, color: AppTheme.textPrimaryColor),
            onPressed: _isSaving ? null : _saveTensionResult,
            tooltip: 'Sauvegarder',
          )
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
             _buildSliderRow('Systolique', _systolique, 'mmHg', 70, 200, (val) => setState(() => _systolique = val)),
             const SizedBox(height: 16),
             _buildSliderRow('Diastolique', _diastolique, 'mmHg', 40, 120, (val) => setState(() => _diastolique = val)),
             const SizedBox(height: 16),
             _buildSliderRow('Pouls', _pouls, 'bpm', 40, 180, (val) => setState(() => _pouls = val)),
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
            Text('${value.toInt()} $unit', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
        Slider(value: value, min: min, max: max, divisions: (max - min).toInt(), label: value.toInt().toString(), onChanged: onChanged),
      ],
    );
  }
  
  Widget _buildGaugeCard() {
     return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Votre mesure : ${_systolique.toInt()}/${_diastolique.toInt()} mmHg', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 20),
            _buildLinearGauge(context: context, value: _systolique, label: 'Systolique (SYS)', minimum: 70, maximum: 200,
              ranges: [
                LinearGaugeRange(startValue: 70, endValue: 90, color: Colors.blue.shade300),
                const LinearGaugeRange(startValue: 90, endValue: 130, color: Colors.green),
                LinearGaugeRange(startValue: 130, endValue: 140, color: Colors.yellow.shade600),
                const LinearGaugeRange(startValue: 140, endValue: 180, color: Colors.orange),
                const LinearGaugeRange(startValue: 180, endValue: 200, color: Colors.red),
              ],
            ),
            const SizedBox(height: 16),
            _buildLinearGauge(context: context, value: _diastolique, label: 'Diastolique (DIA)', minimum: 40, maximum: 120,
              ranges: [
                LinearGaugeRange(startValue: 40, endValue: 60, color: Colors.blue.shade300),
                const LinearGaugeRange(startValue: 60, endValue: 85, color: Colors.green),
                LinearGaugeRange(startValue: 85, endValue: 90, color: Colors.yellow.shade600),
                const LinearGaugeRange(startValue: 90, endValue: 110, color: Colors.orange),
                const LinearGaugeRange(startValue: 110, endValue: 120, color: Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInterpretationCard() {
    final interpretation = _getInterpretation();
    final state = interpretation['state'] as String;
    final recommendations = interpretation['recommendations'] as List<Map<String, String>>;
    final color = interpretation['color'] as Color;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ExpansionTile(
        leading: Icon(Icons.info_outline, color: color, size: 28),
        title: Text('État: $state', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: color)),
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
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TensionHistoryScreen())), 
              child: const Text('Voir tout'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 120,
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('users').doc(_currentUser?.uid).collection('tension_history').orderBy('date', descending: true).limit(5).snapshots(),
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
                  final systolique = data['systolique'] as int? ?? 0;
                  final diastolique = data['diastolique'] as int? ?? 0;
                  
                  return Card(
                    child: Container(
                      width: 140,
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('$systolique / $diastolique', style: Theme.of(context).textTheme.headlineSmall),
                          const Text('mmHg'),
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
        'title': 'Faits surprenants sur l\'hypertension', 'icon': Icons.lightbulb_outline, 'color': Colors.amber,
        'content': [
          {'subtitle': 'Un "tueur silencieux"', 'text': 'L\'hypertension artérielle ne présente souvent aucun symptôme, c\'est pourquoi un dépistage régulier est crucial.'},
          {'subtitle': 'Le sel est un facteur majeur', 'text': 'Une grande partie du sel que nous consommons provient des aliments transformés. Lire les étiquettes peut vous aider à réduire votre apport.'},
        ]
      },
      {
        'title': 'Prévenir et gérer l\'hypertension', 'icon': Icons.shield_outlined, 'color': Colors.blue,
        'content': [
          {'subtitle': 'L\'activité physique', 'text': 'Visez au moins 30 minutes d\'exercice modéré, comme la marche rapide, la plupart des jours de la semaine.'},
          {'subtitle': 'L\'alimentation DASH', 'text': 'Le régime DASH (Dietary Approaches to Stop Hypertension) est riche en fruits, légumes, grains entiers et produits laitiers faibles en gras.'},
        ]
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Lecture recommandée', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        ...articles.map((article) => Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: (article['color'] as Color).withOpacity(0.1),
              foregroundColor: article['color'] as Color,
              child: Icon(article['icon'] as IconData),
            ),
            title: Text(article['title'] as String),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ArticleScreen(
              title: article['title'] as String,
              imagePath: 'assets/images/articles/placeholder.png', // Image générique
              content: article['content'] as List<Map<String, String>>,
            ))),
          ),
        )).toList(),
      ],
    );
  }

  Widget _buildDateTimePicker() {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        leading: const Icon(Icons.calendar_today_outlined, color: AppColors.secondaryText),
        title: Text('Date et heure', style: Theme.of(context).textTheme.bodyLarge),
        subtitle: Text(DateFormat('dd MMMM yyyy, HH:mm', 'fr_FR').format(_selectedDateTime)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: _selectDateTime,
      ),
    );
  }

  Widget _buildNotePickerTile() {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        leading: const Icon(Icons.note_alt_outlined, color: AppColors.secondaryText),
        title: Text('Note', style: Theme.of(context).textTheme.bodyLarge),
        subtitle: Text(_selectedNote ?? 'Ajouter une note...'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: _showNotePicker,
      ),
    );
  }

  Widget _buildLinearGauge({ required BuildContext context, required double value, required String label, required double minimum, required double maximum, required List<LinearGaugeRange> ranges, }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        SfLinearGauge(
          minimum: minimum,
          maximum: maximum,
          ranges: ranges,
          axisTrackStyle: const LinearAxisTrackStyle(thickness: 15, edgeStyle: LinearEdgeStyle.bothCurve),
          markerPointers: [LinearShapePointer(value: value, color: AppColors.primaryText, height: 20, width: 20, shapeType: LinearShapePointerType.circle)],
          barPointers: [LinearBarPointer(value: value, color: Colors.transparent)],
        ),
      ],
    );
  }
}