// lib/screens/dossier/resultats_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:adomed_app/theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';


// Modèle de données pour structurer un résultat
class ResultatItem {
  final String id;
  final String title;
  final DateTime date;
  final String pdfUrl;

  ResultatItem({
    required this.id,
    required this.title,
    required this.date,
    required this.pdfUrl,
  });

  factory ResultatItem.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return ResultatItem(
      id: doc.id,
      title: data['title'] ?? 'Titre non disponible',
      date: (data['date'] as Timestamp).toDate(),
      pdfUrl: data['pdfUrl'] ?? '',
    );
  }
}

class ResultatsScreen extends StatefulWidget {
  const ResultatsScreen({super.key});

  @override
  State<ResultatsScreen> createState() => _ResultatsScreenState();
}

class _ResultatsScreenState extends State<ResultatsScreen> {
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
            .child('resultats_bilans/${currentUser!.uid}/$fileName');
            
        final uploadTask = storageRef.putFile(file);
        final snapshot = await uploadTask.whenComplete(() {});
        final downloadUrl = await snapshot.ref.getDownloadURL();

        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser!.uid)
            .collection('resultats')
            .add({
          'title': fileName,
          'pdfUrl': downloadUrl,
          'date': Timestamp.now(),
        });
        
        if(mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Résultat ajouté avec succès !')),
          );
        }

      } catch (e) {
        if(mounted){
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
        tooltip: 'Ajouter un résultat',
        child: _isUploading
          ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
          : const Icon(Icons.upload_file, color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser?.uid)
            .collection('resultats')
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
                  'Aucun résultat disponible.\nVos résultats de bilans et documents importés seront affichés ici.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ),
            );
          }
          
          final resultats = snapshot.data!.docs.map((doc) => ResultatItem.fromFirestore(doc)).toList();

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 80), // Padding pour le FAB
            itemCount: resultats.length,
            itemBuilder: (context, index) {
              final resultat = resultats[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: ListTile(
                  leading: const Icon(Icons.description_outlined, color: AppColors.primary),
                  title: Text(resultat.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(DateFormat('dd MMMM yyyy', 'fr_FR').format(resultat.date)),
                  trailing: const Icon(Icons.visibility_outlined),
                  onTap: () => _openPdf(resultat.pdfUrl),
                ),
              );
            },
          );
        },
      ),
    );
  }
}