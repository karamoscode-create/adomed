import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BilansPrescritsScreen extends StatefulWidget {
  const BilansPrescritsScreen({super.key});

  @override
  State<BilansPrescritsScreen> createState() => _BilansPrescritsScreenState();
}

class _BilansPrescritsScreenState extends State<BilansPrescritsScreen> {
  bool _uploading = false;

  Future<void> _uploadPrescription() async {
    try {
      // Vérifier si l'utilisateur est connecté
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showErrorSnackBar('Utilisateur non connecté');
        return;
      }

      // Sélectionner l'image
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (picked == null) return;

      setState(() => _uploading = true);

      // Upload vers Firebase Storage
      final uid = user.uid;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = FirebaseStorage.instance
          .ref('prescriptions/$uid/$fileName');
      
      final uploadTask = ref.putFile(File(picked.path));
      await uploadTask;
      final url = await ref.getDownloadURL();

      // Sauvegarder dans Firestore
      await FirebaseFirestore.instance.collection('bilans').add({
        'uid': uid,
        'type': 'prescrit',
        'prescriptionUrl': url,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'totalPrice': 0, // admin fixera
      });

      if (!mounted) return;
      
      // Afficher un message de succès
      _showSuccessSnackBar('Ordonnance uploadée avec succès');
      
      setState(() => _uploading = false);
      Navigator.pop(context);
      
    } catch (e) {
      if (!mounted) return;
      setState(() => _uploading = false);
      _showErrorSnackBar('Erreur lors de l\'upload: ${e.toString()}');
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Bilan prescrit'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_uploading) ...[
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                const Text(
                  'Upload en cours...',
                  style: TextStyle(fontSize: 16),
                ),
              ] else ...[
                Icon(
                  Icons.upload_file,
                  size: 64,
                  color: Colors.grey[600],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Téléchargez votre ordonnance',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Formats acceptés: JPG, PNG\nTaille max: 10MB',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: _uploadPrescription,
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Télécharger l\'ordonnance'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0066CC),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}