// lib/screens/dossier/ordonnances_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:adomed_app/theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class OrdonnanceItem {
  final String id;
  final String doctorName;
  final DateTime date;
  final String pdfUrl;

  OrdonnanceItem({
    required this.id,
    required this.doctorName,
    required this.date,
    required this.pdfUrl,
  });

  factory OrdonnanceItem.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return OrdonnanceItem(
      id: doc.id,
      doctorName: data['doctorName'] ?? 'Médecin inconnu',
      date: (data['date'] as Timestamp).toDate(),
      pdfUrl: data['pdfUrl'] ?? '',
    );
  }
}

class OrdonnancesScreen extends StatefulWidget {
  const OrdonnancesScreen({super.key});

  @override
  State<OrdonnancesScreen> createState() => _OrdonnancesScreenState();
}

class _OrdonnancesScreenState extends State<OrdonnancesScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  bool _isUploading = false;

  Future<void> _uploadDocument() async {
    if (currentUser == null) return;
    
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() => _isUploading = true);
      
      File file = File(result.files.single.path!);
      String fileName = result.files.single.name;

      try {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('ordonnances/${currentUser!.uid}/$fileName');
            
        final uploadTask = storageRef.putFile(file);
        final snapshot = await uploadTask.whenComplete(() {});
        final downloadUrl = await snapshot.ref.getDownloadURL();

        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser!.uid)
            .collection('ordonnances')
            .add({
          'doctorName': 'Document importé',
          'pdfUrl': downloadUrl,
          'date': Timestamp.now(),
        });
        
        if(mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ordonnance ajoutée avec succès !')),
          );
        }

      } catch (e) {
        if(mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur de téléchargement: $e')),
          );
        }
      } finally {
        if(mounted) {
          setState(() => _isUploading = false);
        }
      }
    }
  }
  
  Future<void> _openPdf(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Impossible d\'ouvrir le document : $url')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _isUploading ? null : _uploadDocument,
        backgroundColor: AppColors.primary,
        tooltip: 'Ajouter une ordonnance',
        child: _isUploading
          ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
          : const Icon(Icons.upload_file, color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser?.uid)
            .collection('ordonnances')
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Une erreur s'est produite : ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  'Aucune ordonnance disponible.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ),
            );
          }

          final ordonnances = snapshot.data!.docs.map((doc) => OrdonnanceItem.fromFirestore(doc)).toList();

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 80),
            itemCount: ordonnances.length,
            itemBuilder: (context, index) {
              final ordonnance = ordonnances[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: ListTile(
                  leading: const Icon(Icons.receipt_long_outlined, color: Colors.purple),
                  title: Text(
                    ordonnance.doctorName == 'Document importé' 
                      ? ordonnance.pdfUrl.split('%2F').last.split('?').first.replaceAll('%20', ' ') // Nom du fichier
                      : 'Ordonnance du Dr. ${ordonnance.doctorName}', 
                    style: const TextStyle(fontWeight: FontWeight.bold)
                  ),
                  subtitle: Text(DateFormat('dd MMMM yyyy', 'fr_FR').format(ordonnance.date)),
                  trailing: const Icon(Icons.visibility_outlined),
                  onTap: () => _openPdf(ordonnance.pdfUrl),
                ),
              );
            },
          );
        },
      ),
    );
  }
}