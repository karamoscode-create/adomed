// lib/screens/alimentation_bebe/ai_chat_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:adomed_app/theme/app_theme.dart';

class EmmaChatMessage {
  final String text;
  final bool isUser;

  EmmaChatMessage({
    required this.text,
    required this.isUser,
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
      "Ton but est d'aider les parents en leur donnant des conseils et des idées de repas pour leur bébé. "
      "Tu peux poser des questions sur l'âge du bébé pour mieux répondre. "
      "Réponds toujours en texte simple et amical."
  );

  @override
  void initState() {
    super.initState();
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('GEMINI_API_KEY manquante dans .env');
    }
    
    _model = GenerativeModel(
      model: 'gemini-pro', // Utilise un modèle standard sans 'function calling'
      apiKey: apiKey,
    );
    
    _chatSession = _model.startChat(history: [_systemPrompt]);
    _checkAndAddWelcomeMessage();
    _setLanguageAndVoice();
  }

  Future<void> _sendMessage() async {
    final userMessage = _controller.text.trim();
    if (userMessage.isEmpty || _isLoading) return;
  
    _controller.clear();
    setState(() => _isLoading = true);
  
    try {
      await _addMessageToFirebase(userMessage, isUser: true);
      
      final response = await _chatSession.sendMessage(Content.text(userMessage));
      final aiResponseText = response.text;

      if (aiResponseText != null && aiResponseText.isNotEmpty) {
        await _addMessageToFirebase(aiResponseText, isUser: false);
      }
  
    } catch (e) {
      await _addMessageToFirebase("Désolé, une erreur est survenue. Veuillez réessayer.", isUser: false);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _addMessageToFirebase(String text, {required bool isUser}) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(_currentUserId)
        .collection('emma_discussions')
        .doc(widget.conversationId)
        .collection('messages')
        .add({
          'text': text,
          'isUser': isUser,
          'timestamp': Timestamp.now(),
        });
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
    _scrollToBottom();
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
              stream: FirebaseFirestore.instance.collection('users').doc(_currentUserId).collection('emma_discussions').doc(widget.conversationId).collection('messages').orderBy('timestamp').snapshots(),
              builder: (context, msgSnapshot) {
                if (msgSnapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                if (!msgSnapshot.hasData || msgSnapshot.data!.docs.isEmpty) return const Center(child: Text('Commencez la conversation avec Emma.'));
                
                final messages = msgSnapshot.data!.docs.map((doc) {
                   final data = doc.data() as Map<String, dynamic>;
                    return EmmaChatMessage(
                      text: data['text'] ?? '', 
                      isUser: data['isUser'] ?? false,
                    );
                }).toList();

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) => _buildMessageBubble(messages[index]),
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
              child: Row(
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