import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../services/storage_service.dart';
import '../widgets/transaction_card.dart';
import '../widgets/expense_pie_chart.dart';
import '../models/transaction.dart';
import '../models/product.dart';
import '../utils/number_formatter.dart';
import 'edit_transaction_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StorageService _storageService = StorageService();
  double _totalSales = 0;
  double _totalPurchases = 0;
  double _balance = 0; // Le solde global qui représente aussi le portefeuille
  double _walletTransactions = 0; // Transactions du portefeuille (dépôts/retraits)
  List<Transaction> _recentTransactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Récupérer toutes les données nécessaires
      final sales = await _storageService.getCurrentMonthSales();
      final purchases = await _storageService.getCurrentMonthPurchases();
      final globalBalance = await _storageService.getGlobalBalance(); // Le solde global = portefeuille
      final walletBalance = await _storageService.getWalletTransactionsBalance(); // Solde des transactions du portefeuille
      final transactions = await _storageService.getTransactions();

      // Trier les transactions par date (les plus récentes d'abord)
      transactions.sort((a, b) => b.date.compareTo(a.date));

      // Prendre les 5 transactions les plus récentes (en excluant les transactions du portefeuille)
      final recentTransactions = transactions
          .where((t) => t.type != TransactionType.wallet)
          .take(5)
          .toList();

      if (mounted) {
        setState(() {
          _totalSales = sales;
          _totalPurchases = purchases;
          _balance = globalBalance; // Le solde global = portefeuille
          _walletTransactions = walletBalance; // Solde des transactions du portefeuille
          _recentTransactions = recentTransactions;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        // Gérer l'erreur
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors du chargement des données')),
        );
      }
    }
  }

  // Modifier une transaction
  Future<void> _editTransaction(Transaction transaction) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditTransactionScreen(transactionId: transaction.id),
      ),
    );

    // Si la transaction a été modifiée, recharger les données
    if (result == true) {
      await _loadData();
    }
  }

  // Supprimer une transaction
  Future<void> _deleteTransaction(Transaction transaction) async {
    try {
      await _storageService.deleteTransaction(transaction.id);

      // Si c'est une transaction de vente ou d'achat liée à un produit, mettre à jour le stock
      if (transaction.type == TransactionType.sale || transaction.type == TransactionType.purchase) {
        // Récupérer tous les produits
        final products = await _storageService.getProducts();

        // Chercher un produit avec le même nom
        final productIndex = products.indexWhere((p) => p.name == transaction.name);

        if (productIndex != -1) {
          final product = products[productIndex];
          int newQuantity = product.quantity;

          // Ajuster la quantité en fonction du type de transaction
          if (transaction.type == TransactionType.sale) {
            // Si c'était une vente, on réajoute au stock
            newQuantity += transaction.quantity ?? 1;
          } else if (transaction.type == TransactionType.purchase) {
            // Si c'était un achat, on retire du stock
            newQuantity -= transaction.quantity ?? 1;
            // Éviter les quantités négatives
            newQuantity = newQuantity < 0 ? 0 : newQuantity;
          }

          // Mettre à jour le produit
          final updatedProduct = Product(
            id: product.id,
            name: product.name,
            quantity: newQuantity,
            price: product.price,
            createdAt: product.createdAt,
            updatedAt: DateTime.now(),
          );

          await _storageService.updateProduct(updatedProduct);
        }
      }

      // Recharger les données
      await _loadData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaction supprimée avec succès')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de la suppression de la transaction')),
        );
      }
    }
  }

  Widget _buildStatusIcon() {
    // Utiliser l'image happy.png avec un fond vert si le solde est positif ou égal à 0
    // Utiliser l'image sad.png avec un fond bleu si le solde est négatif
    final bool isHappy = _balance >= 0; // Modifié pour inclure 0 comme cas positif

    // Couleurs de fond pour les images
    final Color backgroundColor = isHappy
        ? const Color(0xFF6B9080)  // Vert pour happy
        : const Color(0xFF5B7FFF); // Bleu pour sad

    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(30),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: Stack(
          fit: StackFit.expand, // Assure que le Stack remplit tout l'espace disponible
          alignment: Alignment.center, // Centre tous les éléments du Stack
          children: [
            // Fond coloré qui remplit tout le conteneur
            Container(
              color: backgroundColor,
            ),
            // Image du chat avec fond transparent
            Padding(
              padding: const EdgeInsets.all(5.0), // Ajoute un peu d'espace autour de l'image
              child: Image.asset(
                isHappy ? 'assets/images/happy.png' : 'assets/images/sad.png',
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Méthode supprimée car non utilisée

  // Méthode pour construire une ligne de résumé compacte
  Widget _buildCompactSummaryRow(String title, double amount, Color color, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: AppSizes.s),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.s,
            vertical: AppSizes.xs,
          ),
          decoration: BoxDecoration(
            color: color.withAlpha(25),
            borderRadius: BorderRadius.circular(AppSizes.s),
          ),
          child: Text(
            NumberFormatter.formatEuro(NumberFormatter.roundToTwoDecimals(amount)),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Money Tracker'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            Navigator.pushNamed(context, '/settings');
          },
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSizes.m),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // En-tête avec statut
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Bonjour !',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildStatusIcon(),
                    ],
                  ),

                  const SizedBox(height: AppSizes.l),

                  // Cartes de résumé avec graphique circulaire
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(AppSizes.m),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Colonne de gauche avec les cartes de résumé
                          Expanded(
                            flex: 3,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildCompactSummaryRow(
                                  AppTexts.earnedThisMonth,
                                  _totalSales,
                                  AppColors.success,
                                  Icons.trending_up,
                                ),
                                const SizedBox(height: AppSizes.s),
                                const Divider(height: 1),
                                const SizedBox(height: AppSizes.s),
                                _buildCompactSummaryRow(
                                  AppTexts.spentThisMonth,
                                  _totalPurchases,
                                  AppColors.warning,
                                  Icons.trending_down,
                                ),
                              ],
                            ),
                          ),
                          // Colonne de droite avec le graphique circulaire
                          Expanded(
                            flex: 2,
                            child: ExpensePieChart(
                              totalSales: _totalSales,
                              totalPurchases: _totalPurchases,
                              walletTransactions: _walletTransactions,
                              transactions: _recentTransactions,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSizes.m),

                  // Carte pour le solde global (plus visible)
                  Card(
                    elevation: 1,
                    color: _balance >= 0 ? AppColors.cardSuccess : AppColors.cardWarning,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSizes.m),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                AppTexts.remainingMoney,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                                          Icon(
                                _balance >= 0 ? Icons.spa : Icons.water_drop,
                                color: _balance >= 0 ? AppColors.success : AppColors.warning,
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSizes.m),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: AppSizes.m, horizontal: AppSizes.l),
                            margin: const EdgeInsets.symmetric(horizontal: AppSizes.m),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(AppSizes.m),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(10),
                                  blurRadius: 2,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Text(
                              NumberFormatter.formatEuro(NumberFormatter.roundToTwoDecimals(_balance)),
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: _balance >= 0 ? AppColors.success : AppColors.warning,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: AppSizes.s),
                          const Divider(),
                          const SizedBox(height: AppSizes.s),
                          // Détails financiers avec meilleure présentation
                          Container(
                            padding: const EdgeInsets.all(AppSizes.m),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(AppSizes.s),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Ventes:', style: TextStyle(fontWeight: FontWeight.w500)),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: AppSizes.m, vertical: AppSizes.xs),
                                      decoration: BoxDecoration(
                                        color: AppColors.success.withAlpha(30),
                                        borderRadius: BorderRadius.circular(AppSizes.xs),
                                      ),
                                      child: Text(
                                        '+${NumberFormatter.formatEuro(NumberFormatter.roundToTwoDecimals(_totalSales))}',
                                        style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSizes.s),
                                const Divider(height: 1),
                                const SizedBox(height: AppSizes.s),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Achats:', style: TextStyle(fontWeight: FontWeight.w500)),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: AppSizes.m, vertical: AppSizes.xs),
                                      decoration: BoxDecoration(
                                        color: AppColors.danger.withAlpha(30),
                                        borderRadius: BorderRadius.circular(AppSizes.xs),
                                      ),
                                      child: Text(
                                        '-${NumberFormatter.formatEuro(NumberFormatter.roundToTwoDecimals(_totalPurchases))}',
                                        style: const TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSizes.s),
                                const Divider(height: 1),
                                const SizedBox(height: AppSizes.s),
                                // Afficher les transactions du portefeuille
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Portefeuille:', style: TextStyle(fontWeight: FontWeight.w500)),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: AppSizes.m, vertical: AppSizes.xs),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withAlpha(30),
                                        borderRadius: BorderRadius.circular(AppSizes.xs),
                                      ),
                                      child: Text(
                                        _walletTransactions >= 0
                                          ? '+${NumberFormatter.formatEuro(NumberFormatter.roundToTwoDecimals(_walletTransactions))}'
                                          : '-${NumberFormatter.formatEuro(NumberFormatter.roundToTwoDecimals(_walletTransactions.abs()))}',
                                        style: TextStyle(
                                          color: _walletTransactions >= 0 ? AppColors.success : AppColors.danger,
                                          fontWeight: FontWeight.bold
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSizes.l),

                  // Transactions récentes
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(AppSizes.m),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Transactions récentes',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: AppSizes.m),
                          _recentTransactions.isEmpty
                              ? const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(AppSizes.s),
                                    child: Text(
                                      'Aucune transaction récente',
                                      style: TextStyle(color: AppColors.textSecondary),
                                    ),
                                  ),
                                )
                              : Column(
                                  children: _recentTransactions
                                      .map((transaction) => TransactionCard(
                                            transaction: transaction,
                                            onTap: () {
                                              // Navigation vers le détail de la transaction
                                            },
                                            onEdit: (transaction) => _editTransaction(transaction),
                                            onDelete: (transaction) => _deleteTransaction(transaction),
                                          ))
                                      .toList(),
                                ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
      ),
    );
  }
}
