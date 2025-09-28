// lib/screens/marketplace/marketplace_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:adomed_app/theme/app_theme.dart';
import 'product_detail_screen.dart'; 
import '../../models/cart_model.dart';
import 'checkout_screen.dart';

// Le modèle de données Product reste inchangé
class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
  });

  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      imageUrl: data['imageUrl'] ?? '',
      category: data['category'] ?? 'Autre',
    );
  }
}

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  String _selectedCategory = 'Tout';
  final TextEditingController _searchController = TextEditingController();

  final List<Product> _allProducts = [
    // --- PRODUITS EXISTANTS ---
    Product(
      id: 'prod1',
      name: 'Stéthoscope 3M Littmann Classic III',
      description: "Le stéthoscope Littmann Classic III est un outil de diagnostic de haute qualité pour les professionnels de santé. Il offre une acoustique fiable et est conçu pour durer. Parfait pour les examens physiques et le diagnostic des patients adultes et pédiatriques.",
      price: 95000,
      imageUrl: 'assets/images/marketplace/Le stethoscope Littmann Classic III.png',
      category: 'Matériel Médical',
    ),
    Product(
      id: 'prod2',
      name: 'Tensiomètre Électronique Omron M7 Intelli IT',
      description: "Le tensiomètre Omron M7 Intelli IT permet des mesures précises de la pression artérielle à domicile. Grâce à la technologie Intelli Wrap Cuff, il assure une mesure précise dans n'importe quelle position autour du bras. Connectivité Bluetooth pour le suivi des données.",
      price: 45000,
      imageUrl: 'assets/images/marketplace/Tensiometre Electronique OmronM7Intelli IT.png',
      category: 'Matériel Médical',
    ),
    Product(
      id: 'prod3',
      name: 'Thermomètre Infrarouge Sans Contact',
      description: "Mesurez la température corporelle sans contact, de manière hygiénique et rapide. Idéal pour les bébés et les enfants. Dispose d'un grand écran LCD avec alerte de fièvre et d'une mémoire de mesure.",
      price: 15000,
      imageUrl: 'assets/images/marketplace/thermometre infra-rouge.png',
      category: 'Matériel Médical',
    ),
    Product(
      id: 'prod4',
      name: 'Glucomètre Accu-Chek Instant',
      description: "Le système de surveillance de la glycémie Accu-Chek Instant est simple et rapide. Il vous donne une lecture en moins de 4 secondes. Le kit comprend le lecteur, les bandelettes de test et les lancettes.",
      price: 25000,
      imageUrl: 'assets/images/marketplace/Glucometre Accu-Chek Instant.png',
      category: 'Matériel Médical',
    ),
    Product(
      id: 'prod5',
      name: 'Vitamines C Liposomale',
      description: "Formule de vitamine C liposomale à haute biodisponibilité. Aide à renforcer le système immunitaire, à réduire la fatigue et à protéger les cellules du stress oxydatif. Flacon de 60 gélules.",
      price: 22000,
      imageUrl: 'assets/images/marketplace/Vitamines C liposomale.png',
      category: 'Compléments Alimentaires',
    ),
    Product(
      id: 'prod6',
      name: 'Probiotiques 10 Souches',
      description: "Ce complexe de probiotiques contient 10 souches différentes pour une flore intestinale équilibrée. Il soutient la digestion, améliore l'absorption des nutriments et renforce l'immunité.",
      price: 18000,
      imageUrl: 'assets/images/marketplace/probiotiques.png',
      category: 'Compléments Alimentaires',
    ),
    Product(
      id: 'prod7',
      name: 'Test d\'Ovulation Digital Clearblue',
      description: "Le test d'ovulation digital Clearblue est précis et facile à utiliser. Il identifie vos 2 jours les plus fertiles pour maximiser vos chances de conception. Le résultat est clair sur l'écran digital.",
      price: 12000,
      imageUrl: 'assets/images/marketplace/test d\'ovulation.png',
      category: 'Santé Féminine & Fertilité',
    ),
    Product(
      id: 'prod8',
      name: 'Coupe Menstruelle Lunacopine',
      description: "La coupe menstruelle Lunacopine est une alternative écologique et économique aux protections périodiques jetables. Faite en silicone médical, elle est confortable et sûre. Disponible en plusieurs tailles.",
      price: 9000,
      imageUrl: 'assets/images/marketplace/coupe menstruelle.png',
      category: 'Santé Féminine & Fertilité',
    ),
    Product(
      id: 'prod9',
      name: 'Masques FFP2 Pack de 20',
      description: "Masques de protection FFP2 certifiés, offrant une filtration supérieure contre les particules fines, les poussières et les aérosols. Confortables et ajustables pour un usage prolongé. Pack de 20 masques.",
      price: 7500,
      imageUrl: 'assets/images/marketplace/masques FFP2 paquet de 20.png',
      category: 'Consommables Médicaux',
    ),
    Product(
      id: 'prod10',
      name: 'Seringues Stériles 5ml Pack de 10',
      description: "Seringues de 5ml avec aiguilles, stériles et à usage unique. Idéales pour les injections, les prélèvements et les soins médicaux. Emballées individuellement pour une hygiène optimale. Pack de 10 seringues.",
      price: 2500,
      imageUrl: 'assets/images/marketplace/pack de seringues.png',
      category: 'Consommables Médicaux',
    ),
    Product(
      id: 'prod11',
      name: 'Genouillère de Maintien Rotulien',
      description: "Cette genouillère de compression offre un soutien ciblé pour la rotule et les ligaments. Idéale pour les douleurs articulaires, l'arthrose ou la rééducation après une blessure. Matériau respirant et confortable.",
      price: 15000,
      imageUrl: 'assets/images/marketplace/Genouillere de maintien rotulien.png',
      category: 'Orthopédie & Mobilité',
    ),
    Product(
      id: 'prod12',
      name: 'Béquilles de Marche Réglables',
      description: "Paire de béquilles de marche en aluminium léger et résistant. Réglables en hauteur, elles offrent un support stable et sûr lors de la rééducation ou en cas de mobilité réduite. Poignées et accoudoirs rembourrés.",
      price: 12000,
      imageUrl: 'assets/images/marketplace/paire de bequilles.png',
      category: 'Orthopédie & Mobilité',
    ),
    Product(
      id: 'prod13',
      name: 'Test de Grossesse Rapide et Précoce',
      description: "Détectez une grossesse 6 jours avant la date présumée de vos règles. Ce test est fiable à plus de 99% et vous donne un résultat rapide. Livré avec deux tests.",
      price: 8000,
      imageUrl: 'assets/images/marketplace/test de grossesse.png',
      category: 'Maternité, Puériculture & Tests',
    ),
    Product(
      id: 'prod14',
      name: 'Tire-Lait Électrique Philips Avent',
      description: "Le tire-lait Philips Avent est conçu pour un pompage confortable et efficace. Il offre un mode de stimulation et trois réglages d'expression pour un confort optimal. Compact et facile à transporter.",
      price: 65000,
      imageUrl: 'assets/images/marketplace/tire-lait.png',
      category: 'Maternité, Puériculture & Tests',
    ),
    Product(
      id: 'prod15',
      name: 'Poussette 3-en-1 Bébé Confort',
      description: "Poussette évolutive 3-en-1 qui s'adapte à la croissance de votre enfant, de la naissance à 4 ans. Inclut un landau, une coque auto et une assise réversible. Confort et sécurité garantis.",
      price: 250000,
      imageUrl: 'assets/images/marketplace/la poussette.png',
      category: 'Maternité, Puériculture & Tests',
    ),
    Product(
      id: 'prod16',
      name: 'Complément pour Diabète à base de Cannelle',
      description: "Ce complément alimentaire est formulé avec de l'extrait de cannelle pour aider à réguler la glycémie. Contient également du chrome et de l'acide alpha-lipoïque pour un soutien métabolique optimal. Veuillez consulter un médecin avant utilisation.",
      price: 18500,
      imageUrl: 'assets/images/marketplace/complement pour le diabete.png',
      category: 'Compléments pour Maladies Spécifiques',
    ),

    // --- DÉBUT DE LA LISTE DES NOUVEAUX PRODUITS ---
    // Pansement (Produits déjà dans le code)
    Product(id: 'prod17', name: 'Alcool 90° 1 litre', description: '', price: 3000, imageUrl: 'assets/images/marketplace/Alcool 90° 1 litre.png', category: 'Consommables Médicaux'),
    Product(id: 'prod18', name: 'Bandes 15 x 450 cm pqt/12', description: '', price: 600, imageUrl: 'assets/images/marketplace/Bandes15.png', category: 'Consommables Médicaux'),
    Product(id: 'prod19', name: 'Bande 10 x 450 cm pqt/12', description: '', price: 350, imageUrl: 'assets/images/marketplace/Bande10.png', category: 'Consommables Médicaux'),
    Product(id: 'prod20', name: 'Compresses non stériles 16 plis', description: '', price: 3000, imageUrl: 'assets/images/marketplace/Compresses non steriles 16 plis.png', category: 'Consommables Médicaux'),
    Product(id: 'prod21', name: 'Sparadraps 5 m x 18 cm', description: '', price: 3000, imageUrl: 'assets/images/marketplace/Sparadraps 5 m x 18 cm.png', category: 'Consommables Médicaux'),
    Product(id: 'prod22', name: 'Fil de suture résorbable bte/12 pcs', description: '', price: 12000, imageUrl: 'assets/images/marketplace/Fil.png', category: 'Consommables Médicaux'),
    
    // Protection & Consommables (Produits déjà dans le code et ajoutés)
    Product(id: 'prod23', name: 'Alèze rouleau d\'examen', description: '', price: 9000, imageUrl: 'assets/images/marketplace/Aleze rouleau d\'examen.png', category: 'Consommables Médicaux'),
    Product(id: 'prod24', name: 'Masque chirurgical pqt/50', description: '', price: 4500, imageUrl: 'assets/images/marketplace/Masque.png', category: 'Consommables Médicaux'),
    Product(id: 'prod25', name: 'Gant stérile la paire', description: '', price: 250, imageUrl: 'assets/images/marketplace/Gant sterile la paire.png', category: 'Consommables Médicaux'),
    Product(id: 'prod26', name: 'Gant propre pqt/100', description: '', price: 3000, imageUrl: 'assets/images/marketplace/Gant propre.png', category: 'Consommables Médicaux'),
    Product(id: 'prod21_new', name: 'Charlotte, Blouses jetables', description: '', price: 3000, imageUrl: 'assets/images/marketplace/Charlotte, Blouses jetables.png', category: 'Consommables Médicaux'),
    Product(id: 'prod22_new', name: 'Poches à urine', description: '', price: 1500, imageUrl: 'assets/images/marketplace/Poches a urine.png', category: 'Consommables Médicaux'),

    // Injection & Perfusion (Produits déjà dans le code et ajoutés)
    Product(id: 'prod27', name: 'Seringue 10 cc pqt/100', description: '', price: 5000, imageUrl: 'assets/images/marketplace/Seringue.png', category: 'Consommables Médicaux'),
    Product(id: 'prod28', name: 'Sérum glucosé 500 ml 5%', description: '', price: 850, imageUrl: 'assets/images/marketplace/Serum glucose 500 ml 5%.png', category: 'Consommables Médicaux'),
    Product(id: 'prod29', name: 'Sérum salé 500 ml 0.9%', description: '', price: 800, imageUrl: 'assets/images/marketplace/Serum sale 500 ml 0.9%.png', category: 'Consommables Médicaux'),
    Product(id: 'prod30', name: 'Sonde d\'aspiration', description: '', price: 800, imageUrl: 'assets/images/marketplace/Sonde daspiration.png', category: 'Consommables Médicaux'),
    
    // Diagnostique (Produits déjà dans le code)
    Product(id: 'prod31', name: 'Tensiomètre Spengler lian', description: '', price: 45000, imageUrl: 'assets/images/marketplace/Tensiometre Spengler lian.png', category: 'Matériel Médical'),
    Product(id: 'prod32', name: 'Stéthoscope double pavillon', description: '', price: 20000, imageUrl: 'assets/images/marketplace/Stethoscope double pavillon.png', category: 'Matériel Médical'),
    Product(id: 'prod33', name: 'Thermomètre électronique', description: '', price: 2000, imageUrl: 'assets/images/marketplace/Thermometre electronique.png', category: 'Matériel Médical'),
    Product(id: 'prod34', name: 'Glucomètre on call plus', description: '', price: 20000, imageUrl: 'assets/images/marketplace/Glucometre on call plus.png', category: 'Matériel Médical'),
    Product(id: 'prod35', name: 'Test de malaria accurate', description: '', price: 35000, imageUrl: 'assets/images/marketplace/Test de malaria accurate.png', category: 'Matériel Médical'),

    // Instruments (Produits déjà dans le code)
    Product(id: 'prod36', name: 'Boite de pansement', description: '', price: 30000, imageUrl: 'assets/images/marketplace/Boite de pansement.png', category: 'Matériel Médical'),
    Product(id: 'prod37', name: 'Boite de petite chirurgie', description: '', price: 35000, imageUrl: 'assets/images/marketplace/Boite de petite chirurgie.png', category: 'Matériel Médical'),
    Product(id: 'prod38', name: 'Haricot 500ml', description: '', price: 20000, imageUrl: 'assets/images/marketplace/Haricot.png', category: 'Matériel Médical'),

    // Petit Matériel (Produits déjà dans le code)
    Product(id: 'prod39', name: 'Toise enfant en bois', description: '', price: 20000, imageUrl: 'assets/images/marketplace/Toise enfant en bois.png', category: 'Matériel Médical'),
    Product(id: 'prod40', name: 'Garrot plastique', description: '', price: 4000, imageUrl: 'assets/images/marketplace/Garrot plastique.png', category: 'Consommables Médicaux'),
    Product(id: 'prod41', name: 'Tube rouge pqt/100', description: '', price: 7000, imageUrl: 'assets/images/marketplace/Tube100.png', category: 'Consommables Médicaux'),

    // Mobilier Médical (Produits déjà dans le code)
    Product(id: 'prod42', name: 'Escabot à 2 marches (local)', description: '', price: 35000, imageUrl: 'assets/images/marketplace/Escabot.png', category: 'Orthopédie & Mobilité'),
    Product(id: 'prod43', name: 'Paravent à 3 volets (importé)', description: '', price: 160000, imageUrl: 'assets/images/marketplace/Paravent.png', category: 'Orthopédie & Mobilité'),
    Product(id: 'prod44', name: 'table de pansements locale', description: '', price: 125000, imageUrl: 'assets/images/marketplace/Table de pansement.png', category: 'Orthopédie & Mobilité'),
    Product(id: 'prod45', name: 'table d\'examen locale', description: '', price: 150000, imageUrl: 'assets/images/marketplace/table dexamen locale.png', category: 'Orthopédie & Mobilité'),
    Product(id: 'prod46', name: 'matelas skaï', description: '', price: 45000, imageUrl: 'assets/images/marketplace/matelas skai.png', category: 'Orthopédie & Mobilité'),
    Product(id: 'prod47', name: 'poubelle à pédale', description: '', price: 25000, imageUrl: 'assets/images/marketplace/poubelle a pedale.png', category: 'Consommables Médicaux'),
    
    // Matériel (Produits déjà dans le code)
    Product(id: 'prod48', name: 'Papier ECG 3 pistes rouleau', description: '', price: 10000, imageUrl: 'assets/images/marketplace/Papier ECG 3 pistes rouleau.png', category: 'Consommables Médicaux'),
    Product(id: 'prod49', name: 'Gel à échographie 5 litres', description: '', price: 15000, imageUrl: 'assets/images/marketplace/Gel a echographie 5 litres.png', category: 'Consommables Médicaux'),
    Product(id: 'prod50', name: 'Pèse personne SECA', description: '', price: 85000, imageUrl: 'assets/images/marketplace/Pese personne SECA.png', category: 'Matériel Médical'),
    Product(id: 'prod51', name: 'Urinoir masculin-féminin', description: '', price: 6000, imageUrl: 'assets/images/marketplace/Urinoir masculin-feminin.png', category: 'Consommables Médicaux'),

    // --- DEBUT DES AJOUTS BASES SUR VOTRE LISTE ---
    Product(id: 'prod52', name: 'Abaisselangue en bois (boîte/100)', description: '', price: 1500, imageUrl: 'assets/images/marketplace/Abaisselangue en bois.png', category: 'Consommables Médicaux'),
    Product(id: 'prod53', name: 'Canule de Guedel (taille adulte)', description: '', price: 2500, imageUrl: 'assets/images/marketplace/Canule de Guedel.png', category: 'Consommables Médicaux'),
    Product(id: 'prod54', name: 'Aiguille de ponction lombaire', description: '', price: 3500, imageUrl: 'assets/images/marketplace/Aiguille de ponction lombaire.png', category: 'Consommables Médicaux'),
    Product(id: 'prod55', name: 'Intranule / Cathéter (plusieurs tailles)', description: '', price: 1000, imageUrl: 'assets/images/marketplace/Intranule.png', category: 'Consommables Médicaux'),
    Product(id: 'prod56', name: 'Perfuseur simple', description: '', price: 700, imageUrl: 'assets/images/marketplace/Perfuseur simple.png', category: 'Consommables Médicaux'),
    Product(id: 'prod57', name: 'Seringue 2cc pqt/100', description: '', price: 4000, imageUrl: 'assets/images/marketplace/Seringue 2cc pqt100.png', category: 'Consommables Médicaux'),
    Product(id: 'prod58', name: 'Sonde naso-gastrique', description: '', price: 1200, imageUrl: 'assets/images/marketplace/Sonde nasogastrique.png', category: 'Consommables Médicaux'),
    Product(id: 'prod59', name: 'Sonde d\'intubation', description: '', price: 4000, imageUrl: 'assets/images/marketplace/Sonde dintubation.png', category: 'Consommables Médicaux'),
    Product(id: 'prod60', name: 'Epicrânienne / Microperfuseur', description: '', price: 500, imageUrl: 'assets/images/marketplace/EpicranienneMicroperfuseur.png', category: 'Consommables Médicaux'),
    Product(id: 'prod61', name: 'Speculum vaginal jetable', description: '', price: 800, imageUrl: 'assets/images/marketplace/Speculum vaginal jetable.png', category: 'Consommables Médicaux'),
    Product(id: 'prod62', name: 'Tensiomètre au poignet', description: '', price: 25000, imageUrl: 'assets/images/marketplace/Tensiometre au poignet.png', category: 'Matériel Médical'),
    Product(id: 'prod63', name: 'Thermomètre à Gallium (ordinaire)', description: '', price: 1500, imageUrl: 'assets/images/marketplace/Thermometre a Gallium.png', category: 'Matériel Médical'),
    Product(id: 'prod64', name: 'Marteau à réflexes Buck', description: '', price: 7500, imageUrl: 'assets/images/marketplace/Marteau a reflexes Buck.png', category: 'Matériel Médical'),
    Product(id: 'prod65', name: 'Otoscope de diagnostic', description: '', price: 35000, imageUrl: 'assets/images/marketplace/Otoscope de diagnostic.png', category: 'Matériel Médical'),
    Product(id: 'prod66', name: 'Bandelettes Accu-Chek (boîte/50)', description: '', price: 12000, imageUrl: 'assets/images/marketplace/Bandelettes Accu-Chek.png', category: 'Consommables Médicaux'),
    Product(id: 'prod67', name: 'Bandelettes On Call Plus (boîte/50)', description: '', price: 10000, imageUrl: 'assets/images/marketplace/Bandelettes On Call Plus.png', category: 'Consommables Médicaux'),
    Product(id: 'prod68', name: 'Boîte d\'accouchement complète', description: '', price: 60000, imageUrl: 'assets/images/marketplace/Boite daccouchement.png', category: 'Matériel Médical'),
    Product(id: 'prod69', name: 'Boîte de césarienne complète', description: '', price: 150000, imageUrl: 'assets/images/marketplace/Boite de cesarienne.png', category: 'Matériel Médical'),
    Product(id: 'prod70', name: 'Set de pansement stérile', description: '', price: 2500, imageUrl: 'assets/images/marketplace/Set de pansement sterile.png', category: 'Consommables Médicaux'),
    Product(id: 'prod71', name: 'Set d\'accouchement jetable', description: '', price: 5000, imageUrl: 'assets/images/marketplace/Set daccouchement jetable.png', category: 'Consommables Médicaux'),
    Product(id: 'prod72', name: 'Manche de bistouri N°4', description: '', price: 1500, imageUrl: 'assets/images/marketplace/Manche de bistouri N4.png', category: 'Matériel Médical'),
    Product(id: 'prod73', name: 'Lames de bistouri (boîte/100)', description: '', price: 8000, imageUrl: 'assets/images/marketplace/Lames de bistouri.png', category: 'Consommables Médicaux'),
    Product(id: 'prod74', name: 'Bassin de lit en inox', description: '', price: 9000, imageUrl: 'assets/images/marketplace/Bassin de lit en inox.png', category: 'Matériel Médical'),
    Product(id: 'prod75', name: 'Lit pédiatrique à barreaux', description: '', price: 180000, imageUrl: 'assets/images/marketplace/Lit pediatrique a barreaux.png', category: 'Orthopédie & Mobilité'),
    Product(id: 'prod76', name: 'Table de chevet pour patient', description: '', price: 75000, imageUrl: 'assets/images/marketplace/Table de chevet pour patient.png', category: 'Orthopédie & Mobilité'),
    Product(id: 'prod77', name: 'Potence / Pied à sérum sur roulettes', description: '', price: 45000, imageUrl: 'assets/images/marketplace/Potence Pied a serum sur roulettes.png', category: 'Orthopédie & Mobilité'),
    Product(id: 'prod78', name: 'Électrodes ECG adhésives (sachet/50)', description: '', price: 12000, imageUrl: 'assets/images/marketplace/Electrodes ECG adhesives.png', category: 'Consommables Médicaux'),
    Product(id: 'prod79', name: 'Insufflateur BAVU Adulte', description: '', price: 25000, imageUrl: 'assets/images/marketplace/Insufflateur BAVU Adulte.png', category: 'Matériel Médical'),
    Product(id: 'prod80', name: 'Insufflateur BAVU Bébé', description: '', price: 22000, imageUrl: 'assets/images/marketplace/Insufflateur BAVU Bebe.png', category: 'Matériel Médical'),
    Product(id: 'prod81', name: 'Négatoscope 1 plage', description: '', price: 65000, imageUrl: 'assets/images/marketplace/Negatoscope 1 plage.png', category: 'Matériel Médical'),
    Product(id: 'prod82', name: 'Nébulisateur / Aérosol pneumatique', description: '', price: 40000, imageUrl: 'assets/images/marketplace/Nebulisateur.png', category: 'Matériel Médical'),
    Product(id: 'prod83', name: 'Échographe portable convexe', description: '', price: 1200000, imageUrl: 'assets/images/marketplace/Echographe portable convexe.png', category: 'Matériel Médical'),
    // --- FIN DE LA LISTE DES NOUVEAUX PRODUITS ---
  ];

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartModel>(context);

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
                    // En-tête personnalisé avec le bouton de panier
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Marketplace',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimaryColor,
                            ),
                          ),
                          Stack(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.shopping_cart),
                                color: AppTheme.textPrimaryColor,
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const CheckoutScreen()),
                                  );
                                },
                              ),
                              if (cart.totalItems > 0)
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 16,
                                      minHeight: 16,
                                    ),
                                    child: Text(
                                      '${cart.totalItems}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: CustomScrollView(
                        slivers: [
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              child: TextField(
                                controller: _searchController,
                                decoration: const InputDecoration(
                                  hintText: 'Rechercher un produit...',
                                  prefixIcon: Icon(Icons.search),
                                ),
                                onChanged: (value) => setState(() {}),
                              ),
                            ),
                          ),
                          SliverToBoxAdapter(child: _buildCategories()),
                          
                          // Changement: nous utilisons la liste de produits locale
                          SliverPadding(
                            padding: const EdgeInsets.all(16.0),
                            sliver: SliverGrid(
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                                childAspectRatio: 0.75,
                              ),
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final filteredProducts = _allProducts.where((product) {
                                    final matchesCategory = _selectedCategory == 'Tout' || product.category == _selectedCategory;
                                    final matchesSearch = _searchController.text.isEmpty || product.name.toLowerCase().contains(_searchController.text.toLowerCase());
                                    return matchesCategory && matchesSearch;
                                  }).toList();
                                  
                                  if (index >= filteredProducts.length) {
                                    return null; // Should not happen if childCount is correct
                                  }
                                  
                                  return _buildProductCard(context, filteredProducts[index]);
                                },
                                childCount: _allProducts.where((product) {
                                  final matchesCategory = _selectedCategory == 'Tout' || product.category == _selectedCategory;
                                  final matchesSearch = _searchController.text.isEmpty || product.name.toLowerCase().contains(_searchController.text.toLowerCase());
                                  return matchesCategory && matchesSearch;
                                }).length,
                              ),
                            ),
                          ),
                          if (_allProducts.where((product) {
                                final matchesCategory = _selectedCategory == 'Tout' || product.category == _selectedCategory;
                                final matchesSearch = _searchController.text.isEmpty || product.name.toLowerCase().contains(_searchController.text.toLowerCase());
                                return matchesCategory && matchesSearch;
                              }).isEmpty)
                            const SliverToBoxAdapter(
                              child: Center(
                                child: Padding(
                                  padding: EdgeInsets.only(top: 50.0),
                                  child: Text('Aucun produit trouvé.'),
                                ),
                              ),
                            ),
                        ],
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

  Widget _buildCategories() {
    const categories = ['Tout', 'Matériel Médical', 'Compléments Alimentaires', 'Santé Féminine & Fertilité', 'Consommables Médicaux', 'Orthopédie & Mobilité', 'Maternité, Puériculture & Tests', 'Compléments pour Maladies Spécifiques'];
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = _selectedCategory == category;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _selectedCategory = category);
                }
              },
              backgroundColor: AppColors.cardColor,
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.primaryText,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: isSelected ? AppColors.primary : Colors.grey.shade300),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Image.asset(
                product.imageUrl,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.image_not_supported, color: Colors.grey)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${product.price.toStringAsFixed(0)} FCFA',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}