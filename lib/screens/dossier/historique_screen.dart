// lib/screens/dossier/historique_screen.dart
import 'package:flutter/material.dart';

class HistoriqueScreen extends StatelessWidget {
  const HistoriqueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: const [
          ListTile(
            title: Text('Antécédents personnels'),
            subtitle: Text('Diabète, Hypertension...'),
            trailing: Icon(Icons.edit),
          ),
          ListTile(
            title: Text('Antécédents familiaux'),
            subtitle: Text('AVC, Cancer...'),
            trailing: Icon(Icons.edit),
          ),
          ListTile(
            title: Text('Allergies connues'),
            subtitle: Text('Aucune pour le moment'),
            trailing: Icon(Icons.edit),
          ),
        ],
      ),
    );
  }
}
