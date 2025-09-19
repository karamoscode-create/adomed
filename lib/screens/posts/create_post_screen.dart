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
  File? _selectedFile;
  String? _fileType;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Utiliser le texte de repost si c'est un repost, sinon le texte initial ou vide
    _contentController = TextEditingController(text: widget.repostText ?? widget.initialText ?? '');

    if (widget.repostImageUrl != null || widget.initialImageUrl != null) {
      _fileType = 'image';
    } else if (widget.repostVideoUrl != null || widget.initialVideoUrl != null) {
      _fileType = 'video';
    }
  }

  Future<void> _pickFile(ImageSource source, {bool isVideo = false}) async {
    final picker = ImagePicker();
    XFile? pickedFile;
    if (isVideo) {
      pickedFile = await picker.pickVideo(source: source);
    } else {
      pickedFile = await picker.pickImage(source: source);
    }

    if (pickedFile != null) {
      setState(() {
        _selectedFile = File(pickedFile!.path);
        _fileType = isVideo ? 'video' : 'image';
      });
    }
  }

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
      String? finalFileType = _fileType;

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
      
      final Map<String, dynamic> postData = {
        'uid': currentUser.uid,
        'authorName': userName,
        'specialty': 'Utilisateur',
        'isAnonymous': false,
        'content': _contentController.text,
        'postImageUrl': finalImageUrl,
        'postVideoUrl': finalVideoUrl,
        if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
      };

      if (widget.postToEditId != null) {
        await FirebaseFirestore.instance.collection('posts').doc(widget.postToEditId).update(postData);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Publication mise à jour avec succès !')),
          );
        }
      } else {
        postData['createdAt'] = FieldValue.serverTimestamp();
        postData['likes'] = 0;
        postData['comments'] = 0;
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
      Clipboard.setData(ClipboardData(text: link));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lien copié dans le presse-papier !')),
      );
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
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