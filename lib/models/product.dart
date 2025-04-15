class Product {
  final String id;
  final String name;
  int quantity;
  final double price;
  final DateTime createdAt;
  DateTime updatedAt;
  String? categoryId; // ID de la catégorie du produit

  Product({
    required this.id,
    required this.name,
    required this.quantity,
    required this.price,
    required this.createdAt,
    required this.updatedAt,
    this.categoryId,
  });

  // Méthode pour mettre à jour la quantité
  void updateQuantity(int newQuantity) {
    quantity = newQuantity;
    updatedAt = DateTime.now();
  }

  // Méthode pour vérifier si le stock est bas
  bool isLowStock() {
    return quantity <= 5; // Considéré comme bas si 5 ou moins
  }

  // Convertir en Map pour le stockage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'price': price,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'categoryId': categoryId,
    };
  }

  // Créer à partir d'un Map
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      quantity: map['quantity'],
      price: map['price'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
      categoryId: map['categoryId'],
    );
  }
}
