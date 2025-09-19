// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'firebase_options.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:adomed_app/theme/app_theme.dart';
import 'package:adomed_app/screens/splash/splash_screen.dart'; // Importez le nouveau SplashScreen
import 'package:adomed_app/screens/home/welcome_screen.dart';
import 'package:adomed_app/screens/home/home_screen.dart';
import 'package:adomed_app/screens/auth/login_screen.dart';
import 'package:adomed_app/screens/auth/register_screen.dart';
import 'package:provider/provider.dart';
import 'package:adomed_app/models/cart_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Chargement du fichier .env
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print("Fichier .env non trouvé, utilisation des valeurs par défaut");
  }
  
  // Initialisation Firebase
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  // Activation Firebase App Check
  try {
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.debug,
      appleProvider: AppleProvider.debug,
    );
  } catch (e) {
    print("Erreur Firebase App Check: $e");
  }

  await initializeDateFormatting('fr_FR', null);
  runApp(const AdomedApp());
}

class AdomedApp extends StatelessWidget {
  const AdomedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CartModel(),
      child: MaterialApp(
        title: 'ADOMED',
        theme: AppTheme.lightTheme,
        home: const SplashScreen(), // Changez la page d'accueil pour le nouveau SplashScreen
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('fr', 'FR'),
        ],
        locale: const Locale('fr'),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/home': (context) => const HomeScreen(),
          '/welcome': (context) => const WelcomeScreen(),
        },
      ),
    );
  }
}