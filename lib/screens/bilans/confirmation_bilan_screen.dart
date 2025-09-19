// lib/screens/bilans/confirmation_bilan_screen.dart

import 'package:flutter/material.dart';
import 'package:adomed_app/theme/app_theme.dart';
import 'package:intl/intl.dart';
import 'paiement_bilan_screen.dart';

class ConfirmationBilanScreen extends StatefulWidget {
  final List<Map<String, dynamic>> selectedAnalyses;
  final int totalPrice;
  final String? packName;

  const ConfirmationBilanScreen({
    super.key,
    required this.selectedAnalyses,
    required this.totalPrice,
    this.packName,
  });

  @override
  State<ConfirmationBilanScreen> createState() => _ConfirmationBilanScreenState();
}

class _ConfirmationBilanScreenState extends State<ConfirmationBilanScreen> {
  DateTime? _selectedDate;
  Map<String, dynamic>? _selectedLocationData; // MODIFICATION : Stocke l'objet complet
  int _shippingCost = 0;

  // MODIFICATION : Structure de données plus robuste pour les lieux
  final List<Map<String, dynamic>> locationsData = [
    {'name': 'Abidjan', 'price': 3000},
    {'name': 'Grand Abidjan (Cocody, Bassam, etc.)', 'price': 5000},
  ];

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime(2027),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _onLocationChanged(Map<String, dynamic>? value) {
    setState(() {
      _selectedLocationData = value;
      if (value != null) {
        _shippingCost = value['price'] as int;
      } else {
        _shippingCost = 0;
      }
    });
  }

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
                              'Confirmation',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimaryColor),
                            ),
                          ),
                          const SizedBox(width: 48),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Récapitulatif de votre commande', style: Theme.of(context).textTheme.headlineSmall),
                            const SizedBox(height: 24),
                            _buildRecapCard(context),
                            const SizedBox(height: 24),
                            _buildDateTimeLocationCard(context),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                      child: ElevatedButton(
                        onPressed: _selectedDate == null || _selectedLocationData == null
                            ? null
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PaiementBilanScreen(
                                      analyses: widget.selectedAnalyses,
                                      totalPrice: widget.totalPrice + _shippingCost,
                                      type: widget.packName ?? 'Bilan à la carte',
                                      date: _selectedDate!,
                                      location: "${_selectedLocationData!['name']} (${_selectedLocationData!['price']} FCFA)",
                                    ),
                                  ),
                                );
                              },
                        child: const Text('Procéder à la commande'),
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

  Widget _buildRecapCard(BuildContext context) {
    // ... (le contenu de cette carte ne change pas)
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.packName ?? 'Bilan à la carte', style: Theme.of(context).textTheme.titleLarge),
            const Divider(height: 24),
            ...widget.selectedAnalyses.map((analyse) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(analyse['name'], style: Theme.of(context).textTheme.bodyLarge)),
                  if (analyse['price'] != 0)
                    Text('${analyse['price']} FCFA', style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            )),
            if (_shippingCost > 0) ...[
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Frais de déplacement', style: Theme.of(context).textTheme.bodyLarge),
                  Text('$_shippingCost FCFA', style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ],
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total', style: Theme.of(context).textTheme.titleLarge),
                Text('${widget.totalPrice + _shippingCost} FCFA', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primary)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimeLocationCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Date et lieu du prélèvement', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today, color: AppColors.primary),
              title: Text(_selectedDate == null ? 'Choisir la date' : 'Date: ${DateFormat('dd/MM/yyyy', 'fr_FR').format(_selectedDate!)}'),
              onTap: () => _selectDate(context),
            ),
            const Divider(),
            // MODIFICATION : Le Dropdown est maintenant plus propre et sans overflow
            DropdownButtonFormField<Map<String, dynamic>>(
              decoration: const InputDecoration(
                labelText: 'Lieu de prélèvement',
                prefixIcon: Icon(Icons.location_on_outlined, color: AppColors.primary),
                border: InputBorder.none,
                filled: false,
              ),
              value: _selectedLocationData,
              isExpanded: true, // Permet au texte de prendre la place nécessaire
              items: locationsData.map((Map<String, dynamic> location) {
                return DropdownMenuItem<Map<String, dynamic>>(
                  value: location,
                  child: Text("${location['name']} (+${location['price']} FCFA)"),
                );
              }).toList(),
              onChanged: _onLocationChanged,
            ),
          ],
        ),
      ),
    );
  }
}