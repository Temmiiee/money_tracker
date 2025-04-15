import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/constants.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../services/storage_service.dart';
import '../widgets/custom_button.dart';
// import '../utils/number_formatter.dart'; // Non utilisé dans ce fichier

class EditTransactionScreen extends StatefulWidget {
  final String transactionId;

  const EditTransactionScreen({
    super.key,
    required this.transactionId,
  });

  @override
  State<EditTransactionScreen> createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _quantityController = TextEditingController();
  final StorageService _storageService = StorageService();

  bool _isLoading = true;
  Transaction? _transaction;
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _loadTransaction();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  // Convertir le nom de l'icône en IconData
  IconData _getCategoryIcon(String iconName) {
    switch (iconName) {
      case 'brush': return Icons.brush;
      case 'handyman': return Icons.handyman;
      case 'diamond': return Icons.diamond;
      case 'checkroom': return Icons.checkroom;
      case 'photo': return Icons.photo;
      case 'menu_book': return Icons.menu_book;
      case 'computer': return Icons.computer;
      case 'loyalty': return Icons.loyalty;
      case 'palette': return Icons.palette;
      case 'restaurant': return Icons.restaurant;
      case 'store': return Icons.store;
      case 'local_shipping': return Icons.local_shipping;
      case 'receipt_long': return Icons.receipt_long;
      default: return Icons.more_horiz;
    }
  }

  Future<void> _loadTransaction() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final transaction = await _storageService.getTransactionById(widget.transactionId);

      if (transaction == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Transaction introuvable')),
          );
          Navigator.pop(context);
        }
        return;
      }

      setState(() {
        _transaction = transaction;
        _nameController.text = transaction.name;
        _amountController.text = transaction.amount.toString();
        if (transaction.quantity != null) {
          _quantityController.text = transaction.quantity.toString();
        }
        _selectedCategoryId = transaction.categoryId;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors du chargement de la transaction')),
        );
        Navigator.pop(context);
      }
    }
  }

  Future<void> _saveTransaction() async {
    if (_formKey.currentState!.validate() && _transaction != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        final name = _nameController.text.trim();
        final amount = double.parse(_amountController.text);
        int? quantity;

        if (_quantityController.text.isNotEmpty) {
          quantity = int.parse(_quantityController.text);
        }

        // Créer la transaction mise à jour
        final updatedTransaction = Transaction(
          id: _transaction!.id,
          name: name,
          amount: amount,
          date: _transaction!.date,
          type: _transaction!.type,
          isForStock: _transaction!.isForStock,
          quantity: quantity,
          isDeposit: _transaction!.isDeposit,
          categoryId: _selectedCategoryId,
        );

        await _storageService.updateTransaction(updatedTransaction);

        setState(() {
          _isLoading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Transaction mise à jour avec succès')),
          );
          Navigator.pop(context, true); // Retourner true pour indiquer que la transaction a été mise à jour
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erreur lors de la mise à jour de la transaction')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier la transaction'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.m),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Type de transaction (non modifiable)
                    Container(
                      padding: const EdgeInsets.all(AppSizes.m),
                      decoration: BoxDecoration(
                        color: _getTransactionTypeColor().withAlpha(30),
                        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _getTransactionTypeIcon(),
                            color: _getTransactionTypeColor(),
                          ),
                          const SizedBox(width: AppSizes.m),
                          Text(
                            _getTransactionTypeLabel(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _getTransactionTypeColor(),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSizes.m),

                    // Champ pour le nom
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nom',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.edit),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer un nom';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: AppSizes.m),

                    // Champ pour le montant
                    TextFormField(
                      controller: _amountController,
                      decoration: const InputDecoration(
                        labelText: 'Montant',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.euro),
                        suffixText: '€',
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

                    const SizedBox(height: AppSizes.m),

                    // Champ pour la quantité (si applicable)
                    if (_transaction!.quantity != null)
                      Column(
                        children: [
                          TextFormField(
                            controller: _quantityController,
                            decoration: const InputDecoration(
                              labelText: 'Quantité',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.numbers),
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer une quantité';
                              }
                              final quantity = int.tryParse(value);
                              if (quantity == null || quantity <= 0) {
                                return 'La quantité doit être supérieure à 0';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppSizes.m),
                        ],
                      ),

                    // Sélection de catégorie
                    Card(
                      elevation: 0,
                      color: _getTransactionTypeColor().withAlpha(30),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSizes.m),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.category, size: 20, color: AppColors.primary),
                                const SizedBox(width: AppSizes.s),
                                const Text(
                                  'Catégorie de produit',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                const Spacer(),
                                if (_selectedCategoryId != null)
                                  TextButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        _selectedCategoryId = null;
                                      });
                                    },
                                    icon: const Icon(Icons.clear, size: 16),
                                    label: const Text('Effacer'),
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppSizes.s,
                                        vertical: AppSizes.xs,
                                      ),
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: AppSizes.s),
                            Container(
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
                              padding: const EdgeInsets.all(AppSizes.s),
                              child: Wrap(
                                alignment: WrapAlignment.center,
                                spacing: AppSizes.s,
                                runSpacing: AppSizes.s,
                                children: predefinedCategories.map((category) {
                                  final isSelected = _selectedCategoryId == category.id;
                                  return InkWell(
                                    onTap: () {
                                      setState(() {
                                        _selectedCategoryId = isSelected ? null : category.id;
                                      });
                                    },
                                    borderRadius: BorderRadius.circular(AppSizes.s),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppSizes.s,
                                        vertical: AppSizes.xs,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected ? _getTransactionTypeColor() : Colors.white,
                                        borderRadius: BorderRadius.circular(AppSizes.s),
                                        border: Border.all(
                                          color: isSelected ? _getTransactionTypeColor() : Colors.grey.shade300,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            _getCategoryIcon(category.icon),
                                            size: 18,
                                            color: isSelected ? Colors.white : _getTransactionTypeColor(),
                                          ),
                                          const SizedBox(width: AppSizes.xs),
                                          Text(
                                            category.name,
                                            style: TextStyle(
                                              color: isSelected ? Colors.white : AppColors.textPrimary,
                                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSizes.xl),

                    // Bouton d'enregistrement
                    CustomButton(
                      text: 'Enregistrer les modifications',
                      icon: Icons.save,
                      onPressed: _saveTransaction,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // Obtenir la couleur en fonction du type de transaction
  Color _getTransactionTypeColor() {
    if (_transaction == null) return AppColors.primary;

    switch (_transaction!.type) {
      case TransactionType.sale:
        return AppColors.success;
      case TransactionType.purchase:
        return AppColors.warning;
      case TransactionType.wallet:
        return AppColors.primary;
    }
  }

  // Obtenir l'icône en fonction du type de transaction
  IconData _getTransactionTypeIcon() {
    if (_transaction == null) return Icons.help_outline;

    switch (_transaction!.type) {
      case TransactionType.sale:
        return Icons.trending_up;
      case TransactionType.purchase:
        return Icons.trending_down;
      case TransactionType.wallet:
        return Icons.account_balance_wallet;
    }
  }

  // Obtenir le libellé en fonction du type de transaction
  String _getTransactionTypeLabel() {
    if (_transaction == null) return 'Transaction';

    switch (_transaction!.type) {
      case TransactionType.sale:
        return 'Vente';
      case TransactionType.purchase:
        return 'Achat';
      case TransactionType.wallet:
        return _transaction!.isDeposit ?? false ? 'Dépôt' : 'Retrait';
    }
  }
}
