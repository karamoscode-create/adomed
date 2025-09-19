// lib/screens/posts/home_screen.dart
import 'package:adomed_app/widgets/app_background.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:adomed_app/screens/services/services_screen.dart';
import 'package:adomed_app/screens/abonnement/abonnement_screen.dart';
import 'package:adomed_app/screens/marketplace/marketplace_screen.dart';
import 'package:adomed_app/screens/profil/profil_screen.dart';
import 'package:adomed_app/screens/demander_avis/demander_avis_screen.dart';
import 'package:adomed_app/screens/suivi_medical/suivi_medical_screen.dart';
import 'package:adomed_app/screens/alimentation_bebe/alimentation_bebe_screen.dart';
import 'package:adomed_app/screens/consultation/consultation_screen.dart';
import 'package:adomed_app/screens/bilans/bilans_medicaux_screen.dart';
import 'package:adomed_app/screens/urgence/urgence_categories_screen.dart';
import 'package:adomed_app/screens/chat/discussions_screen.dart';
import 'package:adomed_app/screens/posts/comments_screen.dart';
import 'package:adomed_app/screens/posts/create_post_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share_plus/share_plus.dart';
import 'package:adomed_app/theme/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:adomed_app/screens/notifications/notifications_screen.dart';
import 'package:photo_view/photo_view.dart';
import 'package:video_player/video_player.dart';
import 'package:shimmer/shimmer.dart';
import 'package:adomed_app/models/post_model.dart';
import 'package:flutter/services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 2;

  final List<Widget> _screens = [
    const ServicesScreen(),
    const MarketplaceScreen(),
    const HomeContent(),
    const ProfilScreen(),
    const AbonnementScreen(),
  ];

  void _onTap(int index) => setState(() => _currentIndex = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Container(decoration: const BoxDecoration(gradient: AppColors.primaryGradient)),
          Padding(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
              child: Container(
                color: AppTheme.backgroundColor.withOpacity(0.95),
                child: Column(
                  children: [
                    Expanded(child: IndexedStack(index: _currentIndex, children: _screens)),
                    _buildCurvedNavigationBar(context),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurvedNavigationBar(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          height: kBottomNavigationBarHeight + 20,
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildNavItem(context, icon: Icons.medical_services_rounded, label: 'Services', index: 0),
              _buildNavItem(context, icon: Icons.shopping_bag_rounded, label: 'Shop', index: 1),
              const SizedBox(width: 60),
              _buildNavItem(context, icon: Icons.person_rounded, label: 'Profil', index: 3),
              _buildNavItem(context, icon: Icons.account_balance_wallet_rounded, label: 'Abonnement', index: 4),
            ],
          ),
        ),
        Positioned(
          bottom: 25,
          child: GestureDetector(
            onTap: () => _onTap(2),
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: AppTheme.primaryColor.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: const Icon(Icons.home_rounded, color: Colors.white, size: 28),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem(BuildContext context, {required IconData icon, required String label, required int index}) {
    final bool isSelected = _currentIndex == index;
    final color = isSelected ? Theme.of(context).primaryColor : Colors.grey.shade500;
    
    return GestureDetector(
      onTap: () => _onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});
  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  Stream<QuerySnapshot<Map<String, dynamic>>>? _postsStream;
  final TextEditingController _searchController = TextEditingController();
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  bool _isSearchFieldVisible = false;

  final List<Map<String, dynamic>> services = const [
    {"name": "Demander un avis", "icon": "assets/images/services/demander_avis.png", "screen": DemanderAvisScreen()},
    {"name": "Consultations", "icon": "assets/images/services/consultations.png", "screen": ConsultationScreen()},
    {"name": "Bilans médicaux", "icon": "assets/images/services/bilans_medicaux.png", "screen": BilansMedicauxScreen()},
    {"name": "C.A.T d'urgence", "icon": "assets/images/services/cat_urgence.png", "screen": UrgenceCategoriesScreen()},
    {"name": "Suivi médical", "icon": "assets/images/services/suivi_medical.png", "screen": SuiviMedicalScreen()},
    {"name": "Alimentation bébé", "icon": "assets/images/services/alimentation_bebe.png", "screen": AlimentationBebeScreen()},
  ];

  @override
  void initState() {
    super.initState();
    _postsStream = FirebaseFirestore.instance.collection('posts').orderBy('createdAt', descending: true).snapshots();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _likePost(String postId) async {
    final currentUser = _currentUser;
    if (currentUser == null) return;
    
    final postRef = FirebaseFirestore.instance.collection('posts').doc(postId);
    final likeRef = postRef.collection('likes').doc(currentUser.uid);
    final isLiked = await likeRef.get().then((doc) => doc.exists);

    if (isLiked) {
      await likeRef.delete();
      await postRef.update({'likes': FieldValue.increment(-1)});
    } else {
      await likeRef.set({'uid': currentUser.uid, 'timestamp': Timestamp.now()});
      await postRef.update({'likes': FieldValue.increment(1)});
    }
  }

  void _sharePost(Post post) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Partager la publication', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.repeat),
              title: const Text('Republier dans l\'application'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreatePostScreen(
                      isRepost: true,
                      repostText: post.content,
                      repostImageUrl: post.postImageUrl,
                      repostVideoUrl: post.postVideoUrl,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Copier le contenu'),
              onTap: () {
                Navigator.pop(context);
                Clipboard.setData(ClipboardData(text: post.content));
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Contenu du post copié !')));
              },
            ),
            ListTile(
              leading: const Icon(Icons.share_outlined),
              title: const Text('Partager via une autre application'),
              onTap: () {
                Navigator.pop(context);
                String shareText = "Vu sur Adomed :\n\n\"${post.content}\"";
                if (post.postImageUrl != null) shareText += "\n\nImage : ${post.postImageUrl}";
                Share.share(shareText);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToService(BuildContext context, Widget screen) => Navigator.push(context, MaterialPageRoute(builder: (context) => screen));

  @override
  Widget build(BuildContext context) {
    final currentUser = _currentUser;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.transparent,
            floating: true,
            pinned: false,
            snap: true,
            elevation: 0,
            toolbarHeight: 110,
            titleSpacing: 0,
            title: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset('assets/images/adomed-logo-home.png', height: 50, fit: BoxFit.contain),
                      Row(
                        children: [
                          if (currentUser != null)
                            StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance.collection('notifications').where('userId', isEqualTo: currentUser.uid).where('isRead', isEqualTo: false).snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                                  return Badge(
                                    backgroundColor: Colors.red,
                                    label: Text(snapshot.data!.docs.length.toString()),
                                    child: IconButton(
                                      icon: const Icon(Icons.notifications_none),
                                      color: Theme.of(context).primaryColor,
                                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsScreen())),
                                    ),
                                  );
                                }
                                return IconButton(
                                  icon: const Icon(Icons.notifications_none),
                                  color: Theme.of(context).primaryColor,
                                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsScreen())),
                                );
                              },
                            ),
                          IconButton(
                            icon: const Icon(Icons.search),
                            color: Theme.of(context).primaryColor,
                            onPressed: () => setState(() => _isSearchFieldVisible = !_isSearchFieldVisible),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (_isSearchFieldVisible)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Rechercher un post...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide.none),
                          filled: true,
                          fillColor: Colors.grey[200]!.withOpacity(0.7),
                          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(20),
                child: GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CreatePostScreen())),
                  child: Container(
                    width: double.infinity,
                    height: 45,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [BoxShadow(color: AppColors.shadowColor.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4))],
                    ),
                    alignment: Alignment.centerLeft,
                    child: Text('Comment vous allez aujourd\'hui ?', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600])),
                  ),
                ),
              ),
              _buildServicesSection(),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                child: Text('Publications', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 10),
              StreamBuilder<QuerySnapshot>(
                stream: _postsStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) return _buildShimmerLoading();
                  if (snapshot.hasError) return Center(child: Text("Erreur: ${snapshot.error}"));
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(20),
                      child: Container(
                        padding: const EdgeInsets.all(25),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: AppColors.shadowColor.withOpacity(0.2), blurRadius: 6, offset: const Offset(0, 2))],
                        ),
                        child: Text("Aucune publication pour le moment.", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black), textAlign: TextAlign.center),
                      ),
                    );
                  }
                  
                  final allPosts = snapshot.data!.docs.map((doc) => Post.fromFirestore(doc)).toList();
                  final searchQuery = _searchController.text.toLowerCase();
                  
                  final filteredPosts = allPosts.where((post) {
                    final contentMatches = post.content.toLowerCase().contains(searchQuery);
                    final authorIdentifier = post.authorName == 'Anonyme' ? post.uid : post.authorName;
                    final authorMatches = authorIdentifier.toLowerCase().contains(searchQuery);
                    return contentMatches || authorMatches;
                  }).toList();

                  if (filteredPosts.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(20),
                      child: Container(
                        padding: const EdgeInsets.all(25),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: AppColors.shadowColor.withOpacity(0.2), blurRadius: 6, offset: const Offset(0, 2))],
                        ),
                        child: Text("Aucun post ne correspond à votre recherche.", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black), textAlign: TextAlign.center),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredPosts.length,
                    itemBuilder: (context, index) => _buildModernPostCard(context, filteredPosts[index]),
                  );
                },
              ),
              const SizedBox(height: 20),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text('Services Rapides', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: services.length,
            itemBuilder: (context, index) {
              final service = services[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: GestureDetector(
                  onTap: () => _navigateToService(context, service['screen']!),
                  child: Column(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4)),
                            BoxShadow(color: Colors.white.withOpacity(0.5), blurRadius: 2, offset: const Offset(-2, -2)),
                          ],
                        ),
                        child: Image.asset(service['icon']!, fit: BoxFit.cover),
                      ),
                      const SizedBox(height: 4),
                      Text(service['name']!, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black, fontSize: 10), textAlign: TextAlign.center),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerLoading() {
    return Column(
      children: List.generate(3, (index) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15.0),
            boxShadow: [BoxShadow(color: AppColors.shadowColor.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4))],
          ),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Container(width: 80, height: 12, color: Colors.white), Container(width: 50, height: 12, color: Colors.white)]),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const CircleAvatar(radius: 25, backgroundColor: Colors.white),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(width: 120, height: 16, color: Colors.white),
                        const SizedBox(height: 4),
                        Container(width: 80, height: 12, color: Colors.white),
                        const SizedBox(height: 4),
                        Container(width: 60, height: 12, color: Colors.white),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(width: double.infinity, height: 14, color: Colors.white),
                const SizedBox(height: 8),
                Container(width: 200, height: 14, color: Colors.white),
                const SizedBox(height: 12),
                Container(width: double.infinity, height: 180, color: Colors.white),
                const SizedBox(height: 16),
                Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [Container(width: 80, height: 20, color: Colors.white), Container(width: 100, height: 20, color: Colors.white), Container(width: 70, height: 20, color: Colors.white)]),
              ],
            ),
          ),
        ),
      )),
    );
  }

  Widget _buildModernPostCard(BuildContext context, Post post) {
    final currentUser = _currentUser;
    final isMyPost = currentUser != null && post.uid == currentUser.uid;
    final authorName = post.authorName;

    // LA LOGIQUE FINALE ET CORRIGÉE EST ICI
    String displayIdentifier;
    if (isMyPost && authorName == 'Anonyme') {
      displayIdentifier = 'Moi';
    } else if (authorName == 'Anonyme') {
      displayIdentifier = 'ID:${post.uid.substring(0, 5)}';
    } else {
      displayIdentifier = authorName;
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: AppColors.shadowColor.withOpacity(0.2), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(color: Theme.of(context).primaryColor, borderRadius: BorderRadius.circular(10)),
                  child: Center(
                    child: authorName == 'Anonyme'
                        ? const Icon(Icons.person, color: Colors.white, size: 20)
                        : Text(authorName.substring(0, 2), style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayIdentifier,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
                      ),
                      if (authorName != 'Anonyme')
                        Text(
                          post.specialty,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w500),
                        ),
                      Text(
                        DateFormat('dd MMM yyyy à HH:mm', 'fr_FR').format(post.createdAt.toDate()),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                if (isMyPost)
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, color: Colors.grey.shade700, size: 20),
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Text('Modifier')),
                      const PopupMenuItem(value: 'delete', child: Text('Supprimer')),
                    ],
                    onSelected: (value) async {
                      if (value == 'edit') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CreatePostScreen(
                              postToEditId: post.id,
                              initialText: post.content,
                              initialImageUrl: post.postImageUrl,
                              initialVideoUrl: post.postVideoUrl,
                            ),
                          ),
                        );
                      } else if (value == 'delete') {
                        await FirebaseFirestore.instance.collection('posts').doc(post.id).delete();
                        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Post supprimé avec succès.')));
                      }
                    },
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(post.content, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary)),
          ),
          if (post.postImageUrl != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ImageViewerScreen(imageUrl: post.postImageUrl!))),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      post.postImageUrl!,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(color: Colors.grey.shade100, child: const Center(child: CircularProgressIndicator()));
                      },
                      errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey.shade100, child: const Center(child: Icon(Icons.broken_image, color: Colors.grey, size: 30))),
                    ),
                  ),
                ),
              ),
            )
          else if (post.postVideoUrl != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: ClipRRect(borderRadius: BorderRadius.circular(12), child: VideoPlayerWidget(videoUrl: post.postVideoUrl!)),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Text('${post.likes} J\'aimes', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textPrimary)),
                      const SizedBox(width: 15),
                      Text('${post.comments} commentaires', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textPrimary)),
                    ],
                  ),
                ),
                if (post.postVideoUrl != null)
                  Text('${post.views} Vues', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textPrimary)),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                FutureBuilder<bool>(
                  future: currentUser != null ? FirebaseFirestore.instance.collection('posts').doc(post.id).collection('likes').doc(currentUser.uid).get().then((doc) => doc.exists) : Future.value(false),
                  builder: (context, snapshot) {
                    final isLiked = snapshot.data ?? false;
                    return _ModernPostActionButton(
                      icon: isLiked ? Icons.favorite : Icons.favorite_border,
                      label: 'J\'aime',
                      color: isLiked ? const Color(0xFFFF6B6B) : Colors.grey.shade700,
                      onTap: () => _likePost(post.id),
                    );
                  },
                ),
                _ModernPostActionButton(
                  icon: Icons.chat_bubble_outline,
                  label: 'Commenter',
                  color: Colors.grey.shade700,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => CommentsScreen(postId: post.id))),
                ),
                _ModernPostActionButton(
                  icon: Icons.share_outlined,
                  label: 'Partager',
                  color: Colors.grey.shade700,
                  onTap: () => _sharePost(post),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ModernPostActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ModernPostActionButton({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 18),
                const SizedBox(width: 6),
                Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w500, fontSize: 12)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ImageViewerScreen extends StatelessWidget {
  final String imageUrl;
  const ImageViewerScreen({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: PhotoView(
        imageProvider: NetworkImage(imageUrl),
        backgroundDecoration: const BoxDecoration(color: Colors.black),
        minScale: PhotoViewComputedScale.contained * 0.8,
        maxScale: PhotoViewComputedScale.covered * 2,
      ),
    );
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  const VideoPlayerWidget({super.key, required this.videoUrl});
  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) => setState(() => _isInitialized = true))
      .catchError((error) => debugPrint("Erreur de chargement de la vidéo: $error"));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Container(height: 200, color: Colors.grey.shade100, child: const Center(child: CircularProgressIndicator()));
    }
    return GestureDetector(
      onTap: () => setState(() => _controller.value.isPlaying ? _controller.pause() : _controller.play()),
      child: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(aspectRatio: _controller.value.aspectRatio, child: VideoPlayer(_controller)),
          if (!_controller.value.isPlaying)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(child: Icon(Icons.play_circle_fill, size: 70, color: Colors.white.withOpacity(0.8))),
            ),
        ],
      ),
    );
  }
}