import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction.dart';
import '../models/product.dart';

class StorageService {
  static const String _transactionsKey = 'transactions';
  static const String _productsKey = 'products';

  // Sauvegarder les transactions
  Future<void> saveTransactions(List<Transaction> transactions) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> jsonList = transactions
        .map((transaction) => jsonEncode(transaction.toMap()))
        .toList();
    await prefs.setStringList(_transactionsKey, jsonList);
  }

  // Récupérer les transactions
  Future<List<Transaction>> getTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? jsonList = prefs.getStringList(_transactionsKey);

    if (jsonList == null) {
      return [];
    }

    return jsonList
        .map((jsonString) => Transaction.fromMap(jsonDecode(jsonString)))
        .toList();
  }

  // Ajouter une transaction
  Future<void> addTransaction(Transaction transaction) async {
    final transactions = await getTransactions();
    transactions.add(transaction);
    await saveTransactions(transactions);
  }

  // Supprimer une transaction
  Future<void> deleteTransaction(String transactionId) async {
    final transactions = await getTransactions();
    final newTransactions = transactions.where((t) => t.id != transactionId).toList();
    await saveTransactions(newTransactions);
  }

  // Mettre à jour une transaction
  Future<void> updateTransaction(Transaction updatedTransaction) async {
    final transactions = await getTransactions();
    final index = transactions.indexWhere((t) => t.id == updatedTransaction.id);

    if (index != -1) {
      transactions[index] = updatedTransaction;
      await saveTransactions(transactions);
    }
  }

  // Récupérer une transaction par son ID
  Future<Transaction?> getTransactionById(String transactionId) async {
    final transactions = await getTransactions();
    try {
      return transactions.firstWhere((t) => t.id == transactionId);
    } catch (e) {
      return null;
    }
  }

  // Sauvegarder les produits
  Future<void> saveProducts(List<Product> products) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> jsonList = products
        .map((product) => jsonEncode(product.toMap()))
        .toList();
    await prefs.setStringList(_productsKey, jsonList);
  }

  // Récupérer les produits
  Future<List<Product>> getProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? jsonList = prefs.getStringList(_productsKey);

    if (jsonList == null) {
      return [];
    }

    return jsonList
        .map((jsonString) => Product.fromMap(jsonDecode(jsonString)))
        .toList();
  }

  // Ajouter un produit
  Future<void> addProduct(Product product) async {
    final products = await getProducts();
    products.add(product);
    await saveProducts(products);
  }

  // Mettre à jour un produit
  Future<void> updateProduct(Product updatedProduct) async {
    final products = await getProducts();
    final index = products.indexWhere((p) => p.id == updatedProduct.id);

    if (index != -1) {
      products[index] = updatedProduct;
      await saveProducts(products);
    }
  }

  // Supprimer un produit
  Future<void> deleteProduct(String productId) async {
    final products = await getProducts();
    final newProducts = products.where((p) => p.id != productId).toList();
    await saveProducts(newProducts);
  }

  // Obtenir les transactions du mois en cours
  Future<List<Transaction>> getCurrentMonthTransactions() async {
    final transactions = await getTransactions();
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

    return transactions.where((transaction) {
      return transaction.date.isAfter(firstDayOfMonth) &&
             transaction.date.isBefore(lastDayOfMonth.add(const Duration(days: 1)));
    }).toList();
  }

  // Calculer le total des ventes du mois (SANS inclure les dépôts dans le portefeuille)
  Future<double> getCurrentMonthSales() async {
    final transactions = await getCurrentMonthTransactions();
    return transactions
        .where((t) => t.type == TransactionType.sale)
        .fold<double>(0.0, (sum, t) => sum + t.amount);
  }

  // Calculer le total des achats du mois (SANS inclure les retraits du portefeuille)
  Future<double> getCurrentMonthPurchases() async {
    final transactions = await getCurrentMonthTransactions();
    return transactions
        .where((t) => t.type == TransactionType.purchase)
        .fold<double>(0.0, (sum, t) => sum + t.amount);
  }

  // Calculer le solde des transactions de portefeuille (dépôts/retraits directs)
  Future<double> getWalletTransactionsBalance() async {
    final transactions = await getTransactions();
    double balance = 0.0;

    for (var transaction in transactions.where((t) => t.type == TransactionType.wallet)) {
      if (transaction.isDeposit ?? false) {
        balance += transaction.amount;
      } else {
        balance -= transaction.amount;
      }
    }

    return balance;
  }

  // Calculer le solde global (ventes - achats + transactions de portefeuille)
  // Ce solde représente directement le portefeuille
  Future<double> getGlobalBalance() async {
    final sales = await getCurrentMonthSales();
    final purchases = await getCurrentMonthPurchases();
    final walletTransactions = await getWalletTransactionsBalance();

    return sales - purchases + walletTransactions;
  }

  // Le solde du portefeuille est maintenant équivalent au solde global
  Future<double> getWalletBalance() async {
    return getGlobalBalance();
  }

  // Obtenir les transactions du portefeuille
  Future<List<Transaction>> getWalletTransactions() async {
    final transactions = await getTransactions();
    return transactions
        .where((t) => t.type == TransactionType.wallet)
        .toList();
  }

  // Obtenir les produits avec un stock bas
  Future<List<Product>> getLowStockProducts() async {
    final products = await getProducts();
    return products.where((p) => p.isLowStock()).toList();
  }
}
