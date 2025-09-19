// lib/screens/alimentation_bebe/recipe_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:adomed_app/theme/app_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'recipe_model.dart';

class RecipeDetailScreen extends StatefulWidget {
  final Recipe recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  // --- NOUVEAUTÉ : Contrôleurs pour les notes et commentaires ---
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  bool _isSavingNote = false;
  bool _isPostingComment = false;

  @override
  void initState() {
    super.initState();
    _loadNote(); // On charge la note personnelle au démarrage
  }

  @override
  void dispose() {
    _noteController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 250.0,
                floating: false,
                pinned: true,
                backgroundColor: AppColors.primary.withOpacity(0.5),
                foregroundColor: Colors.white,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.share_outlined, color: Colors.white),
                    onPressed: _shareRecipe,
                  ),
                  FutureBuilder<bool>(
                    future: _isFavorite(widget.recipe.id),
                    builder: (context, snapshot) {
                      final isFavorite = snapshot.data ?? false;
                      return IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.redAccent : Colors.white,
                        ),
                        onPressed: () => _toggleFavorite(widget.recipe),
                      );
                    },
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.only(left: 60, bottom: 16, right: 60),
                  centerTitle: true,
                  title: Text(
                    widget.recipe.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(blurRadius: 10.0, color: Colors.black54, offset: Offset(2, 2))],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  background: Hero(
                    tag: widget.recipe.id,
                    child: (widget.recipe.imageUrl.startsWith('http'))
                        ? CachedNetworkImage(
                            imageUrl: widget.recipe.imageUrl,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) => const Icon(Icons.error),
                          )
                        : Image.asset(
                            widget.recipe.imageUrl,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
                          ),
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundColor.withOpacity(0.95),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(32),
                          topRight: Radius.circular(32),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoRow(context),
                            const SizedBox(height: 24),
                            if (widget.recipe.description != null && widget.recipe.description!.isNotEmpty)
                              _buildDescription(context),
                            const SizedBox(height: 24),
                            _buildSectionTitle(context, 'Ingrédients'),
                            const SizedBox(height: 12),
                            _buildList(context, widget.recipe.ingredients),
                            const SizedBox(height: 24),
                            if (widget.recipe.materials.isNotEmpty) ...[
                              _buildSectionTitle(context, 'Matériel'),
                              const SizedBox(height: 12),
                              _buildList(context, widget.recipe.materials),
                              const SizedBox(height: 24),
                            ],
                            if (widget.recipe.instructions.isNotEmpty)
                              _buildInstructions(context, widget.recipe.instructions),
                            const SizedBox(height: 24),
                            if (widget.recipe.nutrition.isNotEmpty)
                              _buildNutritionInfo(context, widget.recipe.nutrition),
                            
                            // --- NOUVEAUTÉ : Sections Notes et Commentaires ajoutées ici ---
                            const SizedBox(height: 24),
                            _buildNotesSection(context),
                            const SizedBox(height: 24),
                            _buildCommentsSection(context),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- Fonctions pour les Notes et Commentaires ---

  Future<void> _loadNote() async {
    if (_currentUser == null) return;
    final docRef = FirebaseFirestore.instance.collection('users').doc(_currentUser!.uid).collection('personal_notes').doc(widget.recipe.id);
    final doc = await docRef.get();
    if (doc.exists && mounted) {
      _noteController.text = (doc.data() as Map<String, dynamic>)['text'] ?? '';
    }
  }

  Future<void> _saveNote() async {
    if (_currentUser == null) return;
    setState(() => _isSavingNote = true);
    final docRef = FirebaseFirestore.instance.collection('users').doc(_currentUser!.uid).collection('personal_notes').doc(widget.recipe.id);
    await docRef.set({
      'text': _noteController.text.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    if (mounted) {
      setState(() => _isSavingNote = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Note enregistrée !'), backgroundColor: Colors.green));
    }
  }

  Future<void> _postComment() async {
    if (_commentController.text.trim().isEmpty || _currentUser == null) return;
    setState(() => _isPostingComment = true);
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(_currentUser!.uid).get();
      String authorName = (userDoc.data() as Map<String, dynamic>)['fullName'] ?? 'Utilisateur Adomed';
      
      await FirebaseFirestore.instance.collection('recipes').doc(widget.recipe.id).collection('comments').add({
        'text': _commentController.text.trim(), 'authorId': _currentUser!.uid,
        'authorName': authorName, 'createdAt': FieldValue.serverTimestamp(),
      });
      _commentController.clear();
      FocusScope.of(context).unfocus();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur : $e')));
    } finally {
      if (mounted) setState(() => _isPostingComment = false);
    }
  }

  // --- Widgets pour construire les nouvelles sections ---

  Widget _buildNotesSection(BuildContext context) {
    if (_currentUser == null) return const SizedBox.shrink(); // Ne rien afficher si l'utilisateur n'est pas connecté
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, 'Mes Notes Personnelles (privées)'),
        const SizedBox(height: 12),
        TextField(
          controller: _noteController,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'Notez ici vos ajustements, les réactions de bébé...',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton(
            onPressed: _isSavingNote ? null : _saveNote,
            child: _isSavingNote ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Enregistrer ma note'),
          ),
        )
      ],
    );
  }

  Widget _buildCommentsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, 'Commentaires et Recommandations'),
        const SizedBox(height: 16),
        if (_currentUser != null)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  hintText: 'Ajouter un commentaire public...',
                  border: const OutlineInputBorder(),
                  suffixIcon: _isPostingComment
                      ? const Padding(padding: EdgeInsets.all(12.0), child: CircularProgressIndicator(strokeWidth: 2))
                      : IconButton(icon: const Icon(Icons.send), onPressed: _postComment),
                ),
                maxLines: 3, minLines: 1,
              ),
            ),
          ),
        const SizedBox(height: 24),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('recipes').doc(widget.recipe.id).collection('comments').orderBy('createdAt', descending: true).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text('Aucun commentaire pour le moment.'));
            
            final comments = snapshot.data!.docs;
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: comments.length,
              itemBuilder: (context, index) {
                final comment = comments[index].data() as Map<String, dynamic>;
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(comment['authorName'] ?? 'Anonyme', style: const TextStyle(fontWeight: FontWeight.bold)),
                            const Spacer(),
                            if (comment['createdAt'] != null) Text(DateFormat('dd/MM/yy', 'fr_FR').format((comment['createdAt'] as Timestamp).toDate()), style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(comment['text']),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }


  // --- Widgets de votre design original (inchangés) ---
   Widget _buildInfoRow(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildInfoItem(context, Icons.schedule, '${widget.recipe.prepTime} min', 'Préparation'),
          _buildInfoItem(context, Icons.local_fire_department_outlined, '${widget.recipe.cookTime} min', 'Cuisson'),
          _buildInfoItem(context, Icons.star_border, widget.recipe.difficulty, 'Difficulté'),
          _buildInfoItem(context, Icons.texture, widget.recipe.texture, 'Texture'),
        ],
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, IconData icon, String value, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 30),
          const SizedBox(height: 8),
          Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: AppColors.primaryText,
      ),
    );
  }

  Widget _buildDescription(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, 'Description'),
        const SizedBox(height: 12),
        Text(
          widget.recipe.description!,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6),
        ),
      ],
    );
  }

  Widget _buildList(BuildContext context, List<String> items) {
    return Column(
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Icon(Icons.circle, size: 8, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInstructions(BuildContext context, List<String> instructions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, 'Instructions'),
        const SizedBox(height: 12),
        ...instructions.asMap().entries.map((entry) {
          int idx = entry.key + 1;
          String instruction = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$idx',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    instruction,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
  
  Widget _buildNutritionInfo(BuildContext context, Map<String, dynamic> nutrition) {
    if (nutrition.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, 'Valeurs nutritionnelles (pour 1 portion)'),
        const SizedBox(height: 12),
        ...nutrition.entries.map((entry) {
          String key = entry.key;
          String value = entry.value.toString();
          String unit = '';
          if (key == 'calories') unit = 'kcal';
          else if (['protein', 'carbs', 'fat', 'fiber'].contains(key)) unit = 'g';
          
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '• ${key[0].toUpperCase()}${key.substring(1)}:',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  '$value $unit',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  // --- Fonctions pour le Partage et les Favoris (logique inchangée) ---

  void _shareRecipe() async {
    final String shareText = 'Découvrez la recette "${widget.recipe.title}" sur Adomed ! Téléchargez l\'application : [votre lien]';
    await Share.share(shareText);
  }

  Future<bool> _isFavorite(String recipeId) async {
    if (_currentUser == null) return false;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('user_favorites')
          .doc(_currentUser!.uid)
          .collection('recipes')
          .doc(recipeId)
          .get();
      return doc.exists;
    } catch (e) {
      debugPrint('Erreur lors de la vérification des favoris: $e');
      return false;
    }
  }

  Future<void> _toggleFavorite(Recipe recipe) async {
    if (_currentUser == null) return;
    
    final favoritesRef = FirebaseFirestore.instance
        .collection('user_favorites')
        .doc(_currentUser!.uid)
        .collection('recipes')
        .doc(recipe.id);

    final isCurrentlyFavorite = await _isFavorite(recipe.id);

    if (isCurrentlyFavorite) {
      await favoritesRef.delete();
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Recette retirée des favoris')));
    } else {
      await favoritesRef.set({'addedAt': FieldValue.serverTimestamp()});
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Recette ajoutée aux favoris')));
    }
    if(mounted) setState(() {});
  }
}