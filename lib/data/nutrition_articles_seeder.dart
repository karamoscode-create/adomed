import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

Future<void> addNutritionArticles(BuildContext context) async {
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  final categoriesCollection = FirebaseFirestore.instance.collection('nutrition_categories');
  final articlesCollection = FirebaseFirestore.instance.collection('nutrition_articles');
  
  try {
    scaffoldMessenger.showSnackBar(
      const SnackBar(
        content: Text('🔄 Mise à jour des articles en cours...'),
        backgroundColor: Colors.blue,
      ),
    );

    final categories = {
      'nutrition_croissance': {
        'title': 'Nutrition et croissance',
        'description': 'L\'importance des nutriments pour le développement de bébé.',
        'icon': 'trending_up', 'order': 1,
      },
      'aliments_equilibres': {
        'title': 'Aliments équilibrés',
        'description': 'Guide pour créer des repas équilibrés selon l\'âge.',
        'icon': 'balance', 'order': 2,
      },
      'alimentation_comportement': {
        'title': 'Alimentation et comportement',
        'description': 'Comment l\'alimentation influence l\'humeur de bébé.',
        'icon': 'psychology', 'order': 3,
      },
      'diversification_alimentaire': {
        'title': 'La diversification alimentaire',
        'description': 'Étapes et conseils pour introduire de nouveaux aliments.',
        'icon': 'restaurant', 'order': 4,
      },
      'allergies_alimentaires': {
        'title': 'Prévention et gestion des allergies',
        'description': 'Identifier et gérer les risques d\'allergies alimentaires.',
        'icon': 'warning', 'order': 5,
      },
      'astuces_conservation': {
        'title': 'Astuces de conservation',
        'description': 'Conservation, substitutions et astuces anti-gaspillage.',
        'icon': 'kitchen', 'order': 6,
      },
    };

    // MODIFIÉ : La liste complète des articles, chacun avec un 'id' unique.
    final articles = [
      // --- VOS ARTICLES EXISTANTS (AVEC ID AJOUTÉ) ---
      {
        'id': 'comp001',
        'title': 'La position assise idéale pour manger',
        'categoryId': 'alimentation_comportement',
        'summary': 'Être bien assis à table assure à votre enfant confort et sécurité. Une bonne posture favorise le développement moteur et la digestion.',
        'content': 'Pour que votre enfant mange bien, il est essentiel qu’il soit bien installé...',
        'imageUrl': 'assets/images/articles/position_assise.png',
        'publishedAt': FieldValue.serverTimestamp(),
        'tips': [
          'Assurez-vous que les hanches, genoux et chevilles de votre enfant forment un angle de 90 degrés.',
          'Utilisez un repose-pieds pour stabiliser le corps de votre enfant.',
          'Un coussin ferme et stable peut être une alternative à la chaise haute.'
        ],
      },
      {
        'id': 'comp002',
        'title': 'Mon enfant ne mange pas beaucoup',
        'categoryId': 'alimentation_comportement',
        'summary': 'L’appétit des enfants varie. Laissez-le écouter sa faim et évitez les commentaires négatifs.',
        'content': 'Certains enfants mangent peu car ils ont un petit gabarit ou sont distraits par le jeu...',
        'imageUrl': 'assets/images/articles/enfant_mange_peu.png',
        'publishedAt': FieldValue.serverTimestamp(),
        'tips': [
          'Établissez un horaire de repas et collations régulier.',
          'Évitez les commentaires sur la quantité d’aliments que votre enfant mange.',
          'Créez une ambiance agréable et sans écran pendant les repas.'
        ],
      },
      {
        'id': 'equi001',
        'title': 'Camouflage alimentaire : bonne ou mauvaise idée ?',
        'categoryId': 'aliments_equilibres',
        'summary': 'Le camouflage alimentaire peut aider à court terme, mais a des inconvénients à long terme.',
        'content': 'Le camouflage alimentaire consiste à cacher des aliments (comme des légumes) dans des plats cuisinés...',
        'imageUrl': 'assets/images/articles/camouflage.png',
        'publishedAt': FieldValue.serverTimestamp(),
        'tips': [
          'Votre enfant doit pouvoir reconnaître les aliments qu’il mange pour développer son goût.',
          'Impliquez votre enfant dans la cuisine pour le familiariser avec les aliments.',
          'Le ketchup, riche en sucre et sel, doit rester occasionnel.'
        ],
      },
      {
        'id': 'astu001',
        'title': 'Guide pratique pour tirer son lait',
        'categoryId': 'astuces_conservation',
        'summary': 'Découvrez les méthodes et conseils pour tirer et conserver le lait maternel.',
        'content': 'Il existe plusieurs méthodes pour tirer son lait, de l’expression à la main au tire-lait électrique...',
        'imageUrl': 'assets/images/articles/tire_lait_guide.png',
        'publishedAt': FieldValue.serverTimestamp(),
        'tips': [
          'Vérifiez la taille des coupoles de votre tire-lait pour plus de confort et d\'efficacité.',
          'Continuez de tirer 1 à 2 minutes après que le lait ne coule plus.',
          'Le lait maternel décongelé peut avoir une odeur différente, mais il reste bon.'
        ],
      },
      {
        'id': 'croi001',
        'title': 'L\'alimentation pendant l\'allaitement',
        'categoryId': 'nutrition_croissance',
        'summary': 'Avoir plus faim et soif est normal pendant l’allaitement. Mangez à votre faim.',
        'content': 'Il est parfaitement normal d’avoir plus faim pendant l’allaitement. Votre corps a besoin de calories supplémentaires...',
        'imageUrl': 'assets/images/articles/alimentation_allaitement.png',
        'publishedAt': FieldValue.serverTimestamp(),
        'tips': [
          'Mangez à votre faim et ne limitez pas les quantités pendant l’allaitement.',
          'Prenez des collations saines comme des fruits ou des légumes.',
          'Limitez le café et le thé, car la caféine peut énerver votre bébé.'
        ],
      },
      {
        'id': 'comp003',
        'title': 'Comportements alimentaires : jeter sa nourriture',
        'categoryId': 'alimentation_comportement',
        'summary': 'Les enfants peuvent jeter leur nourriture par expérimentation ou pour attirer l’attention.',
        'content': 'Avant 12 mois, un bébé peut jeter sa nourriture par curiosité. Après 12 mois, cela peut être pour attirer l’attention...',
        'imageUrl': 'assets/images/articles/jeter_nourriture.png',
        'publishedAt': FieldValue.serverTimestamp(),
        'tips': [
          'Si votre enfant jette sa nourriture, restez calme.',
          'Rappelez les consignes avant le repas.',
          'Demandez-lui de vous aider à ramasser pour qu’il comprenne la conséquence de son geste.'
        ],
      },
      {
        'id': 'astu002',
        'title': 'Biberons : conseils pratiques',
        'categoryId': 'astuces_conservation',
        'summary': 'Bien choisir son biberon et respecter une hygiène rigoureuse sont essentiels.',
        'content': 'Un bébé en santé peut s’adapter à la plupart des biberons. Choisissez en fonction du format et de la facilité de nettoyage...',
        'imageUrl': 'assets/images/articles/conseils_biberon.png',
        'publishedAt': FieldValue.serverTimestamp(),
        'tips': [
          'Lavez les biberons à la main de préférence.',
          'Vérifiez l’état de la tétine avant chaque utilisation.',
          'Ne réchauffez jamais le lait au micro-ondes.'
        ],
      },
      {
        'id': 'alle001',
        'title': 'Allergie au lait',
        'categoryId': 'allergies_alimentaires',
        'summary': 'L’allergie au lait est une réaction immunitaire aux protéines de lait de vache, différente de l’intolérance au lactose.',
        'content': 'L’allergie au lait est une réaction anormale du système immunitaire qui touche environ 4 % des bébés...',
        'imageUrl': 'assets/images/articles/allergie_lait.png',
        'publishedAt': FieldValue.serverTimestamp(),
        'tips': [
          'L’allergie au lait n’est pas la même chose que l’intolérance au lactose.',
          'Continuez l’allaitement en suivant un régime d’éviction recommandé par un médecin.',
          'Mentionnez l’allergie de votre enfant au médecin ou au pharmacien.'
        ],
      },
      // --- NOUVEAUX ARTICLES SUR LA DIVERSIFICATION ---
      {
        'id': 'div001',
        'categoryId': 'diversification_alimentaire',
        'title': 'Les Grands Principes de la Diversification',
        'summary': 'Quand et comment commencer ? Découvrez les règles d\'or pour une introduction aux solides en douceur.',
        'content': 'La diversification alimentaire est une étape clé qui débute généralement entre 4 et 6 mois. La règle d\'or est d\'y aller progressivement, en introduisant un seul nouvel aliment à la fois tous les 2-3 jours pour détecter d\'éventuelles allergies.',
        'imageUrl': 'assets/images/articles/diversification_principes.png',
        'tips': [
          'Commencez à midi, avant la tétée ou le biberon.',
          'Ne forcez jamais votre bébé à manger.',
          'N\'ajoutez ni sel, ni sucre dans les préparations.'
        ],
        'publishedAt': FieldValue.serverTimestamp(),
      },
      {
        'id': 'div002',
        'categoryId': 'diversification_alimentaire',
        'title': 'Quels Aliments Introduire et à Quel Âge ?',
        'summary': 'Un guide pratique des aliments à proposer à bébé mois par mois pour éveiller ses papilles.',
        'content': 'Chaque âge a ses besoins. De 4 à 6 mois, commencez avec des purées de légumes et de fruits lisses. Entre 6 et 8 mois, introduisez les protéines (viande, poisson) mixées. Après 8 mois, passez aux textures écrasées et aux petits morceaux.',
        'imageUrl': 'assets/images/articles/diversification_aliments.png',
        'tips': [
          'Privilégiez les produits de saison et locaux.',
          'La patate douce est une excellente première source de glucides.',
          'Introduisez les œufs et les arachides (en purée lisse) avec prudence.'
        ],
        'publishedAt': FieldValue.serverTimestamp(),
      },
      {
        'id': 'div003',
        'categoryId': 'diversification_alimentaire',
        'title': 'Gérer les Allergies et les Refus',
        'summary': 'Apprenez à repérer les signes d\'allergies et à réagir face au refus de bébé.',
        'content': 'Le refus d\'un aliment est normal. Il faut parfois jusqu\'à 10 tentatives pour qu\'un aliment soit accepté. Concernant les allergies, soyez attentif aux signes : rougeurs, boutons, troubles digestifs. En cas de doute, consultez votre pédiatre.',
        'imageUrl': 'assets/images/articles/diversification_allergies.png',
        'tips': [
          'Tenez un journal alimentaire au début pour suivre les réactions.',
          'Introduisez les aliments potentiellement allergènes un par un, le matin ou à midi.',
          'Le refus d\'un aliment n\'est pas un caprice, c\'est un apprentissage.'
        ],
        'publishedAt': FieldValue.serverTimestamp(),
      }
    ];

    final batch = FirebaseFirestore.instance.batch();

    // Ajout/Mise à jour des catégories
    categories.forEach((id, data) {
      batch.set(categoriesCollection.doc(id), data);
    });

    // MODIFIÉ : La boucle utilise maintenant l'ID de chaque article pour éviter les doublons
    for (var articleData in articles) {
      final id = articleData['id'] as String;
      final docRef = articlesCollection.doc(id);
      batch.set(docRef, articleData);
    }
    
    await batch.commit();

    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text('✅ ${articles.length} articles ont été ajoutés/mis à jour !'),
        backgroundColor: Colors.green,
      ),
    );
  } catch (e) {
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text('❌ Erreur lors de l\'ajout des articles: $e'),
        backgroundColor: Colors.red,
      ),
    );
    print('Erreur détaillée: $e');
  }
}