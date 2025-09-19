// lib/screens/auth/register_steps/security_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:adomed_app/theme/app_theme.dart';

class SecurityScreen extends StatefulWidget {
  final String fullName;
  final String dateOfBirth;
  final String country;
  final String city;
  final String phone;

  const SecurityScreen({
    super.key,
    required this.fullName,
    required this.dateOfBirth,
    required this.country,
    required this.city,
    required this.phone,
  });

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _finalizeRegistration() async {
    if (!_formKey.currentState!.validate() || _isLoading) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // ✅ LOGIQUE MISE À JOUR ICI
      // 1. On transforme le numéro de téléphone en un email unique
      final String email = '${widget.phone}@adomed.app';
      final String password = _passwordController.text;

      // 2. On crée le compte avec cet email et le mot de passe
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (user == null) {
        throw Exception("La création de l'utilisateur a échoué.");
      }
      
      // 3. On enregistre toutes les informations dans Firestore
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'fullName': widget.fullName,
        'dateOfBirth': widget.dateOfBirth,
        'country': widget.country,
        'city': widget.city,
        'phoneNumber': widget.phone,
        'email': email, // On sauvegarde l'email unique
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
      }

    } on FirebaseAuthException catch (e) {
      if(mounted) {
        setState(() {
          if (e.code == 'email-already-in-use') {
            _errorMessage = 'Ce numéro de téléphone est déjà utilisé par un autre compte.';
          } else {
            _errorMessage = e.message ?? "Une erreur est survenue.";
          }
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Inscription (Étape 4/4)')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Sécurisez votre compte.', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text('Ce mot de passe vous servira pour vous connecter avec votre numéro.', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 40),

              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Mot de passe"),
                validator: (value) => (value == null || value.length < 6) ? '6 caractères minimum.' : null,
              ),

              const SizedBox(height: 20),
              
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Confirmez le mot de passe"),
                validator: (value) => (value != _passwordController.text) ? 'Les mots de passe ne correspondent pas.' : null,
              ),

              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.redAccent),
                    textAlign: TextAlign.center,
                  ),
                ),

              const SizedBox(height: 60),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _finalizeRegistration,
                  child: _isLoading 
                      ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                      : const Text('Terminer l\'inscription'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}