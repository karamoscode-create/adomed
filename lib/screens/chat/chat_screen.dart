// lib/screens/chat/chat_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:adomed_app/theme/app_theme.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final String? fileUrl;
  final String? fileName;
  final String? fileMimeType;
  final bool isSystemMessage;

  ChatMessage({
    required this.text,
    required this.isUser,
    this.fileUrl,
    this.fileName,
    this.fileMimeType,
    this.isSystemMessage = false,
  });
}

class ChatScreen extends StatefulWidget {
  final String chatWith;
  final String conversationId;

  const ChatScreen({
    super.key,
    required this.chatWith,
    required this.conversationId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;
  String _currentAiResponse = '';
  final FlutterSoundRecorder _audioRecorder = FlutterSoundRecorder();
  bool _isRecording = false;

  late final GenerativeModel _model;
  late final ChatSession _chatSession;
  final FlutterTts flutterTts = FlutterTts();
  final _currentUserId = FirebaseAuth.instance.currentUser!.uid;
  String _conversationStatus = 'active';

  // ✨ PROMPT SYSTÈME MIS À JOUR POUR ÊTRE PLUS HUMAIN ET SPÉCIALISÉ
  final _systemPrompt = Content.text(
      "Tu es Diokara, un assistant médical IA d'origine ivoirienne pour l'application Adomed. "
      "Tu possèdes un doctorat en médecine et ta mission est d'assister les utilisateurs avec empathie, professionnalisme et prudence. "
      "Tes connaissances sont basées sur des documents médicaux certifiés, adaptés au système de santé de la Côte d'Ivoire. "
      "Ton ton est humain, chaleureux et rassurant, comme un médecin qui prend le temps d'écouter. "
      "Pour toute question non médicale (politique, sport, cuisine, etc.), réponds poliment en te rappelant de ton rôle. Réponds : 'Je suis Diokara, votre assistant médical. Je suis uniquement programmé pour discuter de sujets de santé. Comment puis-je vous aider dans ce domaine ?' "
      "Pour les questions médicales, structure toujours ta réponse de manière claire et concise. N'utilise JAMAIS de titres ou de labels comme 'Salutation :', 'Analyse :'. "
      "Ta réponse doit toujours intégrer naturellement les 4 étapes suivantes : "
      "1. Commence par une phrase empathique pour rassurer la personne (ex: 'Je vous écoute, et je suis là pour vous aider.'). "
      "2. Pose une ou deux questions pertinentes et ciblées pour mieux comprendre la situation et les symptômes. "
      "3. Donne des conseils de bon sens, généraux et sans danger, adaptés au contexte ivoirien (ex: 'Assurez-vous de bien vous hydrater.'). "
      "4. Termine TOUJOURS en recommandant fortement de consulter un professionnel de santé via l'application pour un diagnostic précis et une prise en charge adaptée. Si les symptômes semblent alarmants (douleur intense, fièvre persistante, etc.), recommande de ne pas attendre et de consulter un médecin immédiatement ou un spécialiste spécifique si c'est pertinent. "
      "Ne pose JAMAIS de diagnostic direct et ne prescris JAMAIS de médicament. Ton rôle est d'informer et de rassurer, pas de remplacer une consultation.");

  @override
  void initState() {
    super.initState();
    if (widget.chatWith == 'Diokara') {
      final apiKey = dotenv.env['GEMINI_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('GEMINI_API_KEY manquante dans .env');
      }
      _model = GenerativeModel(model: 'gemini-1.5-flash-latest', apiKey: apiKey);
      _chatSession = _model.startChat(history: [_systemPrompt]);
      _checkAndAddWelcomeMessage();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _audioRecorder.closeRecorder();
    flutterTts.stop();
    super.dispose();
  }

  Future<void> _closeConversation() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clore la conversation ?'),
        content: const Text('Cette action est irréversible. Le patient ne pourra plus envoyer de messages.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Confirmer')),
        ],
      ),
    );

    if (confirm != true) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(_currentUserId)
        .collection('discussions')
        .doc(widget.conversationId)
        .update({'status': 'closed', 'last_updated': Timestamp.now()});

    await _addSystemMessage('Cette conversation a été terminée par le médecin.');
  }

  Future<void> _addSystemMessage(String text) async {
    await FirebaseFirestore.instance
      .collection('users')
      .doc(_currentUserId)
      .collection('discussions')
      .doc(widget.conversationId)
      .collection('messages')
      .add({
        'text': text,
        'isUser': false,
        'isSystemMessage': true,
        'timestamp': Timestamp.now(),
      });
  }

  Future<void> _addAiMessageToFirebase(String text, {String? fileUrl, String? fileName, String? fileMimeType}) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(_currentUserId)
        .collection('discussions')
        .doc(widget.conversationId)
        .collection('messages')
        .add({
      'text': text,
      'isUser': false,
      'fileUrl': fileUrl,
      'fileName': fileName,
      'fileMimeType': fileMimeType,
      'timestamp': Timestamp.now(),
    });
  }

  Future<void> _checkAndAddWelcomeMessage() async {
    final messagesSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(_currentUserId)
        .collection('discussions')
        .doc(widget.conversationId)
        .collection('messages')
        .get();

    if (messagesSnapshot.docs.isEmpty) {
      await _addAiMessageToFirebase(
        "Bonjour ! Je suis Diokara, votre assistant médical d'Adomed. Je suis là pour vous accompagner et répondre à vos questions de santé. Comment puis-je vous aider aujourd'hui ?",
      );
    }
  }

  Future<void> _sendMessage() async {
    final userMessage = _controller.text.trim();
    if (userMessage.isEmpty || _isLoading) return;

    _controller.clear();
    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUserId)
          .collection('discussions')
          .doc(widget.conversationId)
          .collection('messages')
          .add({
        'text': userMessage,
        'isUser': true,
        'timestamp': Timestamp.now(),
      });

      if (widget.chatWith == 'Diokara') {
        String aiResponseText = '';
        final stream = _chatSession.sendMessageStream(Content.text(userMessage));

        await for (final chunk in stream) {
          final text = chunk.text;
          if (text != null) {
            setState(() => _currentAiResponse += text);
            aiResponseText += text;
          }
        }

        if (aiResponseText.isNotEmpty) {
          await _addAiMessageToFirebase(aiResponseText);
        }
      }
    } catch (e) {
      await _addAiMessageToFirebase("Désolé, une erreur est survenue.");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _currentAiResponse = '';
        });
      }
    }
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'png', 'pdf'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        await _uploadFile(result.files.single);
      }
    } catch (e) {
      _showErrorSnackBar('Erreur lors de la sélection du fichier: $e');
    }
  }

  Future<void> _uploadFile(PlatformFile file) async {
    try {
      setState(() => _isLoading = true);

      final fileToUpload = File(file.path!);
      final fileName = file.name;
      final ref = FirebaseStorage.instance
          .ref('chat_files/$_currentUserId/${DateTime.now().millisecondsSinceEpoch}_$fileName');

      await ref.putFile(fileToUpload);
      final downloadUrl = await ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUserId)
          .collection('discussions')
          .doc(widget.conversationId)
          .collection('messages')
          .add({
        'text': 'Fichier envoyé: $fileName',
        'isUser': true,
        'fileUrl': downloadUrl,
        'fileName': fileName,
        'fileMimeType': file.extension,
        'timestamp': Timestamp.now(),
      });
    } catch (e) {
      _showErrorSnackBar('Erreur lors de l\'upload: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _startRecording() async {
    try {
      final status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        _showErrorSnackBar('Permission microphone requise');
        return;
      }

      await _audioRecorder.openRecorder();
      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _audioRecorder.startRecorder(
        toFile: path,
        codec: Codec.aacMP4,
      );

      setState(() => _isRecording = true);
    } catch (e) {
      _showErrorSnackBar('Erreur lors du démarrage de l\'enregistrement: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      final audioPath = await _audioRecorder.stopRecorder();
      await _audioRecorder.closeRecorder();
      setState(() => _isRecording = false);

      if (audioPath != null) {
        await _uploadAudioFile(audioPath);
      }
    } catch (e) {
      _showErrorSnackBar('Erreur lors de l\'arrêt de l\'enregistrement: $e');
    }
  }

  Future<void> _uploadAudioFile(String audioPath) async {
    try {
      setState(() => _isLoading = true);
      final audioFile = File(audioPath);
      final fileName = 'audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
      final ref = FirebaseStorage.instance
          .ref('chat_audio/$_currentUserId/$fileName');

      await ref.putFile(audioFile);
      final downloadUrl = await ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUserId)
          .collection('discussions')
          .doc(widget.conversationId)
          .collection('messages')
          .add({
        'text': 'Message vocal envoyé',
        'isUser': true,
        'fileUrl': downloadUrl,
        'fileName': fileName,
        'fileMimeType': 'audio/m4a',
        'timestamp': Timestamp.now(),
      });
    } catch (e) {
      _showErrorSnackBar('Erreur lors de l\'upload audio: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
  }
  
  void _showSuccessSnackBar(String message) {
     if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.green));
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUserId)
          .collection('discussions')
          .doc(widget.conversationId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.exists) {
          final discussionData = snapshot.data!.data() as Map<String, dynamic>;
          _conversationStatus = discussionData['status'] ?? 'active';
        }

        return Scaffold(
          appBar: AppBar(
            title: Text('Chat avec ${widget.chatWith}'),
            actions: [
              if (widget.chatWith == 'Médecin' && _conversationStatus == 'active')
                IconButton(
                  icon: const Icon(Icons.lock_outline),
                  tooltip: 'Clore la conversation',
                  onPressed: _closeConversation,
                ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(_currentUserId)
                      .collection('discussions')
                      .doc(widget.conversationId)
                      .collection('messages')
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, msgSnapshot) {
                    if (msgSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!msgSnapshot.hasData || msgSnapshot.data!.docs.isEmpty) {
                      return const Center(child: Text('Commencez la conversation.'));
                    }
                    final messages = msgSnapshot.data!.docs;
                    return ListView.builder(
                      reverse: true,
                      padding: const EdgeInsets.all(16),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final data = messages[index].data() as Map<String, dynamic>;
                        final message = ChatMessage(
                          text: data['text'] ?? '',
                          isUser: data['isUser'] ?? false,
                          fileUrl: data['fileUrl'],
                          fileName: data['fileName'],
                          fileMimeType: data['fileMimeType'],
                          isSystemMessage: data['isSystemMessage'] ?? false,
                        );
                        return _buildMessageBubble(message);
                      },
                    );
                  },
                ),
              ),
              if (_conversationStatus == 'closed')
                Container(
                  padding: const EdgeInsets.all(24),
                  color: Colors.grey[200],
                  child: SafeArea(
                    child: Center(
                      child: Text(
                        'Cette conversation est terminée.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
                      ),
                    ),
                  ),
                )
              else
                _buildMessageInput(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              onPressed: _isLoading ? null : _pickFile,
              icon: const Icon(Icons.attach_file),
              color: AppColors.primary,
            ),
            IconButton(
              onPressed: _isLoading ? null : (_isRecording ? _stopRecording : _startRecording),
              icon: Icon(_isRecording ? Icons.stop : Icons.mic),
              color: _isRecording ? Colors.red : AppColors.primary,
            ),
            Expanded(
              child: TextField(
                controller: _controller,
                enabled: !_isLoading,
                decoration: InputDecoration(
                  hintText: _isRecording ? 'Enregistrement en cours...' : 'Tapez votre message...',
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _isLoading ? null : _sendMessage,
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(12),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.send),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    if (message.isSystemMessage) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Text(message.text, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic)),
        ),
      );
    }
    
    final bool canBeSpoken = !message.isUser && message.text.isNotEmpty && message.fileUrl == null;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Flexible(
            child: Card(
              color: message.isUser ? AppColors.primary : AppColors.cardColor,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Text(
                        message.text,
                        style: TextStyle(color: message.isUser ? Colors.white : AppColors.primaryText),
                      ),
                    ),
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
          ),
        ],
      ),
    );
  }
}