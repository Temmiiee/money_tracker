import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../models/product.dart';
import '../services/storage_service.dart';
import '../widgets/product_card.dart';
import '../widgets/custom_button.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import '../localization/app_localizations.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final StorageService _storageService = StorageService();
  final _uuid = const Uuid();
  List<Product> _products = [];
  List<Product> _lowStockProducts = [];
  bool _isLoading = true;
  bool _showLowStockOnly = false;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final products = await _storageService.getProducts();
      final lowStock = await _storageService.getLowStockProducts();

      setState(() {
        _products = products;
        _lowStockProducts = lowStock;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).translate('error_loading_products'))),
        );
      }
    }
  }

  void _showAddProductDialog() {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final quantityController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).translate('add_product')),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).translate('product_name'),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context).translate('please_enter_name');
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppSizes.m),

                TextFormField(
                  controller: priceController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).translate('selling_price_per_unit'),
                    border: const OutlineInputBorder(),
                    suffixText: '€',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context).translate('please_enter_price');
                    }
                    if (double.tryParse(value) == null) {
                      return AppLocalizations.of(context).translate('please_enter_valid_price');
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppSizes.m),

                TextFormField(
                  controller: quantityController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).translate('stock_quantity'),
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context).translate('enter_quantity');
                    }
                    final quantity = int.tryParse(value);
                    if (quantity == null || quantity < 0) {
                      return AppLocalizations.of(context).translate('quantity_must_be_positive');
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppTexts.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final name = nameController.text.trim();
                final price = double.parse(priceController.text);
                final quantity = int.parse(quantityController.text);

                final newProduct = Product(
                  id: _uuid.v4(),
                  name: name,
                  quantity: quantity,
                  price: price,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                );

                await _storageService.addProduct(newProduct);
                if (!mounted) return;
                Navigator.pop(context);
                _loadProducts();
              }
            },
            child: const Text(AppTexts.add),
          ),
        ],
      ),
    );
  }

  void _showEditProductDialog(Product product) {
    final nameController = TextEditingController(text: product.name);
    final priceController = TextEditingController(text: product.price.toString());
    final quantityController = TextEditingController(text: product.quantity.toString());
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).translate('edit_product')),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).translate('product_name'),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context).translate('please_enter_name');
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppSizes.m),

                TextFormField(
                  controller: priceController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).translate('selling_price_per_unit'),
                    border: const OutlineInputBorder(),
                    suffixText: '€',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context).translate('please_enter_price');
                    }
                    if (double.tryParse(value) == null) {
                      return AppLocalizations.of(context).translate('please_enter_valid_price');
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppSizes.m),

                TextFormField(
                  controller: quantityController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).translate('stock_quantity'),
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context).translate('enter_quantity');
                    }
                    final quantity = int.tryParse(value);
                    if (quantity == null || quantity < 0) {
                      return AppLocalizations.of(context).translate('quantity_must_be_positive');
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppTexts.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final name = nameController.text.trim();
                final price = double.parse(priceController.text);
                final quantity = int.parse(quantityController.text);

                final updatedProduct = Product(
                  id: product.id,
                  name: name,
                  quantity: quantity,
                  price: price,
                  createdAt: product.createdAt,
                  updatedAt: DateTime.now(),
                );

                await _storageService.updateProduct(updatedProduct);
                if (!mounted) return;
                Navigator.pop(context);
                _loadProducts();
              }
            },
            child: const Text(AppTexts.save),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayedProducts = _showLowStockOnly ? _lowStockProducts : _products;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate(AppTexts.inventoryTitle)),
        actions: [
          IconButton(
            icon: Icon(
              _showLowStockOnly ? Icons.filter_list_off : Icons.filter_list,
              color: _showLowStockOnly ? AppColors.warning : null,
            ),
            onPressed: () {
              setState(() {
                _showLowStockOnly = !_showLowStockOnly;
              });
            },
            tooltip: AppLocalizations.of(context).translate('show_low_stock_only'),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadProducts,
              child: Column(
                children: [
                  // En-tête avec statistiques
                  Container(
                    padding: const EdgeInsets.all(AppSizes.m),
                    color: (Theme.of(context).brightness == Brightness.dark ? AppColors.darkPrimary : AppColors.lightPrimary).withAlpha(25),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatCard(
                          AppLocalizations.of(context).translate('total_products'),
                          _products.length.toString(),
                          Icons.inventory_2_outlined,
                        ),
                        _buildStatCard(
                          AppLocalizations.of(context).translate('to_restock'),
                          _lowStockProducts.length.toString(),
                          Icons.warning_amber_rounded,
                          _lowStockProducts.isNotEmpty ? AppColors.warning : null,
                        ),
                      ],
                    ),
                  ),

                  // Liste des produits
                  Expanded(
                    child: displayedProducts.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.inventory_2_outlined,
                                  size: 64,
                                  color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkTextHint : AppColors.lightTextHint,
                                ),
                                const SizedBox(height: AppSizes.m),
                                Text(
                                  _showLowStockOnly
                                      ? AppLocalizations.of(context).translate('no_products_to_restock')
                                      : AppLocalizations.of(context).translate('no_products'),
                                  style: TextStyle(
                                    color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: AppSizes.l),
                                if (!_showLowStockOnly)
                                  CustomButton(
                                    text: AppLocalizations.of(context).translate('add_product'),
                                    icon: Icons.add,
                                    onPressed: _showAddProductDialog,
                                    isFullWidth: false,
                                  ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(AppSizes.m),
                            itemCount: displayedProducts.length,
                            itemBuilder: (context, index) {
                              final product = displayedProducts[index];
                              return ProductCard(
                                product: product,
                                onTap: () => _showEditProductDialog(product),
                                onDelete: (product) => _deleteProduct(product),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddProductDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  // Supprimer un produit
  Future<void> _deleteProduct(Product product) async {
    try {
      await _storageService.deleteProduct(product.id);
      await _loadProducts();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).translate('product_deleted'))),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).translate('error_deleting_product'))),
        );
      }
    }
  }

  Widget _buildStatCard(String title, String value, IconData icon, [Color? color]) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.s),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.m),
        child: Column(
          children: [
            Icon(
              icon,
              color: color ?? AppColors.primary,
              size: 28,
            ),
            const SizedBox(height: AppSizes.xs),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color ?? AppColors.textPrimary,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
