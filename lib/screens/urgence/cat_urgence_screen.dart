// lib/screens/urgence/cat_urgence_screen.dart
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'urgence_data.dart';
import 'urgence_models.dart';
import 'urgence_instructions_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:adomed_app/theme/app_theme.dart';

class CatUrgencesScreen extends StatelessWidget {
  final UrgenceCategory category;
  const CatUrgencesScreen({super.key, required this.category});

  // Les données des cas d'urgence sont conservées ici
  final Map<String, Map<String, String>> _caseData = const {
    'ACR chez un adulte / enfant / nourrisson': {
      'imageUrl': 'https://images.unsplash.com/photo-1579752945203-9118c7edc316?q=80&w=2940&auto=format&fit=crop',
      'description': 'L\'arrêt cardio-respiratoire nécessite une réanimation immédiate. Alternez 30 compressions thoraciques avec 2 insufflations pour augmenter les chances de survie.',
      'instructions': '1. Appelez les secours (15, 112). 2. Vérifiez la réactivité et la respiration. 3. Si la victime est inconsciente et ne respire pas, commencez la RCP (réanimation cardio-pulmonaire). 4. Pour un adulte : 30 compressions pour 2 insufflations, au rythme de 100 à 120 compressions par minute. 5. Pour un enfant : 30 compressions (une main) pour 2 insufflations. 6. Pour un nourrisson : 30 compressions (deux doigts) pour 2 insufflations. 7. Continuez jusqu\'à l\'arrivée des secours ou la reprise de la victime.'
    },
    'ACR après électrocution': {
      'imageUrl': 'https://images.unsplash.com/photo-1581092490076-2679e9a4f6e3?q=80&w=2940&auto=format&fit=crop',
      'description': 'Après avoir coupé le courant et sécurisé la zone, traitez l\'ACR comme un cas classique, mais soyez vigilant aux brûlures associées.',
      'instructions': '1. Coupez la source d\'électricité AVANT de toucher la victime. 2. Appelez les secours (15, 112). 3. Vérifiez la réactivité et la respiration. 4. Si la victime est inconsciente et ne respire pas, commencez la RCP comme pour un ACR classique. 5. Vérifiez la présence de brûlures et traitez-les après la RCP si l\'état de la victime est stabilisé. 6. Continuez la RCP jusqu\'à l\'arrivée des secours.'
    },
    'Détresse respiratoire grave': {
      'imageUrl': 'https://images.unsplash.com/photo-1534005885741-9c60e0a5879a?q=80&w=2940&auto=format&fit=crop',
      'description': 'Difficultés sévères à respirer, respiration rapide, superficielle ou irrégulière. Mettez la personne en position assise confortable et alertez les secours.',
      'instructions': '1. Appelez les secours (15, 112). 2. Mettez la victime en position assise ou semi-assise, le dos appuyé. 3. Desserrez ses vêtements autour du cou et de la poitrine. 4. Si la victime a des médicaments pour l\'asthme ou une allergie (ex: un inhalateur, un auto-injecteur d\'adrénaline), aidez-la à les utiliser. 5. Restez calme et rassurez la victime. 6. Surveillez continuellement sa respiration et son niveau de conscience en attendant les secours.'
    },
    'Hémorragie importante': {
      'imageUrl': 'https://images.unsplash.com/photo-1594824476967-b50a3b2b528b?q=80&w=2940&auto=format&fit=crop',
      'description': 'Un saignement abondant nécessite une compression directe de la plaie. Utilisez un tissu propre et maintenez une pression ferme pour arrêter l\'hémorragie.',
      'instructions': '1. Appelez les secours (15, 112). 2. Allongez la victime. 3. Exposez la plaie et appliquez une compression directe et forte avec un tissu propre ou la main. 4. Maintenez la pression. Si le tissu est imbibé de sang, n\'enlevez pas le premier, mais ajoutez-en un par-dessus. 5. Surélevez le membre blessé au-dessus du niveau du cœur si possible. 6. Surveillez l\'état de la victime en attendant les secours.'
    },
    'Fractures ouvertes': {
      'imageUrl': 'https://images.unsplash.com/photo-1615392262961-42a9a7a93a11?q=80&w=2940&auto=format&fit=crop',
      'description': 'Une fracture ouverte est une urgence. Protégez la plaie sans tenter de remettre l\'os en place. Immobilisez le membre et alertez les secours.',
      'instructions': '1. Appelez les secours (15, 112). 2. N\'essayez jamais de remettre l\'os en place. 3. Couvrez la plaie avec un pansement stérile ou un linge propre. 4. Immobilisez le membre blessé à l\'aide d\'une écharpe ou d\'attelles improvisées. 5. Maintenez la victime au chaud. 6. Surveillez les signes vitaux et attendez les secours.'
    },
    'Traumatisme crânien': {
      'imageUrl': 'https://images.unsplash.com/photo-1544030638-344408990b50?q=80&w=2940&auto=format&fit=crop',
      'description': 'Surveillez la victime pour des signes de confusion, vomissements, ou perte de connaissance. Appelez les urgences même si les symptômes semblent légers au début.',
      'instructions': '1. Appelez les secours (15, 112) immédiatement en cas de perte de connaissance, vomissements, confusion, saignement des oreilles ou du nez. 2. Allongez la victime, la tête et les épaules légèrement relevées si elle est consciente. 3. Si elle est inconsciente mais respire, placez-la en Position Latérale de Sécurité (PLS). 4. Ne donnez rien à manger ni à boire. 5. Surveillez attentivement l\'évolution de son état en attendant les secours.'
    },
    'Entorses et Luxations': {
      'imageUrl': 'https://images.unsplash.com/photo-1620863260759-42b7e53f01c4?q=80&w=2940&auto=format&fit=crop',
      'description': 'Immobilisez la zone touchée, appliquez du froid et surélevez si possible. N\'essayez pas de remettre en place une luxation. Consultez un professionnel de santé.',
      'instructions': '1. Immobilisez la zone blessée. Ne tentez pas de remettre un membre luxé. 2. Appliquez du froid (glace enveloppée dans un tissu) pendant 15-20 minutes toutes les 2-3 heures. 3. Surélevez le membre blessé pour réduire le gonflement. 4. Consultez un médecin pour un diagnostic et un traitement appropriés. 5. En cas de douleur intense, de déformation importante ou d\'impossibilité de bouger le membre, appelez les urgences.'
    },
    'Brûlures graves': {
      'imageUrl': 'https://images.unsplash.com/photo-1616766488349-f07f5a34241e?q=80&w=2940&auto=format&fit=crop',
      'description': 'Refroidissez immédiatement la zone avec de l\'eau froide (non glacée) pendant 10 à 20 minutes. Retirez les vêtements non collés. Couvrez d\'un linge propre et sec et alertez les secours.',
      'instructions': '1. Appelez les secours (15, 112). 2. Refroidissez la brûlure immédiatement sous l\'eau froide (environ 15-25°C, jamais glacée) pendant au moins 10 à 20 minutes. 3. Retirez délicatement les vêtements et bijoux proches de la brûlure, sauf s\'ils collent à la peau. 4. Couvrez la brûlure avec un linge propre et sec. 5. Ne percez jamais les cloques et n\'appliquez pas de pommade. 6. Surveillez la victime et attendez les secours.'
    },
    'Brûlures chimiques': {
      'imageUrl': 'https://images.unsplash.com/photo-1579752945203-9118c7edc316?q=80&w=2940&auto=format&fit=crop',
      'description': 'En cas de contact avec un produit chimique, rincez abondamment la zone à l\'eau pendant au moins 20 minutes. Retirez les vêtements contaminés. Appelez les urgences en décrivant le produit.',
      'instructions': '1. Appelez les secours (15, 112) en décrivant le produit chimique si possible. 2. Rincez immédiatement et abondamment la zone touchée avec de l\'eau courante pendant au moins 20 à 30 minutes. 3. Retirez tous les vêtements et bijoux contaminés pendant le rinçage. 4. Protégez-vous (gants) si possible pour ne pas être contaminé. 5. Couvrez la brûlure avec un linge propre après le rinçage. 6. Ne tentez pas de neutraliser le produit chimique.'
    },
    'Intoxications alimentaires': {
      'imageUrl': 'https://images.unsplash.com/photo-1587353916298-b99b3b027d1a?q=80&w=2940&auto=format&fit=crop',
      'description': 'En cas de symptômes (vomissements, diarrhée), hydratez la personne et surveillez son état. Si les symptômes sont graves, appelez les urgences.',
      'instructions': '1. Si la victime est consciente et ne présente pas de signes de gravité, proposez-lui de l\'eau ou des solutions de réhydratation par petites gorgées. 2. Évitez les aliments solides. 3. Si la victime est inconsciente, a des difficultés respiratoires, des douleurs abdominales intenses ou si les symptômes persistent, appelez les urgences (15, 112) ou un centre antipoison.'
    },
    'Empoisonnement médicamenteux ou produit chimique': {
      'imageUrl': 'https://images.unsplash.com/photo-1577789490184-2a6230f82f6e?q=80&w=2940&auto=format&fit=crop',
      'description': 'En cas de surdosage ou d\'ingestion accidentelle, ne faites pas vomir. Tentez d\'identifier le produit, puis appelez immédiatement un centre antipoison ou les urgences.',
      'instructions': '1. Appelez immédiatement un centre antipoison (numéro spécifique à votre pays) ou les urgences (15, 112). 2. Tentez d\'identifier le produit ingéré et la quantité. Gardez l\'emballage près de vous pour le donner aux secours. 3. NE FAITES PAS VOMIR la victime. 4. Si la victime est inconsciente mais respire, placez-la en Position Latérale de Sécurité (PLS). 5. Restez auprès de la victime et surveillez son état jusqu\'à l\'arrivée des secours.'
    },
    'Noyade': {
      'imageUrl': 'https://images.unsplash.com/photo-1534005885741-9c60e0a5879a?q=80&w=2940&auto=format&fit=crop',
      'description': 'Sortez la victime de l\'eau en toute sécurité. Vérifiez sa respiration. Si elle ne respire pas, commencez la RCP.',
      'instructions': '1. Sécurisez la victime : sortez-la de l\'eau uniquement si vous êtes en sécurité. Sinon, tendez un objet flottant. 2. Appelez les secours (15, 112). 3. Vérifiez la respiration. Si elle ne respire pas, commencez la RCP en effectuant 5 insufflations initiales avant de débuter les cycles de 30 compressions pour 2 insufflations. 4. Réchauffez la victime en la couvrant. 5. Surveillez son état de conscience et sa respiration.'
    },
    'Étouffement / Obstruction des voies aériennes': {
      'imageUrl': 'https://images.unsplash.com/photo-1627960714243-7f28ed9836ae?q=80&w=2940&auto=format&fit=crop',
      'description': 'Si la personne s\'étouffe, encouragez-la à tousser. Si la toux est inefficace, réalisez la manoeuvre de Heimlich et appelez les secours.',
      'instructions': '1. Pour un adulte conscient : encouragez la victime à tousser fortement. Si la toux est inefficace, donnez 5 claques dans le dos entre les omoplates. Si ça ne marche pas, réalisez 5 compressions abdominales (manœuvre de Heimlich). 2. Alternez 5 claques et 5 compressions jusqu\'à ce que l\'objet soit expulsé. 3. Si la victime devient inconsciente, appelez les secours (15, 112) et commencez la RCP. 4. Pour un nourrisson : 5 claques dans le dos et 5 compressions thoraciques.'
    },
    'Accident Vasculaire Cérébral (AVC)': {
      'imageUrl': 'https://images.unsplash.com/photo-1576091160550-21735c249419?q=80&w=2940&auto=format&fit=crop',
      'description': 'Reconnaissez les signes de l\'AVC (paralysie faciale, faiblesse d\'un bras, troubles de la parole). Appelez immédiatement les urgences.',
      'instructions': '1. Appelez les secours (15, 112) immédiatement. Mentionnez la suspicion d\'AVC. 2. Utilisez le test "FAST" pour identifier les signes : F (Face) : la bouche ou un œil est-il déformé ? A (Arm) : un bras est-il engourdi ou faible ? S (Speech) : le langage est-il incompréhensible ? T (Time) : Agissez vite, notez l\'heure d\'apparition des symptômes. 3. Allongez la personne, la tête et les épaules légèrement relevées si elle est consciente. 4. Ne donnez rien à manger ni à boire. 5. Restez à ses côtés en attendant les secours.'
    },
    'Crise d\'épilepsie': {
      'imageUrl': 'https://images.unsplash.com/photo-1627960714243-7f28ed9836ae?q=80&w=2940&auto=format&fit=crop',
      'description': 'Protégez la personne des objets dangereux. Ne la retenez pas. Surveillez le temps et appelez les urgences si la crise dure plus de 5 minutes.',
      'instructions': '1. Protégez la personne : déplacez les objets dangereux autour d\'elle. 2. Ne tentez pas de retenir ses mouvements. 3. NE METTEZ RIEN DANS SA BOUCHE. 4. Mettez un coussin ou un vêtement sous sa tête. 5. Mettez la personne en Position Latérale de Sécurité (PLS) une fois que les convulsions sont terminées. 6. Appelez les secours si la crise dure plus de 5 minutes, se répète, ou si la personne est blessée.'
    },
    'Malaise': {
      'imageUrl': 'https://images.unsplash.com/photo-1544030638-344408990b50?q=80&w=2940&auto=format&fit=crop',
      'description': 'Si une personne se sent mal, allongez-la et surélevez ses jambes. Desserrez ses vêtements. Si le malaise persiste ou s\'aggrave, alertez les secours.',
      'instructions': '1. Allongez la personne. Si elle est pâle, surélevez ses jambes. Si elle est rouge, mettez-la en position semi-assise. 2. Desserrez ses vêtements (col, ceinture). 3. Rassurez la personne. 4. Si le malaise persiste, s\'aggrave, ou si la personne ne se sent pas bien après quelques minutes, appelez les secours (15, 112).'
    },
    'Choc (état de choc)': {
      'imageUrl': 'https://images.unsplash.com/photo-1517739569850-967a57a1e0b5?q=80&w=2940&auto=format&fit=crop',
      'description': 'L\'état de choc peut suivre une blessure grave ou une hémorragie. Allongez la victime, couvrez-la et surélevez ses jambes. Appelez immédiatement les urgences.',
      'instructions': '1. Appelez immédiatement les secours (15, 112). 2. Allongez la victime sur le dos, les jambes légèrement surélevées. 3. Couvrez la victime pour la garder au chaud. 4. Desserrer les vêtements serrés. 5. Ne donnez rien à boire ni à manger. 6. Surveillez continuellement la conscience et la respiration de la victime.'
    },
    'Réaction allergique sévère': {
      'imageUrl': 'https://images.unsplash.com/photo-1606828859720-3b9b4b9b9c0d?q=80&w=2940&auto=format&fit=crop',
      'description': 'Si la réaction allergique provoque des difficultés respiratoires, un gonflement rapide du visage/gorge, ou une sensation de malaise intense, c\'est une urgence. Appelez les secours.',
      'instructions': '1. Appelez immédiatement les secours (15, 112). 2. Si la personne a un auto-injecteur d\'adrénaline (Epipen), aidez-la à l\'utiliser. 3. Allongez la personne si elle est pâle ou a des vertiges. Si elle a des difficultés respiratoires, mettez-la en position semi-assise. 4. Surveillez sa respiration et son état de conscience.'
    },
    'Crise d\'asthme': {
      'imageUrl': 'https://images.unsplash.com/photo-1594824476967-b50a3b2b528b?q=80&w=2940&auto=format&fit=crop',
      'description': 'Aidez la personne à prendre ses médicaments habituels (ventoline). Calmez-la et mettez-la en position assise. Si la crise ne passe pas, appelez les urgences.',
      'instructions': '1. Aidez la personne à s\'asseoir confortablement. 2. Aidez-la à prendre son médicament de secours (bronchodilatateur, ex: Ventoline). 3. Calmez et rassurez la personne. 4. Si la crise ne s\'améliore pas après 5-10 minutes, si la respiration devient très difficile, ou si la personne devient confuse, appelez les urgences (15, 112).'
    },
  };

  @override
  Widget build(BuildContext context) {
    final List<String> casesForCategory = urgenceData[category.name] ?? [];
    // Vous pouvez modifier ou allonger cette liste pour plus de variété
    final List<Color> iconColors = [
      Colors.red, 
      Colors.blue, 
      Colors.green, 
      Colors.orange, 
      Colors.purple, 
      Colors.teal, 
      Colors.pink
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // COUCHE 1 : Le fond en dégradé
          Container(
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
          ),

          // COUCHE 2 : Le bloc de contenu "vitré"
          Padding(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 20),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(32),
                topRight: Radius.circular(32),
              ),
              child: Container(
                color: AppTheme.backgroundColor.withOpacity(0.95),
                child: Column(
                  children: [
                    // En-tête personnalisé
                    Padding(
                      padding: const EdgeInsets.fromLTRB(4, 20, 16, 10),
                      child: Row(
                        children: [
                          IconButton(
                            // Couleur modifiée pour être cohérente avec le titre
                            icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimaryColor),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          Expanded(
                            child: Text(
                              category.name,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
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

                    // Contenu principal
                    Expanded(
                      child: casesForCategory.isEmpty
                          ? Center(child: Text("Aucun cas spécifique défini pour '${category.name}'.", style: Theme.of(context).textTheme.bodyMedium))
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: casesForCategory.length,
                              itemBuilder: (context, index) {
                                final caseTitle = casesForCategory[index];
                                final caseInfo = _caseData[caseTitle];

                                if (caseInfo == null || caseInfo['imageUrl'] == null || caseInfo['description'] == null) {
                                  return Card(
                                    elevation: 4,
                                    margin: const EdgeInsets.only(bottom: 20),
                                    child: ListTile(
                                      leading: Icon(Icons.error, color: AppColors.error),
                                      title: Text(caseTitle),
                                      subtitle: const Text("Informations non disponibles pour ce cas."),
                                    ),
                                  );
                                }
                                
                                // MODIFIÉ : Attribue une couleur de la liste de manière cyclique
                                final Color iconColor = iconColors[index % iconColors.length];

                                return _UrgenceCaseCard(
                                  title: caseTitle,
                                  description: caseInfo['description']!,
                                  imageUrl: caseInfo['imageUrl']!,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => UrgenceInstructionsScreen(
                                          caseTitle: caseTitle,
                                          instructions: caseInfo['instructions']!,
                                        ),
                                      ),
                                    );
                                  },
                                  iconColor: iconColor,
                                );
                              },
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

class _UrgenceCaseCard extends StatelessWidget {
  final String title;
  final String description;
  final String imageUrl;
  final VoidCallback onTap;
  final Color iconColor;

  const _UrgenceCaseCard({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.onTap,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      margin: const EdgeInsets.only(bottom: 20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 120,
              width: double.infinity,
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[200],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[200],
                  child: const Center(child: Icon(Icons.broken_image, color: Colors.red)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[700],
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Icon(Iconsax.arrow_right_3, size: 20, color: iconColor), // Couleur modifiée ici
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