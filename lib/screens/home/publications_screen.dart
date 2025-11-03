import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:adomed_app/theme/app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:adomed_app/screens/posts/comments_screen.dart';
import 'package:adomed_app/screens/posts/create_post_screen.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:adomed_app/models/post_model.dart';
import 'package:shimmer/shimmer.dart';


class PublicationsScreen extends StatelessWidget {
  const PublicationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Utilisation d'un DefaultTabController pour gérer les onglets
    return DefaultTabController(
      length: 3, // Nombre d'onglets
      initialIndex: 1, // L'onglet "Publications" est sélectionné par défaut
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          leading: IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () {},
          ),
          title: const Text(
            'ADOMED',
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.search, color: Colors.black),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.person_outline, color: Colors.black),
              onPressed: () {},
            ),
          ],
          bottom: const TabBar(
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blue,
            tabs: [
              Tab(text: 'Services'),
              Tab(text: 'Publications'),
              Tab(text: 'Menu Accueil'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            const Center(child: Text('Services Screen')),
            _PublicationsFeed(),
            const Center(child: Text('Menu Accueil Screen')),
          ],
        ),
      ),
    );
  }
}

class _PublicationsFeed extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final currentUserUid = FirebaseAuth.instance.currentUser?.uid;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('Aucune publication pour le moment.'));
        }

        final posts = snapshot.data!.docs;

        return ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            return _PostCard(
              post: post.data() as Map<String, dynamic>,
              postId: post.id,
              currentUserUid: currentUserUid,
            );
          },
        );
      },
    );
  }
}

class _PostCard extends StatefulWidget {
  final Map<String, dynamic> post;
  final String postId;
  final String? currentUserUid;

  const _PostCard({
    required this.post,
    required this.postId,
    required this.currentUserUid,
  });

  @override
  State<_PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<_PostCard> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    if (widget.post['type'] == 'video' && widget.post['videoUrl'] != null) {
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.post['videoUrl']))
        ..initialize().then((_) {
          if (mounted) {
            setState(() {
              _isInitialized = true;
            });
          }
        }).catchError((error) {
          debugPrint("Erreur de chargement de la vidéo: $error");
        });
    }
  }

  @override
  void dispose() {
    if (widget.post['type'] == 'video' && _isInitialized) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _sharePost(BuildContext context) {
    Share.share(
      'Regarde ce post intéressant : ${widget.post['imageUrl'] ?? widget.post['videoUrl'] ?? ''} - ${widget.post['text']}',
      subject: 'Partage de post ADOMED',
    );
  }

  void _repost(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final newPostData = {
        ...widget.post,
        'authorId': user.uid,
        'authorName': user.displayName ?? 'Utilisateur',
        'authorPhotoUrl': user.photoURL ?? '',
        'timestamp': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection('posts').add(newPostData);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post reposter avec succès !')),
        );
      }
    } catch (e) {
      debugPrint('Erreur lors du repostage : $e');
    }
  }

  void _showShareOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.share_outlined),
                title: const Text('Partager'),
                onTap: () {
                  Navigator.pop(bc);
                  _sharePost(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.repeat),
                title: const Text('Reposter'),
                onTap: () {
                  Navigator.pop(bc);
                  _repost(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _deletePost() async {
    final postId = widget.postId;
    final post = widget.post;
    final storage = FirebaseStorage.instance;
    final firestore = FirebaseFirestore.instance;

    try {
      await firestore.collection('posts').doc(postId).delete();
      if (post['imageUrl'] != null) {
        await storage.refFromURL(post['imageUrl']).delete();
      } else if (post['videoUrl'] != null) {
        await storage.refFromURL(post['videoUrl']).delete();
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post supprimé avec succès')),
        );
      }
    } catch (e) {
      debugPrint('Erreur lors de la suppression : $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de la suppression du post')),
        );
      }
    }
  }
  
  void _editPost() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CreatePostScreen(
          postToEditId: widget.postId,
          initialText: widget.post['text'],
          initialImageUrl: widget.post['imageUrl'],
          initialVideoUrl: widget.post['videoUrl'],
          initialSource: widget.post['source'], // <-- CHAMP AJOUTÉ
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final isMyPost = widget.currentUserUid == post['authorId'];
    final bool isVideo = post['type'] == 'video';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: post['authorPhotoUrl'] != null && post['authorPhotoUrl'].isNotEmpty
                      ? NetworkImage(post['authorPhotoUrl'])
                      : null,
                  child: post['authorPhotoUrl'] == null || post['authorPhotoUrl'].isEmpty
                      ? const Icon(Icons.person, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post['authorName'] ?? 'Anonyme',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        post['timestamp'] != null
                            ? DateFormat('dd MMMM yyyy à HH:mm').format((post['timestamp'] as Timestamp).toDate())
                            : 'Date inconnue',
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                if (isMyPost)
                  PopupMenuButton<String>(
                    onSelected: (String result) {
                      if (result == 'edit') {
                        _editPost();
                      } else if (result == 'delete') {
                        _deletePost();
                      }
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'edit',
                        child: Text('Modifier'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'delete',
                        child: Text('Supprimer'),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              post['text'] ?? '',
              style: TextStyle(fontSize: 15, color: AppColors.textPrimary),
            ),
            
            // --- CHAMP SOURCE AJOUTÉ ---
            if (post['source'] != null && post['source'].isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Source : ${post['source']}',
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            // --- FIN DE L'AJOUT ---

            if (post['imageUrl'] != null && post['imageUrl'].isNotEmpty) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  post['imageUrl'],
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
                ),
              ),
            ],
            if (isVideo && _isInitialized) ...[
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _controller.value.isPlaying ? _controller.pause() : _controller.play();
                  });
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    ),
                    if (!_controller.value.isPlaying)
                      Container(
                        color: Colors.black.withOpacity(0.3),
                        child: Center(
                          child: Icon(
                            Icons.play_circle_fill,
                            size: 70,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.favorite_border),
                      onPressed: () {
                        // Handle like
                      },
                    ),
                    Text('${post['likes'] ?? 0}'),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.comment_outlined),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => CommentsScreen(
                              postId: widget.postId,
                            ),
                          ),
                        );
                      },
                    ),
                    Text('${post['commentsCount'] ?? 0}'),
                  ],
                ),
                if (isVideo)
                  Row(
                    children: [
                      const Icon(Icons.remove_red_eye_outlined, size: 20),
                      const SizedBox(width: 4),
                      Text('${post['views'] ?? 0}'),
                    ],
                  ),
                IconButton(
                  icon: const Icon(Icons.share_outlined),
                  onPressed: () => _showShareOptions(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}