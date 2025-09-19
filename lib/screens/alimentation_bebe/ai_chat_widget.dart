// lib/screens/alimentation_bebe/ai_chat_widget.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:adomed_app/theme/app_theme.dart';
// TODO: Importez la page de détails de vos recettes
// import 'package:adomed_app/screens/alimentation_bebe/recipe_detail_screen.dart';

// MODÈLE DE MESSAGE ENRICHI
class EmmaChatMessage {
  final String text;
  final bool isUser;
  final bool isSystemMessage;
  final String? recipeId;
  final String? recipeTitle;

  EmmaChatMessage({
    required this.text,
    required this.isUser,
    this.isSystemMessage = false,
    this.recipeId,
    this.recipeTitle,
  });
}

class AiChatWidget extends StatefulWidget {
  final String conversationId;
  final VoidCallback onClose;

  const AiChatWidget({
    super.key,
    required this.conversationId,
    required this.onClose,
  });

  @override
  State<AiChatWidget> createState() => _AiChatWidgetState();
}

class _AiChatWidgetState extends State<AiChatWidget> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  late final GenerativeModel _model;
  late final ChatSession _chatSession;
  final FlutterTts flutterTts = FlutterTts();
  final _currentUserId = FirebaseAuth.instance.currentUser!.uid;

  final _systemPrompt = Content.text(
      "Tu es Emma, une assistante virtuelle maman ivoirienne et experte en nutrition pour bébé. "
      "Ton ton est chaleureux, bienveillant et posé. "
      "Ton but est d'aider les parents à trouver des repas pour leur bébé. "
      "Pour cela, tu dois d'abord connaître l'âge du bébé. Si tu ne le connais pas, pose la question. "
      "Une fois que tu as l'âge, utilise l'outil 'rechercherRecettes'. "
      "IMPORTANT : Quand tu utilises les résultats de l'outil pour suggérer une recette, ta réponse FINALE doit être un objet JSON valide, et rien d'autre. "
      "Le JSON doit avoir cette structure exacte : "
      "{ \"responseText\": \"Le texte de ta réponse ici.\", \"suggestedRecipe\": { \"id\": \"l_id_de_la_recette\", \"title\": \"Le titre de la recette\" } } "
      "Si tu ne suggères pas de recette, réponds simplement en texte normal."
  );

  @override
  void initState() {
    super.initState();
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('GEMINI_API_KEY manquante dans .env');
    }

    final generationConfig = GenerationConfig(
      temperature: 0.8,
      responseMimeType: 'application/json',
    );
    final tools = [
      Tool(functionDeclarations: [
        FunctionDeclaration(
          'rechercherRecettes',
          'Recherche des recettes pour bébé dans la base de données de l\'application.',
          Schema(SchemaType.object, properties: {
            'ageEnMois': Schema(SchemaType.integer, description: 'L\'âge du bébé en mois.'),
            'preferences': Schema(SchemaType.string, description: 'Préférences ou ingrédients clés mentionnés par le parent (ex: "carotte", "poulet", "sans arachide").'),
          }, requiredProperties: ['ageEnMois']),
        )
      ])
    ];

    _model = GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: apiKey,
      tools: tools,
      generationConfig: generationConfig,
    );
    
    _chatSession = _model.startChat(history: [_systemPrompt]);
    _checkAndAddWelcomeMessage();
    _setLanguageAndVoice();
  }

  Future<List<Map<String, String>>> _findRecipesInFirestore({required int ageEnMois, String? preferences}) async {
    String ageGroup;
    if (ageEnMois >= 4 && ageEnMois <= 6) ageGroup = '4-6 mois';
    else if (ageEnMois > 6 && ageEnMois <= 8) ageGroup = '6-8 mois';
    else if (ageEnMois > 8 && ageEnMois <= 12) ageGroup = '8-12 mois';
    else if (ageEnMois > 12 && ageEnMois <= 18) ageGroup = '12-18 mois';
    else ageGroup = '18+ mois';
    
    Query query = FirebaseFirestore.instance.collection('recipes').where('ageGroup', isEqualTo: ageGroup);
    
    final snapshot = await query.limit(10).get();

    if (snapshot.docs.isEmpty) return [];

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>?;
      final title = data?['title'] as String? ?? 'Recette sans nom';
      return {'id': doc.id, 'title': title};
    }).toList();
  }

  Future<void> _sendMessage() async {
    final userMessage = _controller.text.trim();
    if (userMessage.isEmpty || _isLoading) return;
  
    _controller.clear();
    setState(() => _isLoading = true);
  
    try {
      await _addMessageToFirebase(userMessage, isUser: true);
      
      var response = await _chatSession.sendMessage(Content.text(userMessage));
      
      while (response.functionCalls.isNotEmpty) {
        final functionCall = response.functionCalls.first;
  
        if (functionCall.name == 'rechercherRecettes') {
          final age = functionCall.args['ageEnMois'] as int;
          final prefs = functionCall.args['preferences'] as String?;
          final searchResults = await _findRecipesInFirestore(ageEnMois: age, preferences: prefs);
          final responseData = {'recipes': searchResults};
  
          response = await _chatSession.sendMessage(
            Content.functionResponse(functionCall.name, responseData),
          );
        }
      }
  
      final aiResponseText = response.text;
      if (aiResponseText != null && aiResponseText.isNotEmpty) {
        try {
          final decodedJson = jsonDecode(aiResponseText) as Map<String, dynamic>;
          final text = decodedJson['responseText'] as String;
          final recipe = decodedJson['suggestedRecipe'] as Map<String, dynamic>?;
          
          await _addMessageToFirebase(
            text, 
            isUser: false, 
            recipeId: recipe?['id'] as String?,
            recipeTitle: recipe?['title'] as String?,
          );

        } catch (e) {
          await _addMessageToFirebase(aiResponseText, isUser: false);
        }
      }
  
    } catch (e) {
      await _addMessageToFirebase("Désolé, une erreur est survenue : $e", isUser: false);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _addMessageToFirebase(String text, {
    required bool isUser,
    String? recipeId,
    String? recipeTitle,
  }) async {
    final messageData = {
      'text': text,
      'isUser': isUser,
      'timestamp': Timestamp.now(),
      'recipeId': recipeId,
      'recipeTitle': recipeTitle,
    };
    messageData.removeWhere((key, value) => value == null);

    await FirebaseFirestore.instance
        .collection('users')
        .doc(_currentUserId)
        .collection('emma_discussions')
        .doc(widget.conversationId)
        .collection('messages')
        .add(messageData);
  }
  
  @override
  void dispose() {
    _controller.dispose();
    flutterTts.stop();
    _scrollController.dispose();
    super.dispose();
  }
  
  Future<void> _setLanguageAndVoice() async {
    await flutterTts.setLanguage('fr-FR');
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _checkAndAddWelcomeMessage() async {
    final messagesSnapshot = await FirebaseFirestore.instance.collection('users').doc(_currentUserId).collection('emma_discussions').doc(widget.conversationId).collection('messages').get();
    if (messagesSnapshot.docs.isEmpty) {
      final welcomeMessage = "Bonjour ! Je suis Emma. Comment puis-je vous aider aujourd'hui avec les repas de votre bébé ?";
      await _addMessageToFirebase(welcomeMessage, isUser: false);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emma, votre assistante', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: widget.onClose),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users').doc(_currentUserId).collection('emma_discussions').doc(widget.conversationId).collection('messages').orderBy('timestamp', descending: true).snapshots(),
              builder: (context, msgSnapshot) {
                if (msgSnapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                if (!msgSnapshot.hasData || msgSnapshot.data!.docs.isEmpty) return const Center(child: Text('Commencez la conversation avec Emma.'));
                
                final messages = msgSnapshot.data!.docs;
                final allMessages = messages.map((doc) {
                   final data = doc.data() as Map<String, dynamic>;
                    return EmmaChatMessage(
                      text: data['text'] ?? '', 
                      isUser: data['isUser'] ?? false,
                      recipeId: data['recipeId'] as String?,
                      recipeTitle: data['recipeTitle'] as String?,
                    );
                }).toList();

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: allMessages.length,
                  itemBuilder: (context, index) => _buildMessageBubble(allMessages[index]),
                );
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(EmmaChatMessage message) {
    final bool canBeSpoken = !message.isUser && message.text.isNotEmpty;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              decoration: BoxDecoration(
                color: message.isUser ? AppColors.primary : AppColors.cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Flexible(child: Text(message.text, style: TextStyle(color: message.isUser ? Colors.white : AppColors.primaryText))),
                      if (canBeSpoken) ...[
                        const SizedBox(width: 8),
                        InkWell(
                          child: Icon(Icons.volume_up_outlined, size: 20, color: (message.isUser ? Colors.white : AppColors.primaryText).withOpacity(0.7)),
                          onTap: () async => await flutterTts.speak(message.text),
                        ),
                      ]
                    ],
                  ),
                  if (!message.isUser && message.recipeId != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: ActionChip(
                        elevation: 2,
                        backgroundColor: Colors.white,
                        avatar: Icon(Iconsax.document, size: 16, color: AppColors.primary),
                        label: Text(
                          "Voir la recette : ${message.recipeTitle ?? ''}",
                          style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                        ),
                        onPressed: () {
                           print("Navigation vers la recette ID: ${message.recipeId}");
                           // REMPLACEZ CECI PAR VOTRE VRAIE NAVIGATION
                           // Navigator.push(context, MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipeId: message.recipeId!)));
                        },
                      ),
                    )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.grey.shade200))),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                enabled: !_isLoading,
                decoration: InputDecoration(
                  hintText: 'Posez votre question à Emma...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
                  filled: true,
                  fillColor: AppColors.cardColor,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _isLoading ? null : _sendMessage,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: const CircleBorder(), padding: const EdgeInsets.all(12)),
              child: _isLoading
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Iconsax.send_1, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}