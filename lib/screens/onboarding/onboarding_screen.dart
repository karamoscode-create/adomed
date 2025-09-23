// lib/screens/onboarding/onboarding_screen.dart

import 'package:flutter/material.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_theme.dart';
import '../home/welcome_screen.dart';
import 'onboarding_model.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPageModel> pages = [
    OnboardingPageModel(
      imageUrl: 'assets/images/onboarding1.png',
      title: 'Bienvenue sur Adomed !',
      description: 'Votre santé à portée de main. Découvrez nos services médicaux innovants.',
    ),
    OnboardingPageModel(
      imageUrl: 'assets/images/onboarding2.png',
      title: 'Consultations en ligne',
      description: 'Accédez à des médecins qualifiés 24/7. Obtenez des conseils personnalisés.',
    ),
    OnboardingPageModel(
      imageUrl: 'assets/images/onboarding3.png',
      title: 'Moniteur de Santé Connecté',
      description: 'Suivez vos bilans, gérez vos abonnements et gagnez des points de parrainage.',
    ),
    OnboardingPageModel(
      imageUrl: 'assets/images/onboarding4.png',
      title: 'Marché de Produits de Santé',
      description: 'Trouvez une large gamme de produits de santé et de bien-être de qualité.',
    ),
  ];

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  // Cette fonction est appelée pour passer l'onboarding et aller à l'écran de connexion
  void _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
      );
    }
  }

  void _nextPage() {
    if (_currentPage < pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeIn,
      );
    } else {
      // Si on est sur la dernière page, on termine l'onboarding
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: pages.length,
            onPageChanged: _onPageChanged,
            itemBuilder: (context, index) {
              final page = pages[index];
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 3,
                    child: Image.asset(
                      page.imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: [
                        Text(
                          page.title,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimaryColor,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          page.description,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppTheme.textSecondaryColor,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 120), // Espace pour les indicateurs et boutons
                ],
              );
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DotsIndicator(
                    dotsCount: pages.length,
                    position: _currentPage.toDouble(), // <-- CORRECTION APPLIQUÉE ICI
                    decorator: DotsDecorator(
                      size: const Size.square(9.0),
                      activeSize: const Size(18.0, 9.0),
                      activeShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                      color: Colors.grey[400]!,
                      activeColor: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Le bouton "Passer" n'apparaît que si on n'est pas sur la dernière page
                        if (_currentPage < pages.length - 1)
                          TextButton(
                            onPressed: _completeOnboarding, // Appelle la même fonction
                            child: Text(
                              'Passer',
                              style: TextStyle(color: AppTheme.textSecondaryColor),
                            ),
                          )
                        else 
                          // Espace vide pour garder le bouton "Démarrer" à droite
                          Container(width: 60),

                        ElevatedButton(
                          onPressed: _nextPage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: Text(
                            _currentPage == pages.length - 1 ? 'Démarrer' : 'Suivant',
                            style: const TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}