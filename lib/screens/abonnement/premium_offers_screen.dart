// lib/screens/abonnement/premium_offers_screen.dart

import 'package:flutter/material.dart';
import 'package:adomed_app/theme/app_theme.dart';
import 'package:photo_view/photo_view.dart';
import 'package:iconsax/iconsax.dart';
// Ajout nécessaire pour ouvrir WhatsApp
import 'package:url_launcher/url_launcher.dart'; 

class PriceOption {
  final String price;
  final String description;

  const PriceOption({required this.price, required this.description});
}

class SubscriptionOffer {
  final String title;
  final String subtitle;
  final String imagePath;
  final List<String> features;
  final String closingText;
  final List<PriceOption> prices;
  final String buttonText;

  const SubscriptionOffer({
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.features,
    required this.closingText,
    required this.prices,
    required this.buttonText,
  });
}

final List<SubscriptionOffer> premiumOffers = [
  // --- OFFRES DE SERVICES PHYSIQUES ---
  SubscriptionOffer(
    title: "Pack Médecin de Famille",
    subtitle: "CONSULTATIONS PHYSIQUES ET SUIVI",
    imagePath: "assets/images/offers/medecin_famille_basique.jpeg",
    features: [
      "3 consultations vidéo avec un médecin généraliste",
      "Réduction sur les actes médicaux à domicile",
      "Disponibilité des médecins 24h/24",
      "Coordination des soins physiques",
    ],
    closingText: "Idéal pour un suivi médical régulier sans déplacement.",
    prices: [
      PriceOption(price: "15 000 FCFA", description: " / an"),
    ],
    buttonText: "RÉSERVER CE SOIN",
  ),
  SubscriptionOffer(
    title: "Suivi Médical Complet",
    subtitle: "VISITES À DOMICILE ET ANALYSES",
    imagePath: "assets/images/offers/medecin_famille_diamant.jpeg",
    features: [
      "Consultations illimitées avec médecin généraliste",
      "1 visite de médecin à domicile incluse",
      "Prélèvements biologiques à domicile sans frais de déplacement",
      "Coordination complète des soins",
    ],
    closingText: "Une prise en charge complète à domicile.",
    prices: [
      PriceOption(price: "75 000 FCFA", description: " / an"),
    ],
    buttonText: "RÉSERVER CE SOIN",
  ),
  SubscriptionOffer(
    title: "Suivi de Grossesse",
    subtitle: "ACCOMPAGNEMENT GYNÉCOLOGIQUE",
    imagePath: "assets/images/offers/suivi_grossesse.jpeg",
    features: [
      "Suivi complet avec votre gynécologue",
      "Bilan prénatal physique inclus",
      "Coordination des 3 échographies prénatales",
      "Assistance médicale 24h/24",
    ],
    closingText: "Un accompagnement médical physique et constant.",
    prices: [
      PriceOption(price: "140 000 FCFA", description: " / an"),
    ],
    buttonText: "CONTACTER UN MÉDECIN",
  ),
  SubscriptionOffer(
    title: "Suivi Pédiatrique (0-24 mois)",
    subtitle: "CONSULTATIONS ET VISITES BÉBÉ",
    imagePath: "assets/images/offers/suivi_bebe.jpeg",
    features: [
      "Suivi régulier avec votre pédiatre",
      "Visites au cabinet et à domicile programmées",
      "Assistance urgence pédiatrique 24h/24",
      "Livraison de médicaments à domicile",
    ],
    closingText: "Le suivi médical essentiel pour les nourrissons.",
    prices: [
      PriceOption(price: "150 000 FCFA", description: " / an"),
    ],
    buttonText: "CONTACTER UN PÉDIATRE",
  ),
];

class PremiumOffersScreen extends StatelessWidget {
  const PremiumOffersScreen({super.key});

  // --- NOUVELLE FONCTION : REDIRECTION WHATSAPP ---
  Future<void> _contactViaWhatsApp(BuildContext context, SubscriptionOffer offer) async {
    // Numéro du support ADOMED
    const String phoneNumber = "2250704044643"; 
    
    // Message pré-rempli
    final String message = "Bonjour ADOMED,\n\n"
        "Je souhaite souscrire au *${offer.title}* (${offer.prices.first.price}).\n"
        "Merci de m'indiquer la procédure pour le rendez-vous.";

    // Création de l'URL WhatsApp
    final Uri whatsappUrl = Uri.parse(
      "https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}",
    );

    try {
      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
      } else {
        // Fallback si WhatsApp n'est pas installé ou erreur
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Impossible d'ouvrir WhatsApp. Contactez le +225 07 04 04 46 43"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("Erreur WhatsApp: $e");
    }
  }

  void _showFullScreenImage(BuildContext context, String imagePath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenImageViewer(imagePath: imagePath),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nos Forfaits de Soins"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: premiumOffers.length + 1,
                itemBuilder: (context, index) {
                  if (index == premiumOffers.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
                      child: Column(
                        children: [
                          Text(
                            "Informations Légales",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Ces forfaits concernent exclusivement des prestations médicales physiques (consultations, visites, actes). Ils sont réalisés par des médecins inscrits à l'Ordre National des Médecins de Côte d'Ivoire.",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Source : Ordre National des Médecins / Ministère de la Santé.",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white70, fontSize: 12, fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                    );
                  }

                  final offer = premiumOffers[index];
                  return _OfferCard(
                    offer: offer,
                    onPay: () => _contactViaWhatsApp(context, offer), // Appel WhatsApp ici
                    onImageTap: () => _showFullScreenImage(context, offer.imagePath),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OfferCard extends StatelessWidget {
  final SubscriptionOffer offer;
  final VoidCallback onPay;
  final VoidCallback onImageTap;

  const _OfferCard({
    required this.offer,
    required this.onPay,
    required this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            onTap: onImageTap,
            child: Image.asset(
              offer.imagePath,
              fit: BoxFit.cover,
              height: 180,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 180,
                  color: Colors.grey[200],
                  child: const Center(
                    child: Icon(Icons.broken_image, color: Colors.grey),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  offer.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  offer.subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey[600],
                      ),
                ),
                const Divider(height: 24),
                ...offer.features.map(
                  (feature) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Iconsax.health, size: 16, color: Colors.green),
                        const SizedBox(width: 8),
                        Expanded(child: Text(feature)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  offer.closingText,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[700],
                      ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: offer.prices.map((p) {
                      return Column(
                        children: [
                          Text(
                            p.price,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                          ),
                          Text(
                            "Honoraires médicaux",
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: ElevatedButton(
              onPressed: onPay,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary, // Couleur WhatsApp possible aussi (0xFF25D366)
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Iconsax.message), // Icône de message
                  const SizedBox(width: 8),
                  Text(
                    offer.buttonText, // "RÉSERVER" ou "CONTACTER"
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FullScreenImageViewer extends StatelessWidget {
  final String imagePath;
  const FullScreenImageViewer({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: PhotoView(
          imageProvider: AssetImage(imagePath),
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.covered * 2,
        ),
      ),
    );
  }
}
