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

class SellScreen extends StatefulWidget {
  const SellScreen({super.key});

  @override
  State<SellScreen> createState() => _SellScreenState();
}

class _SellScreenState extends State<SellScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _quantityController = TextEditingController();
  final StorageService _storageService = StorageService();
  final _uuid = const Uuid();

  bool _isMultipleSale = false;
  bool _isLoading = false;
  bool _isPricePerUnit = true; // Par défaut, le prix est par unité
  List<Product> _products = [];
  Product? _selectedProduct;
  String? _selectedCategoryId;

  // Pour forcer la mise à jour de l'interface lorsque les valeurs changent
  double _calculatedTotal = 0.0;

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
    if (_isMultipleSale) {
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

  Future<void> _saveSale() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final name = _nameController.text.trim();
        final price = double.parse(_amountController.text);
        final quantity = _isMultipleSale ? int.parse(_quantityController.text) : 1;

        // Déterminer le montant total et le prix unitaire en fonction du mode de prix
        double totalAmount;
        double unitPrice; // Utilisé pour calculer le prix unitaire

        if (_isMultipleSale) {
          if (_isPricePerUnit) {
            // Si le prix est par unité
            unitPrice = NumberFormatter.roundToTwoDecimals(price);
            totalAmount = NumberFormatter.roundToTwoDecimals(price * quantity);
          } else {
            // Si le prix est déjà le total
            totalAmount = NumberFormatter.roundToTwoDecimals(price);
            unitPrice = NumberFormatter.roundToTwoDecimals(quantity > 0 ? price / quantity : price);
          }
        } else {
          // Si ce n'est pas une vente multiple, le montant est simplement le prix saisi
          totalAmount = NumberFormatter.roundToTwoDecimals(price);
          unitPrice = NumberFormatter.roundToTwoDecimals(price);
        }

        // Créer la transaction
        final transaction = Transaction(
          id: _uuid.v4(),
          name: name,
          amount: totalAmount, // Montant total de la vente
          date: DateTime.now(),
          type: TransactionType.sale,
          quantity: quantity,
          categoryId: _selectedCategoryId,
        );

        await _storageService.addTransaction(transaction);

        // Mettre à jour le stock si un produit est sélectionné
        if (_selectedProduct != null) {
          final updatedProduct = _selectedProduct!;
          updatedProduct.updateQuantity(updatedProduct.quantity - quantity);
          await _storageService.updateProduct(updatedProduct);
        }

        setState(() {
          _isLoading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Vente enregistrée avec succès')),
          );

          // Réinitialiser le formulaire
          _nameController.clear();
          _amountController.clear();
          _quantityController.clear();
          setState(() {
            _isMultipleSale = false;
            _selectedProduct = null;
          });
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erreur lors de l\'enregistrement de la vente')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppTexts.sellTitle),
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
                                const Icon(Icons.shopping_bag_outlined, color: AppColors.success),
                                const SizedBox(width: AppSizes.s),
                                const Text(
                                  'Détails de la vente',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.success),
                                ),
                                const Spacer(),
                                // Option pour vendre plusieurs
                                Row(
                                  children: [
                                    Text(
                                      'Vente multiple',
                                      style: TextStyle(
                                        color: _isMultipleSale ? AppColors.success : AppColors.textSecondary,
                                        fontWeight: _isMultipleSale ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                    Checkbox(
                                      value: _isMultipleSale,
                                      onChanged: (value) {
                                        setState(() {
                                          _isMultipleSale = value ?? false;
                                          if (_isMultipleSale) {
                                            // Initialiser la quantité à 1 si elle est vide
                                            if (_quantityController.text.isEmpty) {
                                              _quantityController.text = '1';
                                            }
                                            // Mettre à jour le montant total
                                            _updateTotalAmount();
                                          }
                                        });
                                      },
                                      activeColor: AppColors.success,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const Divider(),
                            const SizedBox(height: AppSizes.s),

                            // Champ pour le nom du produit
                            DropdownButtonFormField<Product>(
                              decoration: const InputDecoration(
                                labelText: AppTexts.whatItem,
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.shopping_bag_outlined),
                              ),
                              value: _selectedProduct,
                              hint: const Text('Sélectionnez un produit'),
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
                              decoration: const InputDecoration(
                                labelText: 'Ou saisissez le nom manuellement',
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

                            // Section conditionnelle pour les ventes multiples
                            if (_isMultipleSale) ...[
                              // Option pour choisir le mode de prix (unitaire ou total)
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(AppSizes.s),
                                ),
                                margin: const EdgeInsets.only(bottom: AppSizes.m),
                                padding: const EdgeInsets.all(AppSizes.s),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.only(left: AppSizes.s, top: AppSizes.s),
                                      child: Text(
                                        'Mode de prix:',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: RadioListTile<bool>(
                                            title: const Text('Prix unitaire'),
                                            subtitle: const Text('Prix par article'),
                                            value: true,
                                            groupValue: _isPricePerUnit,
                                            onChanged: (value) {
                                              setState(() {
                                                _isPricePerUnit = value!;
                                                _updateTotalAmount();
                                              });
                                            },
                                            dense: true,
                                            activeColor: AppColors.success,
                                          ),
                                        ),
                                        Expanded(
                                          child: RadioListTile<bool>(
                                            title: const Text('Prix total'),
                                            subtitle: const Text('Prix du groupe'),
                                            value: false,
                                            groupValue: _isPricePerUnit,
                                            onChanged: (value) {
                                              setState(() {
                                                _isPricePerUnit = value!;
                                                _updateTotalAmount();
                                              });
                                            },
                                            dense: true,
                                            activeColor: AppColors.success,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Champ pour la quantité
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
                                  if (_isMultipleSale) {
                                    if (value == null || value.isEmpty) {
                                      return 'Veuillez entrer une quantité';
                                    }
                                    final quantity = int.tryParse(value);
                                    if (quantity == null || quantity <= 0) {
                                      return 'La quantité doit être supérieure à 0';
                                    }
                                    if (_selectedProduct != null && quantity > _selectedProduct!.quantity) {
                                      return 'Quantité insuffisante en stock';
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
                                labelText: _isMultipleSale
                                  ? (_isPricePerUnit ? 'Prix de vente/u' : 'Prix total')
                                  : AppTexts.price,
                                hintText: _isMultipleSale
                                  ? (_isPricePerUnit ? 'Prix par unité' : 'Prix pour tout le groupe')
                                  : 'Prix par unité',
                                border: const OutlineInputBorder(),
                                prefixIcon: const Icon(Icons.euro),
                                suffixText: '€',
                                helperText: _isMultipleSale
                                  ? (_isPricePerUnit ? 'Prix par unité' : 'Prix pour tout le groupe')
                                  : null,
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

                            // Affichage du montant total pour les ventes multiples
                            if (_isMultipleSale) ...[
                              const SizedBox(height: AppSizes.m),

                              // Affichage du montant total
                              Container(
                                padding: const EdgeInsets.all(AppSizes.m),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                                  border: Border.all(color: Colors.grey.shade200),
                                ),
                                child: Column(
                                  children: [
                                    const Row(
                                      children: [
                                        Icon(Icons.info_outline, color: AppColors.primary, size: 16),
                                        SizedBox(width: AppSizes.xs),
                                        Text(
                                          'Montant total calculé automatiquement',
                                          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                    if (_isPricePerUnit) ...[
                              const SizedBox(height: AppSizes.s),
                              // Explication du calcul si prix unitaire
                              Row(
                                children: [
                                  const Icon(Icons.info_outline, color: AppColors.success, size: 16),
                                  const SizedBox(width: AppSizes.xs),
                                  Expanded(
                                    child: Text(
                                      'Calcul: ${NumberFormatter.formatCurrency(double.tryParse(_amountController.text) ?? 0.0)} € × ${int.tryParse(_quantityController.text) ?? '0'} unités',
                                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            const SizedBox(height: AppSizes.s),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Montant total :',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.m, vertical: AppSizes.xs),
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
                                    NumberFormatter.formatEuro(_calculatedTotal),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: AppColors.success,
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
                                  const Icon(Icons.info_outline, color: AppColors.success, size: 16),
                                  const SizedBox(width: AppSizes.xs),
                                  Expanded(
                                    child: Text(
                                      'Prix unitaire calculé: ${(int.tryParse(_quantityController.text) ?? 0) > 0 ? NumberFormatter.formatCurrency(NumberFormatter.roundToTwoDecimals((double.tryParse(_amountController.text) ?? 0.0) / (int.tryParse(_quantityController.text) ?? 1))) : '0,00'} € par unité',
                                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
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
                      color: AppColors.cardSuccess.withAlpha(128),
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
                                const Icon(Icons.category, size: 20, color: AppColors.success),
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
                                        color: isSelected ? AppColors.success : Colors.white,
                                        borderRadius: BorderRadius.circular(AppSizes.s),
                                        border: Border.all(
                                          color: isSelected ? AppColors.success : Colors.grey.shade300,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            _getCategoryIcon(category.icon),
                                            size: 18,
                                            color: isSelected ? Colors.white : AppColors.success,
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
                      text: AppTexts.save,
                      icon: Icons.save,
                      onPressed: _saveSale,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
