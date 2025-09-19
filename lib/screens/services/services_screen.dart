// lib/screens/services/services_screen.dart

import 'package:flutter/material.dart';
import 'package:adomed_app/theme/app_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Imports pour tous les écrans de destination
import 'package:adomed_app/screens/bilans/bilans_medicaux_screen.dart';
import 'package:adomed_app/screens/urgence/urgence_categories_screen.dart';
import 'package:adomed_app/screens/consultation/consultation_screen.dart';
import 'package:adomed_app/screens/demander_avis/demander_avis_screen.dart';
import 'package:adomed_app/screens/suivi_medical/suivi_medical_screen.dart';

// Imports pour la section alimentation bébé (ancien et nouvel écran)
import 'package:adomed_app/screens/alimentation_bebe/alimentation_bebe_screen.dart';
import 'package:adomed_app/screens/alimentation_bebe/onboarding_alimentation_screen.dart'; // ✨ IMPORT AJOUTÉ

class ServiceInfo {
  final String title;
  final String description;
  final IconData icon;
  final Color cardColor;

  const ServiceInfo({
    required this.title,
    required this.description,
    required this.icon,
    required this.cardColor,
  });
}

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  final List<ServiceInfo> _services = const [
    ServiceInfo(title: 'Demander un avis', description: 'Discutez avec notre IA Diokara ou un médecin Adomed.', icon: Icons.chat_bubble_outline_rounded, cardColor: AppColors.primary),
    ServiceInfo(title: 'Consultations', description: 'Vous ressentez un mal, consultez un de nos médecins.', icon: Icons.video_call_outlined, cardColor: Color(0xFF3B82F6)),
    ServiceInfo(title: 'Bilans médicaux', description: 'Commandez des bilans médicaux à votre domicile.', icon: Icons.science_outlined, cardColor: Color(0xFF10B981)),
    ServiceInfo(title: 'C.A.T d\'urgence', description: 'Accédez à des conduites à tenir en situation d\'urgence.', icon: Icons.flash_on_rounded, cardColor: Color(0xFFEF4444)),
    ServiceInfo(title: 'Suivi médical', description: 'Suivez votre santé (tension, diabète, obésité) ici !', icon: Icons.monitor_heart_outlined, cardColor: Color(0xFF8B5CF6)),
    ServiceInfo(title: 'Alimentation bébé', description: 'Découvrez nos menus spécial nourrissons !', icon: Icons.child_friendly_outlined, cardColor: Color(0xFFF59E0B)),
  ];

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
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(32),
                topRight: Radius.circular(32),
              ),
              child: Container(
                color: AppTheme.backgroundColor.withOpacity(0.95),
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.0),
                      child: Text(
                        'Nos Services',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimaryColor,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        itemCount: _services.length,
                        itemBuilder: (context, index) {
                          final service = _services[index];
                          return _buildServiceCard(context, service);
                        },
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

  Widget _buildRealtimeStat(String serviceTitle) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return const Text('');

    Query? query;
    String label = '';
    String staticStat = '';

    switch (serviceTitle) {
      case 'Demander un avis':
        query = FirebaseFirestore.instance.collection('users').doc(userId).collection('discussions');
        label = 'conversations';
        break;
      case 'Consultations':
        query = FirebaseFirestore.instance.collection('users').doc(userId).collection('discussions').where('type', isEqualTo: 'medecin');
        label = 'consultations';
        break;
      case 'Bilans médicaux':
        query = FirebaseFirestore.instance.collection('bilans').where('uid', isEqualTo: userId);
        label = 'bilans commandés';
        break;
      case 'Suivi médical':
        query = FirebaseFirestore.instance.collection('users').doc(userId).collection('suivi_medical');
        label = 'suivis actifs';
        break;
      default:
        if (serviceTitle == 'C.A.T d\'urgence') staticStat = '+ 45 assistances';
        if (serviceTitle == 'Alimentation bébé') staticStat = '+ 100 menus';
        break;
    }

    if (query == null) {
      return Text(
        staticStat,
        style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(height: 14, width: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white));
        }
        final count = snapshot.data?.docs.length ?? 0;
        return Text(
          '+ $count $label',
          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
        );
      },
    );
  }

  Widget _buildServiceCard(BuildContext context, ServiceInfo service) {
    final Color darkerColor = Color.lerp(service.cardColor, Colors.black, 0.2)!;

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      color: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _navigateToService(context, service.title),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [service.cardColor, darkerColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(service.icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      service.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white.withOpacity(0.9)),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    _buildRealtimeStat(service.title),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToService(BuildContext context, String serviceTitle) {
    Widget? targetScreen;
    switch (serviceTitle) {
      case 'Demander un avis': targetScreen = const DemanderAvisScreen(); break;
      case 'Consultations': targetScreen = const ConsultationScreen(); break;
      case 'Bilans médicaux': targetScreen = const BilansMedicauxScreen(); break;
      case 'C.A.T d\'urgence': targetScreen = const UrgenceCategoriesScreen(); break;
      case 'Suivi médical': targetScreen = const SuiviMedicalScreen(); break;
      
      // 👇 LA MODIFICATION EST APPLIQUÉE ICI 👇
      case 'Alimentation bébé': 
        targetScreen = const OnboardingAlimentationScreen(); 
        break;
    }
    
    if (targetScreen != null) {
      final screen = targetScreen;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => screen),
      );
    }
  }
}