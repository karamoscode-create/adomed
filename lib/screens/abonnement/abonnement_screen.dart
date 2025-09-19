// lib/screens/abonnement/abonnement_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:adomed_app/theme/app_theme.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:iconsax/iconsax.dart';
import 'package:share_plus/share_plus.dart';
import 'premium_offers_screen.dart'; // <--- IMPORT AJOUTÉ ICI

class AbonnementScreen extends StatefulWidget {
  const AbonnementScreen({super.key});

  @override
  State<AbonnementScreen> createState() => _AbonnementScreenState();
}

class _AbonnementScreenState extends State<AbonnementScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _showRechargeDialog() {
    final TextEditingController amountController = TextEditingController();
    final List<String> methods = ['Wave', 'Orange Money', 'MTN Money', 'Moov Money'];
    String? selectedMethod;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Recharger le portefeuille'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Montant à recharger',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Méthode de paiement',
                      border: OutlineInputBorder(),
                    ),
                    value: selectedMethod,
                    items: methods.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedMethod = newValue;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final amount = int.tryParse(amountController.text);
                    if (amount != null && selectedMethod != null) {
                      _sendWhatsAppMessage(
                        "Recharge de portefeuille",
                        "Bonjour, je souhaite recharger mon portefeuille Adomed de $amount FCFA via $selectedMethod.",
                      );
                      Navigator.of(context).pop();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Veuillez entrer un montant et choisir une méthode.')),
                      );
                    }
                  },
                  child: const Text('Confirmer'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Cette fonction n'est plus utilisée, mais on la garde au cas où.
  void _buyPremiumSubscription() {
    final amount = 1000;
    _sendWhatsAppMessage(
      "Abonnement Premium",
      "Bonjour, je souhaite m'abonner au plan Premium Adomed pour $amount FCFA.",
    );
  }

  void _sendWhatsAppMessage(String title, String message) async {
    final String whatsappNumber = '2250704044643'; // Numéro Adomed
    final String encodedMessage = Uri.encodeComponent("$message\n\nNom d'utilisateur : ${currentUser?.email ?? 'Non spécifié'}");
    final Uri url = Uri.parse("https://wa.me/$whatsappNumber?text=$encodedMessage");

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible d\'ouvrir WhatsApp. Vérifiez que l\'application est installée.')),
      );
    }
  }

  void _shareReferralLink(String link) {
    Share.share('Rejoignez Adomed et gagnez des points ! Utilisez mon lien de parrainage pour télécharger l\'application : $link');
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return const Center(child: Text('Veuillez vous connecter.'));
    }

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
                    Padding(
                      padding: const EdgeInsets.fromLTRB(4, 20, 16, 10),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimaryColor),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          const Expanded(
                            child: Text(
                              'Abonnement & Portefeuille',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimaryColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 48),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        child: Column(
                          children: [
                            _WalletCard(
                              firestore: _firestore,
                              uid: currentUser!.uid,
                              onRecharge: _showRechargeDialog,
                            ),
                            const SizedBox(height: 24),
                            _ReferralSection(
                              firestore: _firestore,
                              uid: currentUser!.uid,
                              onShareLink: _shareReferralLink,
                            ),
                            const SizedBox(height: 24),
                            _TransactionHistorySection(
                              firestore: _firestore,
                              uid: currentUser!.uid,
                            ),
                            const SizedBox(height: 24),
                            _CurrentOfferCard(
                              firestore: _firestore,
                              uid: currentUser!.uid,
                            ),
                          ],
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
}


/* ========================= WIDGETS DYNAMIQUES ========================= */

class _WalletCard extends StatelessWidget {
  final FirebaseFirestore firestore;
  final String uid;
  final VoidCallback onRecharge;

  const _WalletCard({required this.firestore, required this.uid, required this.onRecharge});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: firestore.collection('users').doc(uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingCard();
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return _buildErrorCard('Données utilisateur introuvables');
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final int amount = data['walletAmount'] ?? 0;
        final String userName = data['firstName'] ?? 'Utilisateur';

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Portefeuille Adomed',
                style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Text(
                '$amount FCFA',
                style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const Divider(color: Colors.white30, height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(Iconsax.wallet, color: Colors.white, size: 36),
                  TextButton.icon(
                    onPressed: onRecharge,
                    icon: const Icon(Iconsax.add_square, color: Colors.white),
                    label: const Text('Recharger', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Bienvenue ${userName.toUpperCase()}',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildLoadingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
  
  Widget _buildErrorCard(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Text(message, style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}

class _ReferralSection extends StatelessWidget {
  final FirebaseFirestore firestore;
  final String uid;
  final Function(String) onShareLink;

  const _ReferralSection({
    required this.firestore,
    required this.uid,
    required this.onShareLink,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final referralLink = 'https://adomed.app/referral?uid=$uid';

    return StreamBuilder<DocumentSnapshot>(
      stream: firestore.collection('users').doc(uid).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const SizedBox.shrink();
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final int points = data['referralPoints'] ?? 0;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: AppColors.shadowColor.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Iconsax.people, color: theme.primaryColor, size: 28),
                  const SizedBox(width: 8),
                  Text('Parrainage & Points', style: theme.textTheme.titleLarge),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Vos points de parrainage :',
                    style: TextStyle(fontSize: 16),
                  ),
                  Chip(
                    label: Text(
                      '$points points',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    backgroundColor: AppColors.primary,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Partagez votre lien. Chaque inscription validée vous rapporte 1 point.',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      referralLink,
                      style: TextStyle(fontSize: 12, color: theme.primaryColor, decoration: TextDecoration.underline),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 20),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: referralLink));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Lien de parrainage copié !')),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => onShareLink(referralLink),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: theme.primaryColor),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Partager le lien de parrainage'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TransactionHistorySection extends StatelessWidget {
  final FirebaseFirestore firestore;
  final String uid;

  const _TransactionHistorySection({required this.firestore, required this.uid});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: AppColors.shadowColor.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Historique des transactions', style: theme.textTheme.titleLarge),
          const SizedBox(height: 16),
          StreamBuilder<QuerySnapshot>(
            stream: firestore
                .collection('users')
                .doc(uid)
                .collection('transactions')
                .orderBy('date', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('Aucune transaction trouvée.'));
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final doc = snapshot.data!.docs[index];
                  final transaction = doc.data() as Map<String, dynamic>;
                  final isCredit = transaction['type'] == 'Recharge' || transaction['type'] == 'Abonnement' || transaction['amount'] > 0;
                  final date = (transaction['date'] as Timestamp?)?.toDate();

                  return ListTile(
                    leading: Icon(
                      isCredit ? Iconsax.arrow_down : Iconsax.arrow_up,
                      color: isCredit ? Colors.green : Colors.red,
                    ),
                    title: Text(transaction['type']),
                    subtitle: Text(date?.toLocal().toString().split(' ')[0] ?? 'Date inconnue'),
                    trailing: Text(
                      '${transaction['amount'].toStringAsFixed(0)} FCFA',
                      style: TextStyle(
                        color: isCredit ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CurrentOfferCard extends StatelessWidget {
  final FirebaseFirestore firestore;
  final String uid;

  const _CurrentOfferCard({required this.firestore, required this.uid});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return StreamBuilder<DocumentSnapshot>(
      stream: firestore.collection('users').doc(uid).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const SizedBox.shrink();
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final bool isPremium = data['isPremium'] ?? false;
        
        final String statusText = isPremium ? 'Actif' : 'Standard';
        final Color statusColor = isPremium ? Colors.green : AppColors.primary;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: AppColors.shadowColor.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Offre actuelle', style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Plan $statusText', style: const TextStyle(fontSize: 16)),
                  Chip(
                    label: Text(statusText, style: TextStyle(color: theme.colorScheme.onPrimary, fontSize: 12, fontWeight: FontWeight.bold)),
                    backgroundColor: statusColor,
                    side: BorderSide.none,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                isPremium
                    ? 'Vous bénéficiez de toutes les fonctionnalités de l\'application.'
                    : 'Accès limité à certains services. Mettez à niveau pour plus de fonctionnalités.',
                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 16), // Espace ajouté
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  // --- MODIFICATION APPLIQUÉE ICI ---
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PremiumOffersScreen()),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: theme.primaryColor),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Explorer les offres Premium'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}