import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../utils/constants.dart';
import '../utils/number_formatter.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../localization/app_localizations.dart';

class TransactionCard extends StatefulWidget {
  final Transaction transaction;
  final VoidCallback? onTap;
  final Function(Transaction)? onDelete;
  final Function(Transaction)? onEdit;

  const TransactionCard({
    super.key,
    required this.transaction,
    this.onTap,
    this.onDelete,
    this.onEdit,
  });

  @override
  State<TransactionCard> createState() => _TransactionCardState();
}

class _TransactionCardState extends State<TransactionCard> {
  late DateFormat _dateFormatter;

  @override
  void initState() {
    super.initState();
    // Initialiser la localisation pour les dates en français
    initializeDateFormatting('fr_FR', null).then((_) {
      _dateFormatter = DateFormat('dd/MM/yyyy', 'fr_FR');
      setState(() {}); // Forcer la mise à jour de l'interface
    });
    _dateFormatter = DateFormat('dd/MM/yyyy'); // Valeur par défaut en attendant l'initialisation
  }

  // Afficher une boîte de dialogue de confirmation avant la suppression
  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text('Voulez-vous vraiment supprimer cette transaction ? Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            onPressed: () {
              Navigator.pop(context);
              if (widget.onDelete != null) {
                widget.onDelete!(widget.transaction);
              }
            },
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  // Obtenir l'icône de la catégorie
  IconData _getCategoryIcon(String categoryId) {
    final iconName = getCategoryById(categoryId).icon;

    // Mapper les noms d'icônes aux icônes de Flutter
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

  @override
  Widget build(BuildContext context) {
    final transaction = widget.transaction;
    final bool isSale = transaction.type == TransactionType.sale;
    final bool isWallet = transaction.type == TransactionType.wallet;

    // Déterminer les couleurs et icônes en fonction du type de transaction
    Color cardColor;
    Color amountColor;
    String amountPrefix;
    IconData typeIcon;

    if (isWallet) {
      final bool isDeposit = transaction.isDeposit ?? false;
      cardColor = isDeposit
        ? (Theme.of(context).brightness == Brightness.dark ? AppColors.darkCardSuccess : AppColors.lightCardSuccess)
        : (Theme.of(context).brightness == Brightness.dark ? AppColors.darkCardDanger : AppColors.lightCardDanger);
      amountColor = isDeposit
        ? (Theme.of(context).brightness == Brightness.dark ? AppColors.darkSuccess : AppColors.lightSuccess)
        : (Theme.of(context).brightness == Brightness.dark ? AppColors.darkDanger : AppColors.lightDanger);
      amountPrefix = isDeposit ? '+' : '-';
      typeIcon = isDeposit ? Icons.add_circle_outline : Icons.remove_circle_outline;
    } else {
      cardColor = isSale
        ? (Theme.of(context).brightness == Brightness.dark ? AppColors.darkCardSuccess : AppColors.lightCardSuccess)
        : (Theme.of(context).brightness == Brightness.dark ? AppColors.darkCardWarning : AppColors.lightCardWarning);
      amountColor = isSale
        ? (Theme.of(context).brightness == Brightness.dark ? AppColors.darkSuccess : AppColors.lightSuccess)
        : (Theme.of(context).brightness == Brightness.dark ? AppColors.darkWarning : AppColors.lightWarning);
      amountPrefix = isSale ? '+' : '-';
      typeIcon = isSale ? Icons.arrow_upward : Icons.arrow_downward;
    }

    return Card(
      elevation: 0.5,
      margin: const EdgeInsets.symmetric(vertical: AppSizes.s),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        side: BorderSide(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade700 : Colors.grey.shade200),
      ),
      color: cardColor,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.m),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSizes.s),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkSurface : Colors.white,
                  border: Border.all(color: amountColor.withAlpha(100), width: 1),
                  borderRadius: BorderRadius.circular(AppSizes.s),
                ),
                child: Icon(
                  typeIcon,
                  color: amountColor,
                  size: AppSizes.iconSize,
                ),
              ),
              const SizedBox(width: AppSizes.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.transaction.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSizes.xs),
                    Text(
                      _dateFormatter.format(widget.transaction.date),
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                    if (widget.transaction.quantity != null)
                      Text(
                        '${AppLocalizations.of(context).translate('quantity')}: ${widget.transaction.quantity}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    if (widget.transaction.categoryId != null)
                      Container(
                        margin: const EdgeInsets.only(top: AppSizes.xs),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.xs,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkCardPrimary : AppColors.lightCardPrimary,
                          borderRadius: BorderRadius.circular(AppSizes.xs),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getCategoryIcon(widget.transaction.categoryId!),
                              size: 14,
                              color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkPrimary : AppColors.lightPrimary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              getCategoryById(widget.transaction.categoryId!).name,
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkPrimary : AppColors.lightPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSizes.m, vertical: AppSizes.xs),
                    decoration: BoxDecoration(
                      color: amountColor.withAlpha(30),
                      borderRadius: BorderRadius.circular(AppSizes.s),
                    ),
                    child: Text(
                      '$amountPrefix${NumberFormatter.formatEuro(NumberFormatter.roundToTwoDecimals(widget.transaction.amount))}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: amountColor,
                      ),
                    ),
                  ),

                  // Boutons d'action
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Bouton d'édition
                      if (widget.onEdit != null)
                        IconButton(
                          icon: Icon(Icons.edit_outlined, color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkPrimary : AppColors.lightPrimary),
                          onPressed: () => widget.onEdit!(widget.transaction),
                          tooltip: AppLocalizations.of(context).translate('edit'),
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.only(left: AppSizes.s),
                          iconSize: 20,
                        ),
                      // Bouton de suppression
                      if (widget.onDelete != null)
                        IconButton(
                          icon: Icon(Icons.delete_outline, color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkDanger : AppColors.lightDanger),
                          onPressed: () => _showDeleteConfirmation(context),
                          tooltip: AppLocalizations.of(context).translate('delete'),
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.only(left: AppSizes.s),
                          iconSize: 20,
                        ),
                    ],
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
