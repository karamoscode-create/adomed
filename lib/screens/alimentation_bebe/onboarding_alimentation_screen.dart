// lib/screens/alimentation_bebe/onboarding_alimentation_screen.dart

import 'package:flutter/material.dart';
import 'package:adomed_app/theme/app_theme.dart'; // Vous avez déjà ça
import 'alimentation_bebe_screen.dart'; // L'écran de destination

class OnboardingAlimentationScreen extends StatefulWidget {
  const OnboardingAlimentationScreen({super.key});

  @override
  State<OnboardingAlimentationScreen> createState() => _OnboardingAlimentationScreenState();
}

// Classe pour contenir les données de chaque page
class OnboardingPageData {
  final String imagePath;
  final String title;
  final String description;

  OnboardingPageData({
    required this.imagePath,
    required this.title,
    required this.description,
  });
}

class _OnboardingAlimentationScreenState extends State<OnboardingAlimentationScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Définissez ici le contenu de vos pages d'onboarding
  final List<OnboardingPageData> _pages = [
    OnboardingPageData(
      imagePath: 'assets/images/onboarding_bebe_1.png', // Remplacez par vos images
      title: 'Découvrez la diversification',
      description: 'Des recettes saines et adaptées, inspirées de la richesse culinaire africaine pour votre bébé.',
    ),
    OnboardingPageData(
      imagePath: 'assets/images/onboarding_bebe_2.png',
      title: 'Planifiez les repas en un clin d\'œil',
      description: 'Générez un planning de repas pour la semaine et ne soyez plus jamais à court d\'idées.',
    ),
    OnboardingPageData(
      imagePath: 'assets/images/onboarding_bebe_3.png',
      title: 'Conseils et astuces à portée de main',
      description: 'Accédez à des articles nutritifs et enregistrez vos recettes favorites pour les retrouver facilement.',
    ),
  ];

  void _goToAlimentationScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AlimentationBebeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Le PageView pour les images et le contenu
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              return OnboardingPage(data: _pages[index]);
            },
          ),

          // Le bouton "Skip" (Ignorer)
          Positioned(
            top: 50.0,
            right: 20.0,
            child: TextButton(
              onPressed: _goToAlimentationScreen,
              child: const Text('Passer', style: TextStyle(color: Colors.black54, fontSize: 16)),
            ),
          ),
          
          // La carte du bas avec le bouton fléché
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildBottomCard(),
          )
        ],
      ),
    );
  }

  Widget _buildBottomCard() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.35,
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(50.0),
          topRight: Radius.circular(50.0),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Utilisation de AnimatedSwitcher pour un effet de fondu sur le texte
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: Column(
              // La clé est importante pour qu'AnimatedSwitcher détecte le changement
              key: ValueKey<int>(_currentPage),
              children: [
                Text(
                  _pages[_currentPage].title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(
                  _pages[_currentPage].description,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          FloatingActionButton(
            onPressed: () {
              if (_currentPage < _pages.length - 1) {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                );
              } else {
                _goToAlimentationScreen();
              }
            },
            backgroundColor: AppColors.primary, // ✨ On utilise la couleur primaire de votre thème !
            child: const Icon(Icons.arrow_forward, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

// Widget réutilisable pour afficher une page (image de fond)
class OnboardingPage extends StatelessWidget {
  final OnboardingPageData data;

  const OnboardingPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(data.imagePath),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}