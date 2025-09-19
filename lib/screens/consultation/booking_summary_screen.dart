// lib/screens/consultation/booking_summary_screen.dart
import 'package:flutter/material.dart';

class BookingSummaryScreen extends StatelessWidget {
  final Map<String, dynamic> medecin;
  final DateTime date;
  final String hour;
  final String symptom; // ✅ Le paramètre ajouté

  const BookingSummaryScreen({
    super.key,
    required this.medecin,
    required this.date,
    required this.hour,
    required this.symptom, // ✅ Le symptôme est maintenant requis
  });

  @override
  Widget build(BuildContext context) {
    const int fraisTransport = 2000;
    const int montantConsultation = 25000;
    const int total = fraisTransport + montantConsultation;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Récapitulatif'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Infos générales
            Text(
              'Consultation ${medecin['speciality']}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _InfoRow(label: 'Médecin', value: medecin['name']),
            _InfoRow(label: 'Motif', value: symptom), // ✅ La ligne ajoutée pour afficher le symptôme
            _InfoRow(
                label: 'Date', value: '${date.day}/${date.month}/${date.year}'),
            _InfoRow(label: 'Heure', value: hour),
            const _InfoRow(
                label: 'Localisation', value: 'Rue des épervies de Bassam'),
            const _InfoRow(
                label: 'Frais de transport', value: '$fraisTransport F CFA'),
            const _InfoRow(
                label: 'Montant consultation',
                value: '$montantConsultation F CFA'),
            const Divider(height: 32),
            const _InfoRow(
              label: 'Total à payer',
              value: '$total F CFA',
              valueStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Color(0xFF1E9BBA),
              ),
            ),
            const Spacer(),

            // Confidentialité
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Consultation confidentielle et sécurisée. '
                'Vos échanges et données de santé sont entièrement protégés.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 16),

            // Bouton final
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO : intégrer la logique de paiement ou confirmation
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Rendez-vous confirmé !')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E9BBA),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  'Confirmer le rendez-vous',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? valueStyle;

  const _InfoRow({
    required this.label,
    required this.value,
    this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(
            value,
            style: valueStyle ?? const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}