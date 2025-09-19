// lib/screens/chat/diokara_screen.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Importez le package http
import 'dart:convert'; // Importez pour travailler avec JSON

class DiokaraScreen extends StatefulWidget {
  const DiokaraScreen({super.key});

  @override
  State<DiokaraScreen> createState() => _DiokaraScreenState();
}

class _DiokaraScreenState extends State<DiokaraScreen> {
  final TextEditingController _ctrl = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];

  // Votre clé API Gemini. À PRODUIRE : NE PAS LA LAISSER EN DUR POUR LA PRODUCTION
  // Obtenez une clé API Gemini spécifique depuis Google AI Studio ou Google Cloud Console
  final String _geminiApiKey =
      "AIzaSyCaObSqLGM0DqNxJlWO6uOZ540A5BgH6iU"; // Remplacez par votre VRAIE clé API Gemini si celle-ci ne fonctionne pas
  final String _geminiModel = "gemini-pro"; // Le modèle Gemini simple

  @override
  void initState() {
    super.initState();
    // Message de bienvenue initial de Diokara
    _messages.add({
      'text':
          'Bonjour, je suis Diokara, votre assistant de santé virtuel. Décrivez-moi vos symptômes, et je pourrai vous donner des informations générales. N\'oubliez pas que je ne remplace pas une consultation médicale professionnelle.',
      'isUser': false,
    });
  }

  void _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'text': text, 'isUser': true});
      _ctrl.clear();
    });

    // Afficher un message de chargement de l'IA
    setState(() {
      _messages.add({
        'text': 'Diokara est en train de réfléchir...',
        'isUser': false,
        'isLoading': true
      });
    });

    try {
      final response = await http.post(
        Uri.parse(
            'https://generativelanguage.googleapis.com/v1beta/models/$_geminiModel:generateContent?key=$_geminiApiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {
                  "text":
                      "En tant qu'assistant de santé Diokara, réponds aux symptômes suivants : \"$text\". Donne une cause possible générale, des conseils immédiats non-médicaux (par exemple, boire de l'eau, se reposer), et un avis sur la nécessité de consulter un professionnel. Rappelle toujours que tu ne remplaces pas un avis médical et qu'il faut consulter un professionnel de santé pour un diagnostic ou un traitement."
                }
              ]
            }
          ]
        }),
      );

      // Supprimer le message de chargement
      setState(() {
        _messages.removeWhere((msg) => msg['isLoading'] == true);
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final geminiResponse =
            data['candidates'][0]['content']['parts'][0]['text'];

        setState(() {
          _messages.add({
            'text': geminiResponse,
            'isUser': false,
          });
        });
      } else {
        setState(() {
          _messages.add({
            'text':
                'Diokara: Désolé, je n\'ai pas pu traiter votre demande pour le moment. Erreur: ${response.statusCode}',
            'isUser': false,
          });
        });
        print(
            'Erreur d\'API Gemini: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      // Supprimer le message de chargement en cas d'erreur
      setState(() {
        _messages.removeWhere((msg) => msg['isLoading'] == true);
      });
      setState(() {
        _messages.add({
          'text':
              'Diokara: Une erreur est survenue lors de la communication avec l\'IA. Veuillez réessayer.',
          'isUser': false,
        });
      });
      print('Erreur de connexion: $e');
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('DIOKARA'), centerTitle: true),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: _messages.length,
              itemBuilder: (_, i) {
                final m = _messages[i];
                return Align(
                  alignment: m['isUser'] as bool
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: m['isUser'] as bool
                          ? Colors.blue.shade50
                          : (m['isLoading'] == true
                              ? Colors.grey.shade300
                              : Colors.grey
                                  .shade200), // Couleur grise pour le chargement
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      m['text'] as String,
                      style: TextStyle(
                          color:
                              m['isUser'] as bool ? Colors.blue : Colors.black),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    decoration: InputDecoration(
                      hintText: 'Décrivez vos symptômes…',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFF1E9BBA)),
                  onPressed: _send,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
