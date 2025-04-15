class Category {
  final String id;
  final String name;
  final String icon; // Nom de l'icône à utiliser

  Category({
    required this.id,
    required this.name,
    required this.icon,
  });

  // Convertir en Map pour le stockage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
    };
  }

  // Créer à partir d'un Map
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
      icon: map['icon'],
    );
  }
}

// Liste des catégories prédéfinies pour les vendeurs en convention
final List<Category> predefinedCategories = [
  Category(id: 'art', name: 'Art & Illustrations', icon: 'brush'),
  Category(id: 'crafts', name: 'Artisanat', icon: 'handyman'),
  Category(id: 'accessories', name: 'Accessoires', icon: 'diamond'),
  Category(id: 'clothing', name: 'Vêtements', icon: 'checkroom'),
  Category(id: 'prints', name: 'Impressions', icon: 'photo'),
  Category(id: 'books', name: 'Livres & Zines', icon: 'menu_book'),
  Category(id: 'digital', name: 'Produits digitaux', icon: 'computer'),
  Category(id: 'merch', name: 'Goodies', icon: 'loyalty'),
  Category(id: 'supplies', name: 'Matériel', icon: 'palette'),
  Category(id: 'food_drinks', name: 'Nourriture & Boissons', icon: 'restaurant'),
  Category(id: 'booth', name: 'Stand & Équipement', icon: 'store'),
  Category(id: 'shipping', name: 'Expédition', icon: 'local_shipping'),
  Category(id: 'fees', name: 'Frais & Taxes', icon: 'receipt_long'),
  Category(id: 'other', name: 'Autre', icon: 'more_horiz'),
];

// Fonction pour obtenir une catégorie par son ID
Category getCategoryById(String id) {
  return predefinedCategories.firstWhere(
    (category) => category.id == id,
    orElse: () => predefinedCategories.last, // Retourne "Autre" si non trouvé
  );
}

// Fonction pour obtenir l'icône d'une catégorie
String getCategoryIcon(String categoryId) {
  return getCategoryById(categoryId).icon;
}
