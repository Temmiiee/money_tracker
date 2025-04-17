import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/constants.dart';
import '../models/transaction.dart';
import '../services/storage_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/transaction_card.dart';
import '../utils/number_formatter.dart';
import 'package:uuid/uuid.dart';
import '../localization/app_localizations.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final StorageService _storageService = StorageService();
  final _uuid = const Uuid();

  bool _isDeposit = true; // Par défaut, c'est un dépôt (ajout d'argent)
  bool _isLoading = false;
  List<Transaction> _walletTransactions = [];
  double _walletBalance = 0.0; // Le solde du portefeuille = solde global
  double _totalSales = 0.0;
  double _totalPurchases = 0.0;

  @override
  void initState() {
    super.initState();
    _loadWalletData();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _loadWalletData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Récupérer toutes les transactions
      final allTransactions = await _storageService.getTransactions();

      // Filtrer les transactions de type wallet
      final walletTransactions = allTransactions
          .where((t) => t.type == TransactionType.wallet)
          .toList();

      // Trier par date (plus récentes d'abord)
      walletTransactions.sort((a, b) => b.date.compareTo(a.date));

      // Récupérer les totaux des ventes et achats
      final sales = await _storageService.getCurrentMonthSales();
      final purchases = await _storageService.getCurrentMonthPurchases();

      // Récupérer le solde global qui est maintenant équivalent au portefeuille
      final walletBalance = await _storageService.getWalletBalance();

      if (mounted) {
        setState(() {
          _walletTransactions = walletTransactions;
          _walletBalance = walletBalance; // Le portefeuille = solde global
          _totalSales = sales;
          _totalPurchases = purchases;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors du chargement des données')),
        );
      }
    }
  }

  // Variable pour éviter les soumissions multiples
  bool _isSubmitting = false;

  Future<void> _saveWalletTransaction() async {
    // Vérifier si une soumission est déjà en cours
    if (_isSubmitting) return;

    if (_formKey.currentState!.validate()) {
      // Marquer comme en cours de soumission
      _isSubmitting = true;

      setState(() {
        _isLoading = true;
      });

      try {
        final description = _descriptionController.text.trim();
        final amount = double.parse(_amountController.text);

        // Créer la transaction
        final transaction = Transaction(
          id: _uuid.v4(),
          name: description,
          amount: amount,
          date: DateTime.now(),
          type: TransactionType.wallet,
          isDeposit: _isDeposit,
        );

        await _storageService.addTransaction(transaction);

        if (mounted) {
          // Réinitialiser le formulaire
          _descriptionController.clear();
          _amountController.clear();

          // Recharger les données
          await _loadWalletData();

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_isDeposit
                ? 'Argent ajouté avec succès'
                : 'Argent retiré avec succès'
              ),
              backgroundColor: _isDeposit ? AppColors.success : AppColors.warning,
            ),
          );
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erreur lors de l\'enregistrement'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } finally {
        // Réinitialiser le flag de soumission
        _isSubmitting = false;

        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate(AppTexts.walletTitle)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadWalletData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.m),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Solde du portefeuille et impact sur le solde global
                      Card(
                        elevation: 1,
                        color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkCardPrimary : AppColors.lightCardPrimary,
                        child: Padding(
                          padding: const EdgeInsets.all(AppSizes.m),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.account_balance_wallet, color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkPrimary : AppColors.lightPrimary),
                                  const SizedBox(width: AppSizes.s),
                                  Text(
                                    AppLocalizations.of(context).translate('wallet_balance'),
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkPrimary : AppColors.lightPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSizes.m),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: AppSizes.l, vertical: AppSizes.m),
                                margin: const EdgeInsets.symmetric(vertical: AppSizes.s, horizontal: AppSizes.m),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkSurface : Colors.white,
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
                                  NumberFormatter.formatEuro(_walletBalance),
                                  style: TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: _walletBalance >= 0
                                        ? (Theme.of(context).brightness == Brightness.dark ? AppColors.darkSuccess : AppColors.lightSuccess)
                                        : (Theme.of(context).brightness == Brightness.dark ? AppColors.darkDanger : AppColors.lightDanger),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: AppSizes.m),
                              const Divider(),
                              const SizedBox(height: AppSizes.s),
                              Text(
                                AppLocalizations.of(context).translate('calculation_details'),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: AppSizes.s),
                              // Détails financiers avec meilleure présentation
                              Container(
                                padding: const EdgeInsets.all(AppSizes.m),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkSurface : Colors.white,
                                  borderRadius: BorderRadius.circular(AppSizes.s),
                                  border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade700 : Colors.grey.shade200),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(AppLocalizations.of(context).translate('sales'), style: const TextStyle(fontWeight: FontWeight.w500)),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: AppSizes.m, vertical: AppSizes.xs),
                                          decoration: BoxDecoration(
                                            color: AppColors.success.withAlpha(30),
                                            borderRadius: BorderRadius.circular(AppSizes.xs),
                                          ),
                                          child: Text(
                                            '+${NumberFormatter.formatEuro(_totalSales)}',
                                            style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkSuccess : AppColors.lightSuccess, fontWeight: FontWeight.bold),
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
                                        Text(AppLocalizations.of(context).translate('purchases'), style: const TextStyle(fontWeight: FontWeight.w500)),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: AppSizes.m, vertical: AppSizes.xs),
                                          decoration: BoxDecoration(
                                            color: AppColors.danger.withAlpha(30),
                                            borderRadius: BorderRadius.circular(AppSizes.xs),
                                          ),
                                          child: Text(
                                            '-${NumberFormatter.formatEuro(_totalPurchases)}',
                                            style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkDanger : AppColors.lightDanger, fontWeight: FontWeight.bold),
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
                                        Text('${AppLocalizations.of(context).translate('wallet_transactions')}:', style: const TextStyle(fontWeight: FontWeight.w500)),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: AppSizes.m, vertical: AppSizes.xs),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary.withAlpha(30),
                                            borderRadius: BorderRadius.circular(AppSizes.xs),
                                          ),
                                          child: Text(
                                            NumberFormatter.formatEuro(NumberFormatter.roundToTwoDecimals(_walletTransactions.fold<double>(0.0, (sum, t) => sum + (t.isDeposit ?? false ? t.amount : -t.amount)))),
                                            style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkPrimary : AppColors.lightPrimary, fontWeight: FontWeight.bold),
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

                      const SizedBox(height: AppSizes.l),

                      // Formulaire pour ajouter/retirer de l'argent
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context).translate('add_remove_money'),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: AppSizes.m),

                            // Choix du type d'opération
                            Row(
                              children: [
                                Expanded(
                                  child: RadioListTile<bool>(
                                    title: Text(AppLocalizations.of(context).translate('add_money')),
                                    value: true,
                                    groupValue: _isDeposit,
                                    onChanged: (value) {
                                      setState(() {
                                        _isDeposit = value!;
                                      });
                                    },
                                    activeColor: AppColors.success,
                                  ),
                                ),
                                Expanded(
                                  child: RadioListTile<bool>(
                                    title: Text(AppLocalizations.of(context).translate('remove_money')),
                                    value: false,
                                    groupValue: _isDeposit,
                                    onChanged: (value) {
                                      setState(() {
                                        _isDeposit = value!;
                                      });
                                    },
                                    activeColor: AppColors.danger,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: AppSizes.m),

                            // Description
                            TextFormField(
                              controller: _descriptionController,
                              decoration: InputDecoration(
                                labelText: AppLocalizations.of(context).translate('description'),
                                hintText: AppLocalizations.of(context).translate('description_hint'),
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.description),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Veuillez entrer une description';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: AppSizes.m),

                            // Montant
                            TextFormField(
                              controller: _amountController,
                              decoration: InputDecoration(
                                labelText: AppLocalizations.of(context).translate('amount'),
                                border: const OutlineInputBorder(),
                                prefixIcon: const Icon(Icons.euro),
                                suffixText: '€',
                                hintText: _isDeposit
                                    ? AppLocalizations.of(context).translate('amount_to_add')
                                    : AppLocalizations.of(context).translate('amount_to_remove'),
                              ),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                              ],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Veuillez entrer un montant';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Veuillez entrer un montant valide';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: AppSizes.l),

                            // Bouton d'enregistrement
                            CustomButton(
                              text: _isDeposit ? AppLocalizations.of(context).translate('add_to_wallet') : AppLocalizations.of(context).translate('remove_from_wallet'),
                              icon: _isDeposit ? Icons.add : Icons.remove,
                              color: _isDeposit ? AppColors.success : AppColors.danger,
                              onPressed: _saveWalletTransaction,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSizes.l),

                      // Historique des transactions
                      Text(
                        AppLocalizations.of(context).translate('transaction_history'),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: AppSizes.m),

                      _walletTransactions.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(AppSizes.l),
                                child: Text(
                                  AppLocalizations.of(context).translate('no_transactions'),
                                  style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                                ),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _walletTransactions.length,
                              itemBuilder: (context, index) {
                                return TransactionCard(
                                  transaction: _walletTransactions[index],
                                  onDelete: (transaction) => _deleteTransaction(transaction),
                                );
                              },
                            ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  // Supprimer une transaction du portefeuille
  Future<void> _deleteTransaction(Transaction transaction) async {
    try {
      await _storageService.deleteTransaction(transaction.id);
      await _loadWalletData();

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
}
