import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/constants.dart';
import '../models/transaction.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../services/storage_service.dart';
import '../widgets/custom_button.dart';
import '../utils/number_formatter.dart';
import 'package:uuid/uuid.dart';
import '../localization/app_localizations.dart';

class PurchaseScreen extends StatefulWidget {
  const PurchaseScreen({super.key});

  @override
  State<PurchaseScreen> createState() => _PurchaseScreenState();
}

class _PurchaseScreenState extends State<PurchaseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _quantityController = TextEditingController();
  final StorageService _storageService = StorageService();
  final _uuid = const Uuid();

  bool _isForStock = false;
  bool _isLoading = false;
  bool _isPricePerUnit = true; // Par défaut, le prix est par unité
  List<Product> _products = [];
  Product? _selectedProduct;
  double _calculatedTotal = 0.0; // Pour stocker le montant total calculé
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _loadProducts();

    // Ajouter des écouteurs pour mettre à jour le montant total
    _amountController.addListener(_updateTotalAmount);
    _quantityController.addListener(_updateTotalAmount);
  }

  @override
  void dispose() {
    // Supprimer les écouteurs
    _amountController.removeListener(_updateTotalAmount);
    _quantityController.removeListener(_updateTotalAmount);

    _nameController.dispose();
    _amountController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void _updateTotalAmount() {
    if (_isForStock) {
      final price = double.tryParse(_amountController.text) ?? 0.0;
      final quantity = int.tryParse(_quantityController.text) ?? 0;

      setState(() {
        if (_isPricePerUnit) {
          // Si le prix est par unité, on multiplie par la quantité
          _calculatedTotal = NumberFormatter.roundToTwoDecimals(price * quantity);
        } else {
          // Si le prix est déjà le total, on l'utilise directement
          _calculatedTotal = NumberFormatter.roundToTwoDecimals(price);
        }
      });
    }
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

  Future<void> _loadProducts() async {
    try {
      final products = await _storageService.getProducts();
      if (mounted) {
        setState(() {
          _products = products;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors du chargement des produits')),
        );
      }
    }
  }

  Future<void> _savePurchase() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Utiliser le nom du produit sélectionné si le champ nom est vide
        String name = _nameController.text.trim();
        if (name.isEmpty && _selectedProduct != null) {
          name = _selectedProduct!.name;
        }

        final price = double.parse(_amountController.text);
        final quantity = _isForStock ? int.parse(_quantityController.text) : 1;

        // Déterminer le montant total et le prix unitaire en fonction du mode de prix
        double amount;
        double unitPrice;

        if (_isForStock) {
          if (_isPricePerUnit) {
            // Si le prix est par unité
            unitPrice = NumberFormatter.roundToTwoDecimals(price);
            amount = NumberFormatter.roundToTwoDecimals(price * quantity);
          } else {
            // Si le prix est déjà le total
            amount = NumberFormatter.roundToTwoDecimals(price);
            unitPrice = NumberFormatter.roundToTwoDecimals(quantity > 0 ? price / quantity : price);
          }
        } else {
          // Si ce n'est pas pour le stock, le montant est simplement le prix saisi
          amount = NumberFormatter.roundToTwoDecimals(price);
          unitPrice = NumberFormatter.roundToTwoDecimals(price);
        }

        // Créer la transaction
        final transaction = Transaction(
          id: _uuid.v4(),
          name: name,
          amount: amount,
          date: DateTime.now(),
          type: TransactionType.purchase,
          isForStock: _isForStock,
          quantity: _isForStock ? quantity : null,
          categoryId: _selectedCategoryId,
        );

        await _storageService.addTransaction(transaction);

        // Mettre à jour ou créer un produit si c'est pour le stock
        if (_isForStock) {
          if (_selectedProduct != null) {
            // Mettre à jour un produit existant
            final updatedProduct = _selectedProduct!;
            updatedProduct.updateQuantity(updatedProduct.quantity + quantity);
            await _storageService.updateProduct(updatedProduct);
          } else {
            // Créer un nouveau produit
            final newProduct = Product(
              id: _uuid.v4(),
              name: name,
              quantity: quantity,
              price: unitPrice, // Prix unitaire déjà calculé
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );
            await _storageService.addProduct(newProduct);
          }
        }

        setState(() {
          _isLoading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Achat enregistré avec succès')),
          );

          // Réinitialiser le formulaire
          _nameController.clear();
          _amountController.clear();
          _quantityController.clear();
          setState(() {
            _isForStock = false;
            _selectedProduct = null;
          });
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erreur lors de l\'enregistrement de l\'achat')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate(AppTexts.purchaseTitle)),
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
                    // Grande carte contenant tous les champs
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSizes.m),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // En-tête de la section
                            Row(
                              children: [
                                const Icon(Icons.shopping_cart_outlined, color: AppColors.primary),
                                const SizedBox(width: AppSizes.s),
                                Text(
                                  AppLocalizations.of(context).translate('purchase_details'),
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                                ),
                                const Spacer(),
                                // Option pour le stock
                                Row(
                                  children: [
                                    Text(
                                      AppLocalizations.of(context).translate('for_stock'),
                                      style: TextStyle(
                                        color: _isForStock ? AppColors.primary : AppColors.textSecondary,
                                        fontWeight: _isForStock ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                    Checkbox(
                                      value: _isForStock,
                                      onChanged: (value) {
                                        setState(() {
                                          _isForStock = value ?? false;
                                          // Mettre à jour le montant total si nécessaire
                                          if (_isForStock) {
                                            _updateTotalAmount();
                                          }
                                        });
                                      },
                                      activeColor: AppColors.primary,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const Divider(),
                            const SizedBox(height: AppSizes.s),

                            // Champ pour le nom de l'achat si ce n'est pas pour le stock
                            if (!_isForStock) ...[
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context).translate(AppTexts.whatItem),
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.shopping_cart_outlined),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppLocalizations.of(context).translate('please_enter_name');
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: AppSizes.m),
                            ],

                            // Section conditionnelle pour le stock
                            if (_isForStock) ...[
                              // Sélection d'un produit existant
                              DropdownButtonFormField<Product>(
                                decoration: InputDecoration(
                                  labelText: AppLocalizations.of(context).translate('select_product'),
                                  border: const OutlineInputBorder(),
                                  prefixIcon: const Icon(Icons.inventory_2_outlined),
                                ),
                                value: _selectedProduct,
                                hint: Text(AppLocalizations.of(context).translate('select_product_to_restock')),
                                items: _products.map((product) {
                                  return DropdownMenuItem<Product>(
                                    value: product,
                                    child: Text(product.name),
                                  );
                                }).toList(),
                                onChanged: (Product? value) {
                                  setState(() {
                                    _selectedProduct = value;
                                    if (value != null) {
                                      _nameController.text = value.name;
                                      _amountController.text = value.price.toString();

                                      // Récupérer la catégorie du produit s'il en a une
                                      if (value.categoryId != null) {
                                        setState(() {
                                          _selectedCategoryId = value.categoryId;
                                        });
                                      }
                                    }
                                  });
                                },
                              ),

                              const SizedBox(height: AppSizes.m),

                              // Champ pour saisir manuellement si pas dans la liste
                              TextFormField(
                                controller: _nameController,
                                decoration: InputDecoration(
                                  labelText: AppLocalizations.of(context).translate('or_enter_name_manually'),
                                  border: const OutlineInputBorder(),
                                  prefixIcon: const Icon(Icons.edit),
                                ),
                                validator: (value) {
                                  // Accepter un nom vide si un produit est sélectionné
                                  if ((value == null || value.isEmpty) && _selectedProduct == null) {
                                    return AppLocalizations.of(context).translate('enter_name_or_select_product');
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: AppSizes.m),



                              // Champ pour la quantité
                              TextFormField(
                                controller: _quantityController,
                                decoration: InputDecoration(
                                  labelText: AppLocalizations.of(context).translate('quantity'),
                                  border: const OutlineInputBorder(),
                                  prefixIcon: const Icon(Icons.numbers),
                                ),
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                validator: (value) {
                                  if (_isForStock) {
                                    if (value == null || value.isEmpty) {
                                      return AppLocalizations.of(context).translate('enter_quantity');
                                    }
                                    final quantity = int.tryParse(value);
                                    if (quantity == null || quantity <= 0) {
                                      return AppLocalizations.of(context).translate('quantity_must_be_positive');
                                    }
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: AppSizes.m),
                            ],

                            // Champ pour le montant
                            TextFormField(
                              controller: _amountController,
                              decoration: InputDecoration(
                                labelText: _isForStock
                                  ? (_isPricePerUnit ? AppLocalizations.of(context).translate('unit_purchase_price') : AppLocalizations.of(context).translate('total_price'))
                                  : AppLocalizations.of(context).translate('price'),
                                border: const OutlineInputBorder(),
                                prefixIcon: const Icon(Icons.euro),
                                suffixText: '€',
                                helperText: _isForStock
                                  ? (_isPricePerUnit ? AppLocalizations.of(context).translate('price_per_unit') : AppLocalizations.of(context).translate('price_for_group'))
                                  : null,
                                // Simple bouton de basculement pour le mode de prix
                                suffixIcon: _isForStock ? InkWell(
                                  onTap: () {
                                    setState(() {
                                      _isPricePerUnit = !_isPricePerUnit;
                                      _updateTotalAmount();
                                    });
                                    // Afficher un feedback visuel temporaire
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('${AppLocalizations.of(context).translate('price_mode_changed')}: ${_isPricePerUnit ? AppLocalizations.of(context).translate('unit_price') : AppLocalizations.of(context).translate('total_price')}'),
                                        duration: const Duration(seconds: 1),
                                        behavior: SnackBarBehavior.floating,
                                        margin: const EdgeInsets.all(8),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          _isPricePerUnit ? AppLocalizations.of(context).translate('unit_price') : AppLocalizations.of(context).translate('total_price'),
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context).brightness == Brightness.dark
                                              ? AppColors.darkPrimary
                                              : AppColors.lightPrimary,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Icon(
                                          _isPricePerUnit ? Icons.euro_symbol : Icons.money,
                                          color: Theme.of(context).brightness == Brightness.dark
                                            ? AppColors.darkPrimary
                                            : AppColors.lightPrimary,
                                          size: 16,
                                        ),
                                      ],
                                    ),
                                  ),
                                ) : null,
                              ),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                              ],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return AppLocalizations.of(context).translate('enter_amount');
                                }
                                if (double.tryParse(value) == null) {
                                  return AppLocalizations.of(context).translate('enter_valid_amount');
                                }
                                return null;
                              },
                            ),

                            // Affichage du montant total pour le stock
                            if (_isForStock && _calculatedTotal > 0) ...[
                              const SizedBox(height: AppSizes.m),

                              // Affichage du montant total calculé
                              Container(
                                padding: const EdgeInsets.all(AppSizes.m),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkSurface : Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                                  border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade700 : Colors.grey.shade200),
                                ),
                                child: Column(
                                  children: [
                                    if (_isPricePerUnit) ...[
                                // Explication du calcul si prix unitaire
                                Row(
                                  children: [
                                    Icon(Icons.info_outline, color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkPrimary : AppColors.lightPrimary, size: 16),
                                    const SizedBox(width: AppSizes.xs),
                                    Expanded(
                                      child: Text(
                                        '${AppLocalizations.of(context).translate('calculation')}: ${NumberFormatter.formatCurrency(double.tryParse(_amountController.text) ?? 0.0)} € × ${int.tryParse(_quantityController.text) ?? '0'} ${AppLocalizations.of(context).translate('units')}',
                                        style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary, fontSize: 12),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSizes.s),
                              ],
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${AppLocalizations.of(context).translate('total_amount')}:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: AppSizes.m, vertical: AppSizes.xs),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkSurface : Colors.white,
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
                                      NumberFormatter.formatEuro(_calculatedTotal),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkPrimary : AppColors.lightPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (!_isPricePerUnit) ...[
                                const SizedBox(height: AppSizes.s),
                                // Explication du calcul si prix total
                                Row(
                                  children: [
                                    Icon(Icons.info_outline, color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkPrimary : AppColors.lightPrimary, size: 16),
                                    const SizedBox(width: AppSizes.xs),
                                    Expanded(
                                      child: Text(
                                        '${AppLocalizations.of(context).translate('calculated_unit_price')}: ${(int.tryParse(_quantityController.text) ?? 0) > 0 ? NumberFormatter.formatCurrency(NumberFormatter.roundToTwoDecimals((double.tryParse(_amountController.text) ?? 0.0) / (int.tryParse(_quantityController.text) ?? 1))) : '0,00'} € ${AppLocalizations.of(context).translate('per_unit')}',
                                        style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary, fontSize: 12),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSizes.m),

                    // Sélection de catégorie
                    Card(
                      elevation: 0,
                      color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkCardPrimary.withAlpha(128) : AppColors.lightCardPrimary.withAlpha(128),
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
                                Text(
                                  AppLocalizations.of(context).translate('product_category'),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                                    label: Text(AppLocalizations.of(context).translate('clear')),
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
                                color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkSurface : Colors.white,
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
                                        color: isSelected
                                          ? (Theme.of(context).brightness == Brightness.dark ? AppColors.darkPrimary : AppColors.lightPrimary)
                                          : (Theme.of(context).brightness == Brightness.dark ? AppColors.darkSurface : Colors.white),
                                        borderRadius: BorderRadius.circular(AppSizes.s),
                                        border: Border.all(
                                          color: isSelected ? AppColors.primary : Colors.grey.shade300,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            _getCategoryIcon(category.icon),
                                            size: 18,
                                            color: isSelected
                                              ? Colors.white
                                              : (Theme.of(context).brightness == Brightness.dark ? AppColors.darkPrimary : AppColors.lightPrimary),
                                          ),
                                          const SizedBox(width: AppSizes.xs),
                                          Text(
                                            category.name,
                                            style: TextStyle(
                                              color: isSelected
                                                ? Colors.white
                                                : (Theme.of(context).brightness == Brightness.dark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
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
                      text: AppLocalizations.of(context).translate(AppTexts.save),
                      icon: Icons.save,
                      onPressed: _savePurchase,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
