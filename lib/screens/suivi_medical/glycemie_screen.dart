// lib/screens/suivi_medical/glycemie_screen.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:adomed_app/theme/app_theme.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'article_screen.dart';
import 'glycemie_history_screen.dart';
import 'reminder_screen.dart';

enum GlycemieUnit { mmolL, mgdL }

class GlycemieScreen extends StatefulWidget {
  const GlycemieScreen({super.key});

  @override
  State<GlycemieScreen> createState() => _GlycemieScreenState();
}

class _GlycemieScreenState extends State<GlycemieScreen> {
  double _glycemieInMmolL = 7.6;
  DateTime _selectedDateTime = DateTime.now();
  String? _selectedNote;
  GlycemieUnit _currentUnit = GlycemieUnit.mmolL;
  User? _currentUser;
  bool _isSaving = false;

  final List<String> _notes = ['À jeun', 'Avant le repas', 'Après le repas (1h)', 'Après le repas (2h)', 'Avant sport', 'Après sport'];
  static const double _conversionFactor = 18.0182;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
  }

  double get _displayValue {
    return _currentUnit == GlycemieUnit.mgdL ? _glycemieInMmolL * _conversionFactor : _glycemieInMmolL;
  }
  
  Map<String, String> _getInterpretation() {
    if (_glycemieInMmolL < 4.0) return {'state': 'Hypoglycémie', 'recommendation': 'Consommez rapidement 15g de glucides (sucre, jus). Contrôlez à nouveau dans 15 minutes.'};
    if (_glycemieInMmolL < 7.0 && _selectedNote == 'À jeun') return {'state': 'Normale (à jeun)', 'recommendation': 'Excellent ! Maintenez une alimentation équilibrée et une activité physique régulière.'};
    if (_glycemieInMmolL < 10.0 && _selectedNote != 'À jeun') return {'state': 'Normale (post-repas)', 'recommendation': 'Votre taux est bon. Continuez vos bonnes habitudes.'};
    if (_glycemieInMmolL < 10.0) return {'state': 'Hyperglycémie modérée', 'recommendation': 'Votre taux est élevé. Buvez de l\'eau, surveillez votre alimentation et évitez les sucres rapides.'};
    return {'state': 'Hyperglycémie sévère', 'recommendation': 'Taux très élevé. Contactez votre médecin ou un professionnel de santé rapidement. Ne restez pas seul.'};
  }

  Future<void> _saveGlycemieResult() async {
    if (_currentUser == null) return;
    setState(() => _isSaving = true);
    try {
      await FirebaseFirestore.instance.collection('users').doc(_currentUser!.uid).collection('glycemie_history').add({
        'glycemie_mmolL': _glycemieInMmolL,
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
                          _buildMeasurementInput(),
                          const SizedBox(height: 24),
                          _buildModernGlycemieGauge(),
                          const SizedBox(height: 24),
                          _buildInterpretationCard(),
                           const SizedBox(height: 24),
                          _buildHistorySection(),
                          const SizedBox(height: 24),
                          _buildRecommendedReading(),
                          const SizedBox(height: 24),
                          _buildAlarmFeature(),
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
            child: Text(
              'Suivi de Glycémie',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimaryColor),
            ),
          ),
          IconButton(
            icon: Icon(_isSaving ? Icons.pending : Icons.save_outlined, color: AppTheme.textPrimaryColor),
            onPressed: _isSaving ? null : _saveGlycemieResult,
            tooltip: 'Sauvegarder',
          )
        ],
      ),
    );
  }
  
  Widget _buildMeasurementInput() {
    bool isMmolL = _currentUnit == GlycemieUnit.mmolL;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text('Taux de glucose', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              _displayValue.toStringAsFixed(isMmolL ? 1 : 0), 
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 36, fontWeight: FontWeight.bold)
            ),
            const SizedBox(height: 16),
            Slider(
              value: _glycemieInMmolL,
              min: 2.0,
              max: 20.0,
              divisions: ( (20.0 - 2.0) * 10 ).toInt(),
              label: _glycemieInMmolL.toStringAsFixed(1),
              onChanged: (val) {
                setState(() => _glycemieInMmolL = val);
              },
            ),
            const SizedBox(height: 16),
            CupertinoSlidingSegmentedControl<GlycemieUnit>(
              groupValue: _currentUnit,
              children: const {
                GlycemieUnit.mmolL: Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Text('mmol/L')),
                GlycemieUnit.mgdL: Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Text('mg/dL')),
              },
              onValueChanged: (GlycemieUnit? newValue) {
                if (newValue != null) setState(() => _currentUnit = newValue);
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildModernGlycemieGauge() {
    bool isMgdL = _currentUnit == GlycemieUnit.mgdL;
    double min = isMgdL ? 2.0 * _conversionFactor : 2.0;
    double max = isMgdL ? 20.0 * _conversionFactor : 20.0;
    
    // MODIFIÉ : On ajuste l'intervalle des libellés pour le mode mg/dL
    double? labelInterval = isMgdL ? 50 : null; // Affiche un libellé tous les 50 mg/dL pour éviter la superposition

    List<LinearGaugeRange> ranges = isMgdL
      ? [ 
          LinearGaugeRange(startValue: min, endValue: 72, color: Colors.blue.shade300),
          const LinearGaugeRange(startValue: 72, endValue: 180, color: Colors.green),
          LinearGaugeRange(startValue: 180, endValue: max, color: Colors.red),
        ]
      : [ 
          LinearGaugeRange(startValue: min, endValue: 4, color: Colors.blue.shade300),
          const LinearGaugeRange(startValue: 4, endValue: 10, color: Colors.green),
          LinearGaugeRange(startValue: 10, endValue: max, color: Colors.red),
        ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SfLinearGauge(
          minimum: min,
          maximum: max,
          axisLabelStyle: const TextStyle(fontSize: 10),
          axisTrackStyle: const LinearAxisTrackStyle(thickness: 15, edgeStyle: LinearEdgeStyle.bothCurve),
          orientation: LinearGaugeOrientation.horizontal,
          interval: labelInterval, // Utilise l'intervalle dynamique
          ranges: ranges,
          markerPointers: [
            LinearShapePointer(
              value: _displayValue,
              color: AppColors.primaryText,
              height: 20,
              width: 20,
              shapeType: LinearShapePointerType.circle,
            )
          ],
        ),
      ),
    );
  }
  
  Widget _buildInterpretationCard() {
    final interpretationData = _getInterpretation(); // Cast n'est plus nécessaire ici
    final state = interpretationData['state']!;
    final recommendation = interpretationData['recommendation']!;
    
    Color color;
    if (state.contains('Hypo')) { color = Colors.blue.shade300; } 
    else if (state.contains('Normale')) { color = Colors.green; } 
    else { color = Colors.red; } 
    
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: color, size: 28),
                const SizedBox(width: 12),
                Expanded(child: Text('État: $state', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: color))),
              ],
            ),
            const SizedBox(height: 16),
            Text(recommendation, style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5)),
          ],
        ),
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
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const GlycemieHistoryScreen())), 
              child: const Text('Voir tout'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 120,
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('users').doc(_currentUser?.uid).collection('glycemie_history').orderBy('date', descending: true).limit(5).snapshots(),
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
                  final value = (data['glycemie_mmolL'] as double?) ?? 0.0;

                  return Card(
                    child: Container(
                      width: 140,
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(value.toStringAsFixed(1), style: Theme.of(context).textTheme.headlineSmall),
                          const Text('mmol/L'),
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
        'title': 'Comprendre le diabète', 'icon': Icons.medical_information_outlined, 'color': Colors.deepPurple,
        'content': [
           {'subtitle': 'Qu\'est-ce que le diabète ?', 'text': 'Le diabète est une maladie chronique qui apparaît lorsque le pancréas ne produit pas suffisamment d\'insuline ou que l\'organisme n\'utilise pas correctement l\'insuline qu\'il produit. Cela entraîne une concentration de glucose (sucre) élevée dans le sang.'},
        ]
      },
      {
        'title': 'Qu\'est-ce que le diabète de type 2 ?', 'icon': Icons.info_outline, 'color': Colors.blueGrey,
        'content': [
          {'subtitle': 'La forme la plus courante', 'text': 'Le diabète de type 2 résulte d\'une mauvaise utilisation de l\'insuline par l\'organisme. Il est souvent la conséquence d\'un excès pondéral et de l\'inactivité physique, et touche principalement les adultes, bien qu\'il soit de plus en plus observé chez les enfants.'},
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
              imagePath: 'assets/images/articles/placeholder.png',
              content: article['content'] as List<Map<String, String>>,
            ))),
          ),
        )).toList(),
      ],
    );
  }

  Widget _buildAlarmFeature() {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.alarm, color: AppColors.primary),
        title: const Text('Planifier des alarmes'),
        subtitle: const Text('Définissez des rappels pour vos mesures.'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const ReminderScreen()));
        },
      ),
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
}