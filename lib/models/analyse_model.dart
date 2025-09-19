// Ce fichier contient uniquement la définition des objets de données.

class Analyse {
  final String name;
  final String price;
  bool isSelected;

  Analyse({required this.name, required this.price, this.isSelected = false});
}

class AnalyseCategory {
  final String categoryName;
  final List<Analyse> analyses;

  AnalyseCategory({required this.categoryName, required this.analyses});
}