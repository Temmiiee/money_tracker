import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../utils/constants.dart';
import '../utils/number_formatter.dart';
import '../models/transaction.dart';
import '../models/category.dart';

class ExpensePieChart extends StatefulWidget {
  final double totalSales;
  final double totalPurchases;
  final double walletTransactions;
  final List<Transaction>? transactions; // Liste des transactions pour les catégories

  const ExpensePieChart({
    super.key,
    required this.totalSales,
    required this.totalPurchases,
    required this.walletTransactions,
    this.transactions,
  });

  @override
  State<ExpensePieChart> createState() => _ExpensePieChartState();
}

class _ExpensePieChartState extends State<ExpensePieChart> with TickerProviderStateMixin {
  int touchedIndex = -1;
  int _selectedTabIndex = 0;
  late TabController _tabController;

  // Données pour les sections du graphique principal
  final List<Map<String, dynamic>> _mainSections = [
    {'name': 'Ventes', 'color': AppColors.success, 'icon': Icons.trending_up, 'type': TransactionType.sale},
    {'name': 'Achats', 'color': AppColors.warning, 'icon': Icons.trending_down, 'type': TransactionType.purchase},
    {'name': 'Portefeuille', 'color': AppColors.primary, 'icon': Icons.account_balance_wallet, 'type': TransactionType.wallet},
  ];

  @override
  void initState() {
    super.initState();
    // Initialiser avec une longueur temporaire, sera mise à jour dans didUpdateWidget
    _tabController = TabController(length: 1, vsync: this);
    _updateTabController();
  }

  @override
  void didUpdateWidget(ExpensePieChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Mettre à jour le TabController si les données ont changé
    if (oldWidget.totalSales != widget.totalSales ||
        oldWidget.totalPurchases != widget.totalPurchases) {
      _updateTabController();
    }
  }

  // Mettre à jour le TabController en fonction des données disponibles
  void _updateTabController() {
    // Calculer le nombre d'onglets en fonction des données disponibles
    int tabCount = 1; // L'onglet 'Types' est toujours présent

    if (widget.totalSales > 0) tabCount++;
    if (widget.totalPurchases > 0) tabCount++;
    if (widget.totalSales > 0 || widget.totalPurchases > 0) tabCount++;

    // Conserver l'index actuel si possible
    final int currentIndex = _tabController.index < tabCount ? _tabController.index : 0;

    // Supprimer l'ancien listener avant de disposer du controller
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();

    // Créer un nouveau TabController avec le nombre correct d'onglets
    _tabController = TabController(length: tabCount, vsync: this, initialIndex: currentIndex);

    // Ajouter le listener au nouveau controller
    _tabController.addListener(_handleTabSelection);
  }

  // Gestionnaire de sélection d'onglet
  void _handleTabSelection() {
    if (!mounted) return;
    setState(() {
      _selectedTabIndex = _tabController.index;
      touchedIndex = -1; // Réinitialiser l'index touché lors du changement d'onglet
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Si aucune donnée, ne rien afficher
    final double total = widget.totalSales + widget.totalPurchases +
                        (widget.walletTransactions >= 0 ? widget.walletTransactions : 0);

    if (total <= 0) {
      return const SizedBox.shrink(); // Ne rien afficher si pas de données
    }

    // Sélectionner le graphique en fonction de l'onglet actif
    // Déterminer les indices d'onglets en fonction des données disponibles
    int salesTabIndex = -1;
    int purchasesTabIndex = -1;
    int balanceTabIndex = -1;

    int currentIndex = 1; // L'onglet 0 est toujours 'Types'

    if (widget.totalSales > 0) {
      salesTabIndex = currentIndex++;
    }

    if (widget.totalPurchases > 0) {
      purchasesTabIndex = currentIndex++;
    }

    if (widget.totalSales > 0 || widget.totalPurchases > 0) {
      balanceTabIndex = currentIndex;
    }

    // Sélectionner le graphique approprié
    if (_selectedTabIndex == 0) {
      return _buildMainChart(); // Types (Ventes, Achats, Portefeuille)
    } else if (_selectedTabIndex == salesTabIndex) {
      return _buildCategoryChart(TransactionType.sale); // Catégories de ventes
    } else if (_selectedTabIndex == purchasesTabIndex) {
      return _buildCategoryChart(TransactionType.purchase); // Catégories d'achats
    } else if (_selectedTabIndex == balanceTabIndex) {
      return _buildNetCategoryChart(); // Solde net par catégorie
    } else {
      return _buildMainChart(); // Par défaut
    }
  }

  Widget _buildMainChart() {
    // Calculer les valeurs pour le graphique principal
    // Pour les ventes et achats, nous utilisons les valeurs absolues
    // Pour le solde net, nous calculons ventes - achats
    final double salesValue = widget.totalSales;
    final double purchasesValue = widget.totalPurchases;
    final double walletValue = widget.walletTransactions >= 0 ? widget.walletTransactions : 0;

    // Calculer le solde net (ventes - achats) pour l'affichage au centre
    final double netBalance = NumberFormatter.roundToTwoDecimals(salesValue - purchasesValue);

    // Préparer les sections avec les valeurs appropriées
    final List<Map<String, dynamic>> sections = [
      {
        ...(_mainSections[0]), // Ventes
        'value': salesValue,
        'displayValue': salesValue, // Montant à afficher
        'displayText': 'Ventes',
      },
      {
        ...(_mainSections[1]), // Achats
        'value': purchasesValue,
        'displayValue': purchasesValue, // Montant à afficher
        'displayText': 'Achats',
      },
      {
        ...(_mainSections[2]), // Portefeuille
        'value': walletValue,
        'displayValue': walletValue, // Montant à afficher
        'displayText': 'Portefeuille',
      },
    ];

    // Calculer le total pour les pourcentages (somme des valeurs absolues)
    final double total = salesValue + purchasesValue + walletValue;

    // Filtrer les sections avec des valeurs > 0
    final List<Map<String, dynamic>> activeSections = [];
    for (int i = 0; i < sections.length; i++) {
      if (sections[i]['value'] > 0) {
        activeSections.add({
          ...sections[i],
          'percent': sections[i]['value'] / total,
          'index': activeSections.length, // Index dans la liste filtrée
        });
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Onglets pour basculer entre les vues
        Container(
          margin: const EdgeInsets.only(bottom: AppSizes.m),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(AppSizes.s),
          ),
          child: TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            indicatorSize: TabBarIndicatorSize.label,
            labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            unselectedLabelStyle: const TextStyle(fontSize: 12),
            tabs: [
              Tab(text: 'Types'),
              if (widget.totalSales > 0) Tab(text: 'Ventes'),
              if (widget.totalPurchases > 0) Tab(text: 'Achats'),
              if (widget.totalSales > 0 || widget.totalPurchases > 0) Tab(text: 'Solde'),
            ],
          ),
        ),
        // Graphique principal
        LayoutBuilder(
          builder: (context, constraints) {
            // Taille fixe pour tous les graphiques pour assurer la cohérence
            final double size = 180;
            // Réduire la largeur du cercle en augmentant le rayon central et en diminuant le rayon des sections
            final double centerRadius = 50; // Rayon central plus grand
            final double sectionRadius = 65; // Section plus fine
            final double expandedRadius = 70; // Section touchée plus fine

            return SizedBox(
              height: size,
              width: size,
              child: Stack(
                children: [
                  PieChart(
                    PieChartData(
                      sectionsSpace: 0,
                      centerSpaceRadius: centerRadius,
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          setState(() {
                            if (!event.isInterestedForInteractions ||
                                pieTouchResponse == null ||
                                pieTouchResponse.touchedSection == null) {
                              touchedIndex = -1;
                              return;
                            }
                            // Vérifier si la section touchée a une valeur non nulle
                            final sectionIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                            if (sectionIndex >= 0 && sectionIndex < activeSections.length) {
                              final section = activeSections[sectionIndex];
                              if (section['value'] > 0) {
                                touchedIndex = sectionIndex;
                              }
                            }
                          });
                        },
                      ),
                      sections: activeSections.map((section) {
                        final int index = section['index'];
                        final bool isTouched = touchedIndex == index;

                        return PieChartSectionData(
                          color: section['color'],
                          value: section['value'],
                          title: '',
                          radius: isTouched ? expandedRadius : sectionRadius,
                          titleStyle: const TextStyle(fontSize: 0),
                          badgeWidget: isTouched ? _Badge(
                            section['displayText'] ?? section['name'],
                            section['color'],
                            NumberFormatter.formatEuro(section['displayValue'] ?? section['value']),
                            '${(section['percent'] * 100).toStringAsFixed(0)}%',
                          ) : null,
                          badgePositionPercentageOffset: .98,
                        );
                      }).toList(),
                    ),
                  ),
                  // Afficher une légende au centre si aucune section n'est touchée
                  if (touchedIndex == -1)
                    Positioned.fill(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Solde net',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              NumberFormatter.formatEuro(netBalance),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: netBalance >= 0 ? AppColors.success : AppColors.warning,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // Graphique du solde net par catégorie
  Widget _buildNetCategoryChart() {
    if (widget.transactions == null || widget.transactions!.isEmpty) {
      return const SizedBox.shrink();
    }

    // Regrouper les transactions par catégorie
    final Map<String, double> salesByCategory = {};
    final Map<String, double> purchasesByCategory = {};
    final Map<String, String> categoryNames = {};

    // Parcourir toutes les transactions pour calculer les totaux par catégorie
    for (final transaction in widget.transactions!) {
      if (transaction.categoryId != null) {
        final category = getCategoryById(transaction.categoryId!);
        final String categoryId = category.id;
        final double amount = transaction.amount;

        categoryNames[categoryId] = category.name;

        if (transaction.type == TransactionType.sale) {
          salesByCategory[categoryId] = (salesByCategory[categoryId] ?? 0) + amount;
        } else if (transaction.type == TransactionType.purchase) {
          purchasesByCategory[categoryId] = (purchasesByCategory[categoryId] ?? 0) + amount;
        }
      }
    }

    // Calculer le solde net par catégorie (ventes - achats)
    final Map<String, double> netBalanceByCategory = {};
    final Map<String, Color> categoryColors = {};

    // Combiner toutes les catégories (ventes et achats)
    final Set<String> allCategoryIds = {...salesByCategory.keys, ...purchasesByCategory.keys};

    // Listes pour séparer les catégories positives et négatives
    final List<String> positiveCategoryIds = [];
    final List<String> negativeCategoryIds = [];

    for (final categoryId in allCategoryIds) {
      final double sales = salesByCategory[categoryId] ?? 0;
      final double purchases = purchasesByCategory[categoryId] ?? 0;
      final double netBalance = NumberFormatter.roundToTwoDecimals(sales - purchases);

      // Ne garder que les catégories avec un solde non nul
      if (netBalance != 0) {
        netBalanceByCategory[categoryId] = netBalance;
        if (netBalance > 0) {
          positiveCategoryIds.add(categoryId);
        } else {
          negativeCategoryIds.add(categoryId);
        }
      }
    }

    // Palettes de couleurs pour les soldes positifs et négatifs
    final List<Color> positiveColorPalette = [
      AppColors.success,
      const Color(0xFF66BB6A), // Vert clair
      const Color(0xFF43A047), // Vert moyen
      const Color(0xFF2E7D32), // Vert foncé
      const Color(0xFF1B5E20), // Vert très foncé
      const Color(0xFF81C784), // Vert très clair
    ];

    final List<Color> negativeColorPalette = [
      AppColors.warning,
      const Color(0xFFFFB74D), // Orange clair
      const Color(0xFFFFA726), // Orange moyen
      const Color(0xFFFF9800), // Orange foncé
      const Color(0xFFE65100), // Orange très foncé
      const Color(0xFFFFCC80), // Orange très clair
    ];

    // Assigner des couleurs différentes aux catégories positives
    int colorIndex = 0;
    for (final categoryId in positiveCategoryIds) {
      categoryColors[categoryId] = positiveColorPalette[colorIndex % positiveColorPalette.length];
      colorIndex++;
    }

    // Assigner des couleurs différentes aux catégories négatives
    colorIndex = 0;
    for (final categoryId in negativeCategoryIds) {
      categoryColors[categoryId] = negativeColorPalette[colorIndex % negativeColorPalette.length];
      colorIndex++;
    }

    // Si aucune catégorie avec un solde non nul, afficher un message
    if (netBalanceByCategory.isEmpty) {
      return const Center(
        child: Text(
          'Aucune catégorie avec un solde',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    // Préparer les sections pour le graphique
    final List<Map<String, dynamic>> categorySections = [];

    // Calculer la somme des valeurs absolues pour les pourcentages
    final double totalAbsValue = netBalanceByCategory.values
        .map((value) => value.abs())
        .fold(0.0, (sum, value) => sum + value);

    int index = 0;
    netBalanceByCategory.forEach((categoryId, value) {
      categorySections.add({
        'id': categoryId,
        'name': categoryNames[categoryId] ?? 'Inconnu',
        'color': categoryColors[categoryId] ?? AppColors.primary,
        'value': value.abs(), // Utiliser la valeur absolue pour le graphique
        'displayValue': value, // Garder la valeur réelle pour l'affichage
        'percent': value.abs() / totalAbsValue,
        'index': index++,
      });
    });

    return LayoutBuilder(
      builder: (context, constraints) {
        // Taille fixe pour tous les graphiques pour assurer la cohérence
        final double size = 180;
        // Réduire la largeur du cercle en augmentant le rayon central et en diminuant le rayon des sections
        final double centerRadius = 50; // Rayon central plus grand
        final double sectionRadius = 65; // Section plus fine
        final double expandedRadius = 70; // Section touchée plus fine

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Onglets pour basculer entre les vues
            Container(
              margin: const EdgeInsets.only(bottom: AppSizes.m),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(AppSizes.s),
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.primary,
                indicatorSize: TabBarIndicatorSize.label,
                labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                unselectedLabelStyle: const TextStyle(fontSize: 12),
                tabs: [
                  Tab(text: 'Types'),
                  if (widget.totalSales > 0) Tab(text: 'Ventes'),
                  if (widget.totalPurchases > 0) Tab(text: 'Achats'),
                  if (widget.totalSales > 0 || widget.totalPurchases > 0) Tab(text: 'Solde'),
                ],
              ),
            ),
            // Graphique des catégories
            SizedBox(
              height: size,
              width: size,
              child: Stack(
                children: [
                  PieChart(
                    PieChartData(
                      sectionsSpace: 0,
                      centerSpaceRadius: centerRadius,
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          setState(() {
                            if (!event.isInterestedForInteractions ||
                                pieTouchResponse == null ||
                                pieTouchResponse.touchedSection == null) {
                              touchedIndex = -1;
                              return;
                            }
                            // Vérifier si la section touchée a une valeur non nulle
                            final sectionIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                            if (sectionIndex >= 0 && sectionIndex < categorySections.length) {
                              final section = categorySections[sectionIndex];
                              if (section['value'] > 0) {
                                touchedIndex = sectionIndex;
                              }
                            }
                          });
                        },
                      ),
                      sections: categorySections.map((section) {
                        final int index = section['index'];
                        final bool isTouched = touchedIndex == index;
                        final double displayValue = section['displayValue'];
                        final String sign = displayValue >= 0 ? '+' : '';

                        return PieChartSectionData(
                          color: section['color'],
                          value: section['value'],
                          title: '',
                          radius: isTouched ? expandedRadius : sectionRadius,
                          titleStyle: const TextStyle(fontSize: 0),
                          badgeWidget: isTouched ? _Badge(
                            section['name'],
                            section['color'],
                            '$sign${NumberFormatter.formatEuro(displayValue)}',
                            '${(section['percent'] * 100).toStringAsFixed(0)}%',
                          ) : null,
                          badgePositionPercentageOffset: .98,
                        );
                      }).toList(),
                    ),
                  ),
                  // Afficher une légende au centre si aucune section n'est touchée
                  if (touchedIndex == -1)
                    Positioned.fill(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Solde',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 1),
                            Text(
                              NumberFormatter.formatEuro(NumberFormatter.roundToTwoDecimals(netBalanceByCategory.values.fold(0.0, (sum, value) => sum + value))),
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: NumberFormatter.roundToTwoDecimals(netBalanceByCategory.values.fold(0.0, (sum, value) => sum + value)) >= 0
                                    ? AppColors.success
                                    : AppColors.warning,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // Graphique des catégories
  Widget _buildCategoryChart(TransactionType filterType) {
    if (widget.transactions == null || widget.transactions!.isEmpty) {
      return const SizedBox.shrink();
    }

    // Regrouper les transactions par catégorie
    final Map<String, double> categoryTotals = {};
    final Map<String, Color> categoryColors = {};
    final Map<String, String> categoryNames = {};

    // Filtrer les transactions par type (vente ou achat)
    final filteredTransactions = widget.transactions!.where(
      (transaction) => transaction.type == filterType
    ).toList();

    // Si aucune transaction du type demandé, afficher un message
    if (filteredTransactions.isEmpty) {
      return Center(
        child: Text(
          filterType == TransactionType.sale
              ? 'Aucune vente avec catégorie'
              : 'Aucun achat avec catégorie',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    // Parcourir les transactions filtrées pour calculer les totaux par catégorie
    for (final transaction in filteredTransactions) {
      if (transaction.categoryId != null) {
        final category = getCategoryById(transaction.categoryId!);
        final String categoryId = category.id;
        final double amount = transaction.amount;

        categoryTotals[categoryId] = (categoryTotals[categoryId] ?? 0) + amount;
        categoryNames[categoryId] = category.name;
      }
    }

    // Assigner des couleurs différentes aux catégories
    final List<Color> categoryColorPalette = [
      AppColors.success,
      const Color(0xFF66BB6A), // Vert clair
      const Color(0xFF43A047), // Vert moyen
      const Color(0xFF2E7D32), // Vert foncé
      const Color(0xFF1B5E20), // Vert très foncé
      const Color(0xFF81C784), // Vert très clair
    ];

    final List<Color> purchaseColorPalette = [
      AppColors.warning,
      const Color(0xFFFFB74D), // Orange clair
      const Color(0xFFFFA726), // Orange moyen
      const Color(0xFFFF9800), // Orange foncé
      const Color(0xFFE65100), // Orange très foncé
      const Color(0xFFFFCC80), // Orange très clair
    ];

    final List<Color> colorPalette = filterType == TransactionType.sale
        ? categoryColorPalette
        : purchaseColorPalette;

    int colorIndex = 0;
    for (final categoryId in categoryTotals.keys) {
      categoryColors[categoryId] = colorPalette[colorIndex % colorPalette.length];
      colorIndex++;
    }

    // Si aucune catégorie, ne rien afficher
    if (categoryTotals.isEmpty) {
      return const Center(
        child: Text(
          'Aucune catégorie',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    // Préparer les sections pour le graphique
    final List<Map<String, dynamic>> categorySections = [];
    final double total = categoryTotals.values.fold(0.0, (sum, value) => sum + value);

    int index = 0;
    categoryTotals.forEach((categoryId, value) {
      categorySections.add({
        'id': categoryId,
        'name': categoryNames[categoryId] ?? 'Inconnu',
        'color': categoryColors[categoryId] ?? AppColors.primary,
        'value': value,
        'percent': value / total,
        'index': index++,
      });
    });

    return LayoutBuilder(
      builder: (context, constraints) {
        // Taille fixe pour tous les graphiques pour assurer la cohérence
        final double size = 180;
        // Réduire la largeur du cercle en augmentant le rayon central et en diminuant le rayon des sections
        final double centerRadius = 50; // Rayon central plus grand
        final double sectionRadius = 65; // Section plus fine
        final double expandedRadius = 70; // Section touchée plus fine

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Onglets pour basculer entre les vues
            Container(
              margin: const EdgeInsets.only(bottom: AppSizes.m),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(AppSizes.s),
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.primary,
                indicatorSize: TabBarIndicatorSize.label,
                labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                unselectedLabelStyle: const TextStyle(fontSize: 12),
                tabs: [
                  Tab(text: 'Types'),
                  if (widget.totalSales > 0) Tab(text: 'Ventes'),
                  if (widget.totalPurchases > 0) Tab(text: 'Achats'),
                  if (widget.totalSales > 0 || widget.totalPurchases > 0) Tab(text: 'Solde'),
                ],
              ),
            ),
            // Graphique des catégories
            SizedBox(
              height: size,
              width: size,
              child: Stack(
                children: [
                  PieChart(
                    PieChartData(
                      sectionsSpace: 0,
                      centerSpaceRadius: centerRadius,
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          setState(() {
                            if (!event.isInterestedForInteractions ||
                                pieTouchResponse == null ||
                                pieTouchResponse.touchedSection == null) {
                              touchedIndex = -1;
                              return;
                            }
                            // Vérifier si la section touchée a une valeur non nulle
                            final sectionIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                            if (sectionIndex >= 0 && sectionIndex < categorySections.length) {
                              final section = categorySections[sectionIndex];
                              if (section['value'] > 0) {
                                touchedIndex = sectionIndex;
                              }
                            }
                          });
                        },
                      ),
                      sections: categorySections.map((section) {
                        final int index = section['index'];
                        final bool isTouched = touchedIndex == index;

                        return PieChartSectionData(
                          color: section['color'],
                          value: section['value'],
                          title: '',
                          radius: isTouched ? expandedRadius : sectionRadius,
                          titleStyle: const TextStyle(fontSize: 0),
                          badgeWidget: isTouched ? _Badge(
                            section['name'],
                            section['color'],
                            NumberFormatter.formatEuro(section['value']),
                            '${(section['percent'] * 100).toStringAsFixed(0)}%',
                          ) : null,
                          badgePositionPercentageOffset: .98,
                        );
                      }).toList(),
                    ),
                  ),
                  // Afficher une légende au centre si aucune section n'est touchée
                  if (touchedIndex == -1)
                    Positioned.fill(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              filterType == TransactionType.sale ? 'Ventes' : 'Achats',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              NumberFormatter.formatEuro(total),
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

// Widget pour afficher un badge sur la section touchée
class _Badge extends StatelessWidget {
  final String title;
  final Color color;
  final String amount;
  final String percentage;

  const _Badge(this.title, this.color, this.amount, this.percentage);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: PieChart.defaultDuration,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            offset: const Offset(0, 1),
            blurRadius: 3,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      constraints: const BoxConstraints(maxWidth: 120), // Limiter la largeur maximale
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            amount,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color.withAlpha(200),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: color.withAlpha(50),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              percentage,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
