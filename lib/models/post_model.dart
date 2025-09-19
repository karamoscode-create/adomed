// lib/models/post_model.dart (assumant que le fichier est dans ce dossier)
import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String authorName;
  final Timestamp createdAt;
  final String content;
  final String? postImageUrl;
  final String? authorImageUrl;
  final String? postVideoUrl; // <-- CORRIGÉ
  final String? thumbnailUrl;
  final String specialty;
  final bool isAnonymous;
  final int likes;
  final int comments;
  final int views;
  final String uid;

  Post({
    required this.id,
    required this.authorName,
    required this.createdAt,
    required this.content,
    required this.specialty,
    required this.isAnonymous,
    required this.uid,
    this.postImageUrl,
    this.authorImageUrl,
    this.postVideoUrl, // <-- CORRIGÉ
    this.thumbnailUrl,
    this.likes = 0,
    this.comments = 0,
    this.views = 0,
  });

  factory Post.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Post(
      id: doc.id,
      authorName: data['authorName'] ?? 'Auteur inconnu',
      createdAt: data['createdAt'] ?? Timestamp.now(),
      content: data['content'] ?? '',
      specialty: data['specialty'] ?? '',
      isAnonymous: data['isAnonymous'] ?? false,
      uid: data['uid'] ?? '',
      postImageUrl: data['postImageUrl'],
      authorImageUrl: data['authorImageUrl'],
      postVideoUrl: data['postVideoUrl'], // <-- CORRIGÉ
      thumbnailUrl: data['thumbnailUrl'],
      likes: data['likes'] ?? 0,
      comments: data['comments'] ?? 0,
      views: data['views'] ?? 0,
    );
  }

  String get timeAgo {
    final now = DateTime.now();
    final dateTime = createdAt.toDate();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'À l\'instant';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}j';
    } else {
      return '${(difference.inDays / 7).floor()}sem';
    }
  }
}