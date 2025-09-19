// lib/screens/profil/profil_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:adomed_app/screens/profil/edit_profil_screen.dart';
import 'package:adomed_app/screens/profil/edit_coordonnees_screen.dart';
import 'package:adomed_app/screens/auth/login_screen.dart';
import '../agenda/agenda_screen.dart';
import '../dossier/dossier_medical_screen.dart';
import '../abonnement/abonnement_screen.dart';
import 'package:adomed_app/theme/app_theme.dart';
import 'package:iconsax/iconsax.dart';
import 'commandes_screen.dart'; // NOUVEL IMPORT

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  late StreamSubscription<User?> _authSubscription;
  User? _user;
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      _user = user;
      if (user != null) {
        _fetchUserData();
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    });
  }

  Future<void> _fetchUserData() async {
    if (_user == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(_user!.uid)
        .get();
    if (doc.exists) {
      _userData = doc.data()!;
      _userData!['subscription'] ??= 'Standard';
      _userData!['bloodGroup'] ??= 'Non défini';
      _userData!['lastCheck'] ??= 'Date inconnue';
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(32),
                topRight: Radius.circular(32),
              ),
              child: Container(
                color: AppTheme.backgroundColor.withOpacity(0.95),
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.0),
                      child: Text(
                        'Profil',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimaryColor,
                        ),
                      ),
                    ),
                    Expanded(
                      child: _isLoading
                          ? Center(child: CircularProgressIndicator(color: theme.primaryColor))
                          : _user == null
                              ? _buildLoginPrompt(context)
                              : RefreshIndicator(
                                  onRefresh: _fetchUserData,
                                  child: SingleChildScrollView(
                                    physics: const AlwaysScrollableScrollPhysics(),
                                    padding: const EdgeInsets.only(bottom: 24),
                                    child: Column(
                                      children: [
                                        _IdentityCard(
                                          userData: _userData,
                                          uid: _user!.uid,
                                        ),
                                        const SizedBox(height: 24),
                                        _InfoGrid(userData: _userData!),
                                        const SizedBox(height: 24),
                                        _NavTile(
                                          icon: Iconsax.folder_open,
                                          title: 'Dossier médical',
                                          subtitle: 'Consultez votre dossier médical et toutes les informations liées.',
                                          onTap: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (_) => const DossierMedicalScreen()),
                                          ),
                                          iconColor: Colors.blue,
                                        ),
                                        _NavTile(
                                          icon: Iconsax.calendar_1,
                                          title: 'Mes rendez-vous',
                                          subtitle: 'Gérez vos consultations.',
                                          onTap: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (_) => const AgendaScreen()),
                                          ),
                                          iconColor: Colors.green,
                                        ),
                                        _NavTile(
                                          icon: Iconsax.card,
                                          title: 'Abonnement',
                                          subtitle: 'Gérez votre abonnement et vos avantages.',
                                          onTap: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (_) => const AbonnementScreen()),
                                          ),
                                          iconColor: Colors.orange,
                                        ),
                                        _NavTile(
                                          icon: Iconsax.shopping_bag,
                                          title: 'Mes commandes',
                                          subtitle: 'Retrouvez l’historique de vos achats.',
                                          onTap: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (_) => const CommandesScreen()),
                                          ),
                                          iconColor: Colors.purple,
                                        ),
                                        _NavTile(
                                          icon: Iconsax.user_edit,
                                          title: 'Infos personnelles',
                                          subtitle: 'Nom, prénom, date de naissance, groupe sanguin',
                                          onTap: () async {
                                            final result = await Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (_) => EditProfilScreen(userData: _userData!)),
                                            );
                                            if (result == true) _fetchUserData();
                                          },
                                          iconColor: Colors.teal,
                                        ),
                                        _NavTile(
                                          icon: Iconsax.location,
                                          title: 'Coordonnées',
                                          subtitle: 'Adresse, numéro de téléphone',
                                          onTap: () async {
                                            final result = await Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (_) => EditCoordonneesScreen(userData: _userData!)),
                                            );
                                            if (result == true) _fetchUserData();
                                          },
                                          iconColor: Colors.cyan,
                                        ),
                                        _NavTile(
                                          icon: Iconsax.security_user,
                                          title: 'Sécurité',
                                          subtitle: 'Mot de passe',
                                          onTap: () => _showSecurityDialog(context),
                                          iconColor: Colors.brown,
                                        ),
                                        const SizedBox(height: 24),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 24),
                                          child: SizedBox(
                                            width: double.infinity,
                                            height: 52,
                                            child: InkWell(
                                              onTap: _logout,
                                              borderRadius: BorderRadius.circular(14),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  gradient: AppColors.primaryGradient,
                                                  borderRadius: BorderRadius.circular(14),
                                                ),
                                                child: const Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Icon(Iconsax.logout, size: 20, color: Colors.white),
                                                    SizedBox(width: 8),
                                                    Text('Déconnexion', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginPrompt(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.user, size: 64, color: AppColors.textHint), // Couleur de l'icône modifiée
          const SizedBox(height: 12),
          const Text('Vous n’êtes pas connecté'),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: InkWell(
              onTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              ),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Text('Se connecter', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  void _showSecurityDialog(BuildContext context) {
    final newPassController = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sécurité'),
        content: TextField(
          controller: newPassController,
          decoration: const InputDecoration(labelText: 'Nouveau mot de passe'),
          obscureText: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newPass = newPassController.text.trim();
              if (newPass.isNotEmpty) {
                try {
                  await FirebaseAuth.instance.currentUser?.updatePassword(newPass);
                  if (!mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Mot de passe mis à jour.')),
                  );
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erreur : $e')),
                  );
                }
              }
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }
}

// ... Les autres widgets (_IdentityCard, _InfoGrid, etc.) restent inchangés ...
class _IdentityCard extends StatelessWidget {
  final Map<String, dynamic>? userData;
  final String uid;
  const _IdentityCard({this.userData, required this.uid});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowColor.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.primaryColor, width: 2),
                image: DecorationImage(
                  image: userData?['photoUrl'] != null && userData!['photoUrl'].isNotEmpty
                      ? NetworkImage(userData!['photoUrl'])
                      : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              userData?['fullName'] ?? 'Utilisateur Adomed',
              style: theme.textTheme.headlineSmall?.copyWith(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'UA${uid.substring(0, 6)}',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.primaryColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${_calculateAge(userData?['birthDate'])} ans, ${userData?['city'] ?? 'Ville non définie'}',
              style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.secondaryText),
            ),
          ],
        ),
      ),
    );
  }

  int _calculateAge(String? birthDate) {
    if (birthDate == null || birthDate.isEmpty) return 0;
    try {
      final dateOfBirth = DateTime.parse(birthDate);
      final today = DateTime.now();
      int age = today.year - dateOfBirth.year;
      if (today.month < dateOfBirth.month || (today.month == dateOfBirth.month && today.day < dateOfBirth.day)) {
        age--;
      }
      return age;
    } catch (e) {
      return 0;
    }
  }
}

class _InfoGrid extends StatelessWidget {
  final Map<String, dynamic> userData;
  const _InfoGrid({required this.userData});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowColor.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _InfoItem(
              icon: Iconsax.fatrows,
              label: 'Abonnement',
              value: userData['subscription'] ?? 'Standard',
            ),
            _InfoItem(
              icon: Iconsax.health,
              label: 'Groupe sanguin',
              value: userData['bloodGroup'] ?? 'Non défini',
            ),
            _InfoItem(
              icon: Iconsax.calendar,
              label: 'Dernier bilan',
              value: userData['lastCheck'] ?? 'N/A',
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  
  const _InfoItem({required this.icon, required this.label, required this.value});
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, color: theme.primaryColor, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(color: AppColors.secondaryText),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class _NavTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color iconColor;
  const _NavTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowColor.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: iconColor, size: 28),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: AppColors.textHint, size: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }
}