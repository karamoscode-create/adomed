// lib/screens/posts/create_post_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:adomed_app/theme/app_theme.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';

class CreatePostScreen extends StatefulWidget {
  final String? postToEditId;
  final String? initialText;
  final String? initialImageUrl;
  final String? initialVideoUrl;
  final String? initialSource; // CHAMP AJOUTÉ
  final String? repostText;
  final String? repostImageUrl;
  final String? repostVideoUrl;
  final bool isRepost;

  const CreatePostScreen({
    super.key,
    this.postToEditId,
    this.initialText,
    this.initialImageUrl,
    this.initialVideoUrl,
    this.initialSource, // CHAMP AJOUTÉ
    this.repostText,
    this.repostImageUrl,
    this.repostVideoUrl,
    this.isRepost = false,
  });

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  late TextEditingController _contentController;
  late TextEditingController _sourceController; // CHAMP AJOUTÉ
  File? _selectedFile;
  String? _fileType;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(text: widget.repostText ?? widget.initialText ?? '');
    _sourceController = TextEditingController(text: widget.initialSource ?? ''); // CHAMP AJOUTÉ

    if (widget.repostImageUrl != null || widget.initialImageUrl != null) {
      _fileType = 'image';
    } else if (widget.repostVideoUrl != null || widget.initialVideoUrl != null) {
      _fileType = 'video';
    }
  }

  // =================== VOICI LA MODIFICATION ===================
  // J'ai rendu la vérification de "path" plus explicite
  // pour forcer l'analyseur de votre IDE à la valider.
  Future<void> _pickFile(ImageSource source, {bool isVideo = false}) async {
    final picker = ImagePicker();
    XFile? pickedFile;

    if (isVideo) {
      pickedFile = await picker.pickVideo(source: source);
    } else {
      pickedFile = await picker.pickImage(source: source);
    }

    // On vérifie si pickedFile n'est pas nul avant de continuer
    if (pickedFile != null) {
      // On assigne le chemin à une variable locale non-nulle
      final String localPath = pickedFile.path;
      
      // On utilise cette variable locale
      setState(() {
        _selectedFile = File(localPath);
        _fileType = isVideo ? 'video' : 'image';
      });
    }
  }
  // ================= FIN DE LA MODIFICATION ==================

  Future<String?> _uploadFile(File file, String userId, String fileType) async {
    try {
      final ext = file.path.split('.').last;
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('${fileType == 'video' ? 'post_videos' : 'post_images'}/${userId}_${DateTime.now().toIso8601String()}.$ext');
      final uploadTask = storageRef.putFile(file);
      final snapshot = await uploadTask.whenComplete(() {});
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du téléchargement du $fileType.')),
        );
      }
      return null;
    }
  }

  Future<String?> _generateVideoThumbnail(String videoPath) async {
    final thumbnailPath = await VideoThumbnail.thumbnailFile(
      video: videoPath,
      thumbnailPath: (await getTemporaryDirectory()).path,
      imageFormat: ImageFormat.JPEG,
      maxHeight: 200,
      quality: 75,
    );
    return thumbnailPath;
  }

  Future<void> _handlePost() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez vous connecter pour publier.')),
        );
      }
      return;
    }

    if (_contentController.text.isEmpty && _selectedFile == null && widget.initialImageUrl == null && widget.initialVideoUrl == null && widget.repostImageUrl == null && widget.repostVideoUrl == null) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? fileUrl;
      String? thumbnailUrl;
      String? finalImageUrl = widget.initialImageUrl ?? widget.repostImageUrl;
      String? finalVideoUrl = widget.initialVideoUrl ?? widget.repostVideoUrl;

      if (_selectedFile != null) {
        fileUrl = await _uploadFile(_selectedFile!, currentUser.uid, _fileType!);
        if (fileUrl == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('La publication a échoué car le fichier n\'a pas pu être téléchargé.')),
            );
          }
          return;
        }

        if (_fileType == 'video') {
          final tempThumbnailPath = await _generateVideoThumbnail(_selectedFile!.path);
          if (tempThumbnailPath != null) {
            thumbnailUrl = await _uploadFile(File(tempThumbnailPath), currentUser.uid, 'thumbnail');
          }
          finalVideoUrl = fileUrl;
          finalImageUrl = null;
        } else {
          finalImageUrl = fileUrl;
          finalVideoUrl = null;
        }
      }

      final userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();
      final userName = userDoc.data()?['firstName'] ?? 'Anonyme';
      final userPhotoUrl = userDoc.data()?['photoUrl'] ?? '';
      final String sourceText = _sourceController.text.trim();

      // --- BLOC DE CORRECTION MAJEURE ---
      // Utilise les bons noms de champs (`text`, `imageUrl`, etc.)
      // que `publications_screen.dart` s'attend à lire.
      final Map<String, dynamic> postData = {
        'authorId': currentUser.uid,
        'authorName': userName,
        'authorPhotoUrl': userPhotoUrl,
        'text': _contentController.text,
        'imageUrl': finalImageUrl,
        'videoUrl': finalVideoUrl,
        'type': finalVideoUrl != null ? 'video' : (finalImageUrl != null ? 'image' : 'text'),
        if (sourceText.isNotEmpty) 'source': sourceText, // CHAMP AJOUTÉ
        if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
      };
      // --- FIN DU BLOC DE CORRECTION ---


      if (widget.postToEditId != null) {
        // En mode édition, on ne met à jour que les données
        await FirebaseFirestore.instance.collection('posts').doc(widget.postToEditId).update(postData);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Publication mise à jour avec succès !')),
          );
        }
      } else {
        // En mode création, on ajoute les champs initiaux
        postData['timestamp'] = FieldValue.serverTimestamp();
        postData['likes'] = 0;
        postData['commentsCount'] = 0;
        postData['views'] = 0;
        await FirebaseFirestore.instance.collection('posts').add(postData);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Publication créée avec succès !')),
          );
        }
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de la publication.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _copyLinkToClipboard() {
    String? link;
    if (widget.initialImageUrl != null) {
      link = widget.initialImageUrl;
    } else if (widget.initialVideoUrl != null) {
      link = widget.initialVideoUrl;
    } else if (widget.repostImageUrl != null) {
      link = widget.repostImageUrl;
    } else if (widget.repostVideoUrl != null) {
      link = widget.repostVideoUrl;
    }

    if (link != null) {
      // CORRECTION : L'import 'package:flutter/services.dart' résout ces erreurs
      Clipboard.setData(ClipboardData(text: link));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lien copié dans le presse-papier !')),
      );
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    _sourceController.dispose(); // CHAMP AJOUTÉ
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.postToEditId != null;
    final bool isReposting = widget.isRepost;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Modifier la publication' : (isReposting ? 'Republier' : 'Créer une publication')),
        actions: [
          if (isReposting && (widget.repostImageUrl != null || widget.repostVideoUrl != null))
            IconButton(
              onPressed: _copyLinkToClipboard,
              icon: const Icon(Icons.copy),
              tooltip: 'Copier le lien',
            ),
          TextButton(
            onPressed: _isLoading ? null : _handlePost,
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
            ),
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(isEditing ? 'Sauvegarder' : 'Publier'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _contentController,
              maxLines: null,
              decoration: const InputDecoration(
                hintText: 'Comment vous allez aujourd\'hui ?',
                border: InputBorder.none,
              ),
            ),
            
            // --- CHAMP SOURCE AJOUTÉ ---
            const Divider(thickness: 1),
            TextField(
              controller: _sourceController,
              decoration: InputDecoration(
                hintText: 'Source (ex: OMS, www.sante.gouv...)',
                // CORRECTION : Remplacement de .textHintColor par .textHint
                hintStyle: TextStyle(color: AppColors.textHint, fontStyle: FontStyle.italic),
                border: InputBorder.none,
              ),
            ),
            const Divider(thickness: 1),
            // --- FIN DE L'AJOUT ---

            if (_selectedFile != null)
              Container(
                margin: const EdgeInsets.only(top: 16),
                child: _fileType == 'video'
                    ? const Text('Vidéo sélectionnée', style: TextStyle(color: Colors.black))
                    : Image.file(_selectedFile!),
              )
            else if (isReposting && widget.repostImageUrl != null)
              Container(
                margin: const EdgeInsets.only(top: 16),
                child: Image.network(widget.repostImageUrl!),
              )
            else if (isReposting && widget.repostVideoUrl != null)
              Container(
                // CORRECTION : Remplacement de : par .
                margin: const EdgeInsets.only(top: 16),
                child: Text(
                  'Vidéo originale',
                  style: TextStyle(color: AppColors.textPrimary, fontStyle: FontStyle.italic),
                ),
              )
            else if (isEditing && widget.initialImageUrl != null)
              Container(
                margin: const EdgeInsets.only(top: 16),
                child: Image.network(widget.initialImageUrl!),
              )
            else if (isEditing && widget.initialVideoUrl != null)
              Container(
                // CORRECTION : Remplacement de : par .
                margin: const EdgeInsets.only(top: 16),
                child: Text(
                  'Vidéo originale',
                  style: TextStyle(color: AppColors.textPrimary, fontStyle: FontStyle.italic),
                ),
              ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  onPressed: () => _pickFile(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  tooltip: 'Ajouter une image',
                ),
                IconButton(
                  onPressed: () => _pickFile(ImageSource.gallery, isVideo: true),
                  icon: const Icon(Icons.video_library),
                  tooltip: 'Ajouter une vidéo',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}