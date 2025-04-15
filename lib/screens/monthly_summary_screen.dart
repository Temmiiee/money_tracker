import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../models/transaction.dart';
import '../models/product.dart';
import '../services/storage_service.dart';
import '../widgets/transaction_card.dart';
import '../widgets/custom_button.dart';
import '../utils/number_formatter.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class MonthlySummaryScreen extends StatefulWidget {
  const MonthlySummaryScreen({super.key});

  @override
  State<MonthlySummaryScreen> createState() => _MonthlySummaryScreenState();
}

class _MonthlySummaryScreenState extends State<MonthlySummaryScreen> {
  final StorageService _storageService = StorageService();
  List<Transaction> _transactions = [];
  double _totalSales = 0;
  double _totalPurchases = 0;
  double _walletTransactionsBalance = 0; // Solde des transactions du portefeuille pour ce mois
  double _balance = 0; // Le solde global qui représente aussi le portefeuille
  bool _isLoading = true;
  DateTime _selectedMonth = DateTime.now();
  late DateFormat _monthFormatter;

  @override
  void initState() {
    super.initState();
    // Initialiser la localisation pour les dates en français
    initializeDateFormatting('fr_FR', null).then((_) {
      _monthFormatter = DateFormat('MMMM yyyy', 'fr_FR');
      _loadData();
    });
  }

  @override
  void dispose() {
    super.dispose();
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

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final allTransactions = await _storageService.getTransactions();

      // Filtrer les transactions pour le mois sélectionné
      final firstDayOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
      final lastDayOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);

      final monthlyTransactions = allTransactions.where((transaction) {
        return transaction.date.isAfter(firstDayOfMonth.subtract(const Duration(days: 1))) &&
               transaction.date.isBefore(lastDayOfMonth.add(const Duration(days: 1)));
      }).toList();

      // Trier les transactions par date (les plus récentes d'abord)
      monthlyTransactions.sort((a, b) => b.date.compareTo(a.date));

      // Calculer les totaux
      final sales = monthlyTransactions
          .where((t) => t.type == TransactionType.sale)
          .fold(0.0, (sum, t) => sum + t.amount);

      final purchases = monthlyTransactions
          .where((t) => t.type == TransactionType.purchase)
          .fold(0.0, (sum, t) => sum + t.amount);

      // Calculer le solde des transactions du portefeuille pour ce mois
      double walletTransactionsBalance = 0.0;
      for (var transaction in monthlyTransactions.where((t) => t.type == TransactionType.wallet)) {
        if (transaction.isDeposit ?? false) {
          walletTransactionsBalance += transaction.amount;
        } else {
          walletTransactionsBalance -= transaction.amount;
        }
      }

      // Récupérer le solde global (portefeuille)
      final balance = await _storageService.getWalletBalance();

      setState(() {
        _transactions = monthlyTransactions;
        _totalSales = sales;
        _totalPurchases = purchases;
        _walletTransactionsBalance = walletTransactionsBalance;
        _balance = balance; // Le solde global = portefeuille
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors du chargement des données')),
        );
      }
    }
  }

  Future<void> _selectMonth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDatePickerMode: DatePickerMode.year,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedMonth = DateTime(picked.year, picked.month, 1);
      });
      _loadData();
    }
  }

  Widget _buildSummaryCard(String title, double amount, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSizes.s),
            Text(
              NumberFormatter.formatEuro(NumberFormatter.roundToTwoDecimals(amount)),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppTexts.monthlyTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: _selectMonth,
            tooltip: 'Changer de mois',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                children: [
                  // En-tête avec le mois sélectionné
                  Container(
                    padding: const EdgeInsets.all(AppSizes.m),
                    color: AppColors.cardPrimary,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.calendar_today, color: AppColors.primary),
                        const SizedBox(width: AppSizes.s),
                        Text(
                          _monthFormatter.format(_selectedMonth),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Résumé du mois
                  Padding(
                    padding: const EdgeInsets.all(AppSizes.m),
                    child: Column(
                      children: [
                        _buildSummaryCard(
                          AppTexts.earnedThisMonth,
                          _totalSales,
                          AppColors.success,
                        ),

                        const SizedBox(height: AppSizes.m),

                        _buildSummaryCard(
                          AppTexts.spentThisMonth,
                          _totalPurchases,
                          AppColors.warning,
                        ),

                        const SizedBox(height: AppSizes.m),

                        // Le portefeuille est maintenant équivalent au solde global
                        // Nous n'affichons donc plus cette carte pour éviter la confusion

                        const SizedBox(height: AppSizes.m),

                        // Carte pour le solde global (plus visible)
                        Card(
                          elevation: 1,
                          color: _balance >= 0 ? AppColors.cardSuccess : AppColors.cardDanger,
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
                                      _balance >= 0 ? Icons.thumb_up : Icons.thumb_down,
                                      color: _balance >= 0 ? AppColors.success : AppColors.danger,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSizes.m),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.m, vertical: AppSizes.s),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(AppSizes.s),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withAlpha(10),
                                        blurRadius: 2,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    NumberFormatter.formatEuro(_balance),
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: _balance >= 0 ? AppColors.success : AppColors.danger,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: AppSizes.s),
                                const Divider(),
                                const SizedBox(height: AppSizes.s),
                                // Détail du calcul
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
                                              '+${NumberFormatter.formatEuro(_totalSales)}',
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
                                              '-${NumberFormatter.formatEuro(_totalPurchases)}',
                                              style: const TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold),
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
                                          const Text('Transactions du portefeuille:', style: TextStyle(fontWeight: FontWeight.w500)),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: AppSizes.m, vertical: AppSizes.xs),
                                            decoration: BoxDecoration(
                                              color: (_walletTransactionsBalance >= 0 ? AppColors.success : AppColors.danger).withAlpha(30),
                                              borderRadius: BorderRadius.circular(AppSizes.xs),
                                            ),
                                            child: Text(
                                              '${_walletTransactionsBalance >= 0 ? '+' : ''}${NumberFormatter.formatEuro(NumberFormatter.roundToTwoDecimals(_walletTransactionsBalance))}',
                                              style: TextStyle(
                                                color: _walletTransactionsBalance >= 0 ? AppColors.success : AppColors.danger,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: AppSizes.m),

                        CustomButton(
                          text: AppTexts.export,
                          icon: Icons.picture_as_pdf,
                          onPressed: () {
                            // Fonctionnalité d'export PDF (à implémenter)
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Export PDF à venir dans une prochaine version')),
                            );
                          },
                          color: AppColors.secondary,
                        ),
                      ],
                    ),
                  ),

                  // Liste des transactions
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSizes.m),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Transactions du mois',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  _transactions.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(AppSizes.xl),
                          child: Center(
                            child: Text(
                              'Aucune transaction pour ce mois',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(AppSizes.m),
                          itemCount: _transactions.length,
                          itemBuilder: (context, index) {
                            return TransactionCard(
                              transaction: _transactions[index],
                              onDelete: (transaction) => _deleteTransaction(transaction),
                            );
                          },
                        ),
                ],
              ),
            ),
          ),
    );
  }
}
