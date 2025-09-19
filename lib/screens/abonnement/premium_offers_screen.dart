// lib/screens/abonnement/premium_offers_screen.dart

import 'package:flutter/material.dart';
import 'package:adomed_app/theme/app_theme.dart';
import 'package:photo_view/photo_view.dart';
import 'package:iconsax/iconsax.dart';

// Modèle pour représenter une option de prix
class PriceOption {
  final String price;
  final String description;

  const PriceOption({required this.price, required this.description});
}

// Modèle pour représenter une offre d'abonnement complète
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

// --- Données des offres, basées sur votre document ---
final List<SubscriptionOffer> premiumOffers = [
  SubscriptionOffer(
    title: "Accès Basique",
    subtitle: "VOTRE ASSISTANT SANTÉ DIGITAL !",
    imagePath: "assets/images/offers/offre_basique.jpeg",
    features: [
      "Accès partiel à l'application Adomed",
      "1 discussion/mois avec un médecin par messagerie",
      "Assistant \"DIOKARA\" et blog santé inclus",
      "Suivi gratuit tension, diabète, obésité",
      "Interprétation gratuite de vos bilans médicaux",
    ],
    closingText: "Parfait pour les petits budgets et les questions santé occasionnelles.",
    prices: [
      PriceOption(price: "600 FCFA", description: "/ mois"),
      PriceOption(price: "5 000 FCFA", description: "/ an"),
    ],
    buttonText: "S'ABONNER",
  ),
  SubscriptionOffer(
    title: "Accès Premium",
    subtitle: "VOTRE COMPAGNON SANTÉ ILLIMITÉ !",
    imagePath: "assets/images/offers/offre_premium.jpeg",
    features: [
      "Accès COMPLET à l'application Adomed",
      "Discussions ILLIMITÉES avec un médecin",
      "Agenda et rappels de santé personnalisés",
      "Tous les avantages du pack basique, mais en illimité !",
    ],
    closingText: "Pour ceux qui veulent un accès illimité à un conseil médical de qualité, 24h/24 et 7j/7.",
    prices: [
      PriceOption(price: "1 100 FCFA", description: "/ mois"),
      PriceOption(price: "9 000 FCFA", description: "/ an"),
    ],
    buttonText: "PASSER EN PREMIUM",
  ),
  SubscriptionOffer(
    title: "Médecin de Famille \"Basique\"",
    subtitle: "VOTRE MÉDECIN EN LIGNE, MÊME POUR PETIT BUDGET !",
    imagePath: "assets/images/offers/medecin_famille_basique.jpeg",
    features: [
      "3 consultations vidéo/an avec un médecin généraliste",
      "Réduction de 10% sur les consultations et bilans à domicile",
      "Médecin disponible 24h/24 et 7j/7",
      "1 livraison gratuite sur la marketplace",
    ],
    closingText: "Un forfait malin pour avoir un avis médical rapide sans se déplacer.",
    prices: [
      PriceOption(price: "15 000 FCFA", description: "/ an (1 pers)"),
      PriceOption(price: "35 000 FCFA", description: "/ an (4 pers)"),
    ],
    buttonText: "CHOISIR CE PACK",
  ),
    SubscriptionOffer(
    title: "Médecin de Famille \"Diamant\"",
    subtitle: "L'EXCELLENCE MÉDICALE SANS LIMITE !",
    imagePath: "assets/images/offers/medecin_famille_diamant.jpeg",
    features: [
      "Consultations vidéo ILLIMITÉES avec un médecin généraliste",
      "1 consultation généraliste + 1 bilan infectieux GRATUITS à domicile",
      "TOUS vos bilans à domicile SANS FRAIS de transport",
      "Réduction de 10% sur les autres services",
    ],
    closingText: "Le summum du confort et de la tranquillité d'esprit !",
    prices: [
      PriceOption(price: "75 000 FCFA", description: "/ an (1 pers)"),
      PriceOption(price: "100 000 FCFA", description: "/ an (2 pers)"),
    ],
    buttonText: "OPTER PACK DIAMANT",
  ),
  SubscriptionOffer(
    title: "Suivi de Grossesse",
    subtitle: "VOTRE GYNÉCO EN LIGNE POUR UNE GROSSESSE ZEN !",
    imagePath: "assets/images/offers/suivi_grossesse.jpeg",
    features: [
      "Consultations vidéo ILLIMITÉES avec votre gynécologue",
      "PACK de bilan prénatal inclus",
      "3 échographies prénatales + 7 consultations prénatales",
      "Médecin disponible 24h/24 et 7j/7",
    ],
    closingText: "Vivez une grossesse sereine. Un accompagnement personnalisé et complet.",
    prices: [
      PriceOption(price: "140 000 FCFA", description: "/ an"),
    ],
    buttonText: "SOUSCRIRE",
  ),
  SubscriptionOffer(
    title: "Suivi Bébé 0-24 mois",
    subtitle: "VOTRE PÉDIATRE EN LIGNE POUR BÉBÉ !",
    imagePath: "assets/images/offers/suivi_bebe.jpeg",
    features: [
      "Consultations vidéo ILLIMITÉES avec votre pédiatre",
      "1 consultation/mois au cabinet + 1 consultation à domicile",
      "Médecin disponible 24h/24 et 7j/7 pour toutes les urgences",
      "3 livraisons gratuites sur la marketplace",
    ],
    closingText: "Le partenaire idéal pour les jeunes parents.",
    prices: [
      PriceOption(price: "150 000 FCFA", description: "/ an"),
    ],
    buttonText: "SOUSCRIRE",
  ),
  SubscriptionOffer(
    title: "Suivi Enfant 25 mois et +",
    subtitle: "VOTRE PÉDIATRE POUR GRANDIR EN TOUTE SÉRÉNITÉ !",
    imagePath: "assets/images/offers/suivi_bebe.jpeg", // Placeholder image
    features: [
        "Consultations vidéo ILLIMITÉES avec votre pédiatre",
        "6 consultations/an au cabinet + 1 consultation à domicile",
        "Médecin disponible 24h/24 et 7j/7",
        "3 livraisons gratuites sur la marketplace",
    ],
    closingText: "Un accompagnement adapté pour les enfants en bas âge et au-delà.",
    prices: [
        PriceOption(price: "100 000 FCFA", description: "/ an"),
    ],
    buttonText: "SOUSCRIRE",
  ),
];


class PremiumOffersScreen extends StatelessWidget {
  const PremiumOffersScreen({super.key});

  void _initiatePayment(BuildContext context, SubscriptionOffer offer) {
    // TODO: Implémenter la logique de paiement avec l'API ici
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Redirection vers le paiement pour l'offre : ${offer.title}"),
        backgroundColor: Colors.green,
      ),
    );
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
        title: const Text("Nos Offres d'Abonnement"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: premiumOffers.length,
          itemBuilder: (context, index) {
            final offer = premiumOffers[index];
            return _OfferCard(
              offer: offer,
              onPay: () => _initiatePayment(context, offer),
              onImageTap: () => _showFullScreenImage(context, offer.imagePath),
            );
          },
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
              // Gérer les erreurs si l'image n'est pas trouvée
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 180,
                  color: Colors.grey[200],
                  child: const Center(
                    child: Text(
                      'Image non disponible',
                      style: TextStyle(color: Colors.red),
                    ),
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
                        const Icon(Iconsax.tick_circle, size: 16, color: Colors.green),
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
                // Affichage des prix
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: offer.prices.map((p) {
                      return Flexible(
                        child: Column(
                          children: [
                            Text(
                              p.price,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                            ),
                            Text(
                              p.description,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
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
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                offer.buttonText,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget simple pour afficher l'image en plein écran
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