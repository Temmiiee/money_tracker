enum TransactionType {
  sale,
  purchase,
  wallet,
}

class Transaction {
  final String id;
  final String name;
  final double amount;
  final DateTime date;
  final TransactionType type;
  final bool isForStock;
  final int? quantity;
  final bool? isDeposit; // Pour les transactions de type wallet (true = dépôt, false = retrait)
  final String? categoryId; // ID de la catégorie
  final String? notes; // Notes ou commentaires sur la transaction

  Transaction({
    required this.id,
    required this.name,
    required this.amount,
    required this.date,
    required this.type,
    this.isForStock = false,
    this.quantity,
    this.isDeposit,
    this.categoryId,
    this.notes,
  });

  // Convertir en Map pour le stockage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'date': date.millisecondsSinceEpoch,
      'type': type.toString(),
      'isForStock': isForStock,
      'quantity': quantity,
      'isDeposit': isDeposit,
      'categoryId': categoryId,
      'notes': notes,
    };
  }

  // Créer à partir d'un Map
  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      name: map['name'],
      amount: map['amount'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      type: _parseTransactionType(map['type']),
      isForStock: map['isForStock'] ?? false,
      quantity: map['quantity'],
      isDeposit: map['isDeposit'],
      categoryId: map['categoryId'],
      notes: map['notes'],
    );
  }

  // Méthode pour analyser le type de transaction à partir d'une chaîne
  static TransactionType _parseTransactionType(String? typeString) {
    if (typeString == 'TransactionType.sale') {
      return TransactionType.sale;
    } else if (typeString == 'TransactionType.wallet') {
      return TransactionType.wallet;
    } else {
      return TransactionType.purchase;
    }
  }
}
