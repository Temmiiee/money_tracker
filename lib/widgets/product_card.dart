import 'package:flutter/material.dart';
import '../models/product.dart';
import '../utils/constants.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final Function(Product)? onDelete;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onDelete,
  });

  // Afficher une boîte de dialogue de confirmation avant la suppression
  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text('Voulez-vous vraiment supprimer ce produit ? Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            onPressed: () {
              Navigator.pop(context);
              if (onDelete != null) {
                onDelete!(product);
              }
            },
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isLowStock = product.isLowStock();
    final Color stockColor = isLowStock
      ? (Theme.of(context).brightness == Brightness.dark ? AppColors.darkDanger : AppColors.lightDanger)
      : (Theme.of(context).brightness == Brightness.dark ? AppColors.darkSuccess : AppColors.lightSuccess);
    final Color cardColor = isLowStock
      ? (Theme.of(context).brightness == Brightness.dark ? AppColors.darkCardDanger : AppColors.lightCardDanger)
      : (Theme.of(context).brightness == Brightness.dark ? AppColors.darkCardSuccess : AppColors.lightCardSuccess);

    return Card(
      elevation: 0.5,
      margin: const EdgeInsets.symmetric(vertical: AppSizes.s),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        side: BorderSide(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade700 : Colors.grey.shade200),
      ),
      color: cardColor,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.m),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSizes.s),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkSurface : Colors.white,
                  border: Border.all(color: (Theme.of(context).brightness == Brightness.dark ? AppColors.darkPrimary : AppColors.lightPrimary).withAlpha(100), width: 1),
                  borderRadius: BorderRadius.circular(AppSizes.s),
                ),
                child: Icon(
                  Icons.inventory_2_outlined,
                  color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkPrimary : AppColors.lightPrimary,
                  size: AppSizes.iconSize,
                ),
              ),
              const SizedBox(width: AppSizes.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSizes.xs),
                    Text(
                      'Prix: ${product.price.toStringAsFixed(2)} €',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.m,
                      vertical: AppSizes.xs,
                    ),
                    decoration: BoxDecoration(
                      color: stockColor.withAlpha(30),
                      borderRadius: BorderRadius.circular(AppSizes.s),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isLowStock ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                          color: stockColor,
                          size: 18,
                        ),
                        const SizedBox(width: AppSizes.xs),
                        Text(
                          '${product.quantity}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: stockColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Bouton de suppression
                  if (onDelete != null)
                    IconButton(
                      icon: Icon(Icons.delete_outline, color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkDanger : AppColors.lightDanger),
                      onPressed: () => _showDeleteConfirmation(context),
                      tooltip: 'Supprimer',
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.only(left: AppSizes.s),
                      iconSize: 20,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
