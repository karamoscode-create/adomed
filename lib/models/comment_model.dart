import 'package:cloud_firestore/cloud_firestore.dart';

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