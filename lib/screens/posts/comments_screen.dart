// lib/screens/posts/comments_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:adomed_app/theme/app_theme.dart';
import 'package:intl/intl.dart';

class Comment {
  final String id;
  final String authorName;
  final String content;
  final Timestamp timestamp;
  final String uid;

  Comment({
    required this.id,
    required this.authorName,
    required this.content,
    required this.timestamp,
    required this.uid,
  });

  factory Comment.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Comment(
      id: doc.id,
      authorName: data['authorName'] ?? 'Anonyme',
      content: data['content'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
      uid: data['uid'] ?? '',
    );
  }
}

class CommentsScreen extends StatefulWidget {
  final String postId;

  const CommentsScreen({super.key, required this.postId});

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final TextEditingController _commentController = TextEditingController();
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  bool _isPosting = false;

  Future<void> _postComment() async {
    final currentUser = _currentUser;
    if (_commentController.text.isEmpty || currentUser == null) {
      return;
    }

    setState(() => _isPosting = true);

    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();
      final userName = (userDoc.data() as Map<String, dynamic>)['firstName'] ?? 'Utilisateur Adomed';

      await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .collection('comments')
          .add({
        'authorName': userName,
        'content': _commentController.text,
        'timestamp': Timestamp.now(),
        'uid': currentUser.uid,
      });

      await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .update({'comments': FieldValue.increment(1)});

      await _createCommentNotification(widget.postId, currentUser.uid);

      _commentController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de l\'envoi du commentaire.')),
      );
    } finally {
      if(mounted) {
        setState(() => _isPosting = false);
      }
    }
  }

  Future<void> _createCommentNotification(String postId, String commenterId) async {
    final postDoc = await FirebaseFirestore.instance.collection('posts').doc(postId).get();
    final postAuthorId = postDoc.data()?['uid'];
    
    if (postAuthorId == commenterId) return;

    final commenterName = 'UA${commenterId.substring(0, 6)}';
    
    await FirebaseFirestore.instance.collection('notifications').add({
      'userId': postAuthorId,
      'type': 'comment',
      'message': '$commenterName a commenté votre publication.',
      'relatedId': postId,
      'isRead': false,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }


  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Commentaires'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('posts')
                  .doc(widget.postId)
                  .collection('comments')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('Aucun commentaire. Soyez le premier !'));
                }
                final comments = snapshot.data!.docs.map((doc) => Comment.fromFirestore(doc)).toList();

                return ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final comment = comments[index];
                    return _buildCommentTile(comment);
                  },
                );
              },
            ),
          ),
          _buildCommentInputField(),
        ],
      ),
    );
  }

  Widget _buildCommentTile(Comment comment) {
    final date = DateFormat('dd MMM yyyy à HH:mm', 'fr_FR').format(comment.timestamp.toDate());
    final currentUser = _currentUser;

    final isMyComment = currentUser != null && comment.uid == currentUser.uid;
    final authorName = isMyComment ? 'MOI' : 'UA${comment.uid.substring(0, 6)}';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(authorName, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                const Spacer(),
                Text(date, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
            const SizedBox(height: 8),
            Text(comment.content, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentInputField() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _commentController,
                maxLines: null, // Permet l'expansion automatique
                keyboardType: TextInputType.multiline, // Permet le retour à la ligne
                decoration: InputDecoration(
                  hintText: 'Ajouter un commentaire...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                textCapitalization: TextCapitalization.sentences,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: _isPosting ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.send),
              onPressed: _isPosting ? null : _postComment,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}