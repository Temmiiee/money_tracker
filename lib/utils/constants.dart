import 'package:flutter/material.dart';

// Couleurs de l'application
class AppColors {
  // Mode jour - Couleurs principales - thème forêt ensoleillée
  static const Color lightPrimary = Color(0xFF6B9080);      // Vert sauge/forêt
  static const Color lightSecondary = Color(0xFFA4C3B2);    // Vert menthe clair
  static const Color lightBackground = Color(0xFFF6FFF8);   // Blanc cassé verdatre
  static const Color lightSurface = Colors.white;
  static const Color lightError = Color(0xFFCB997E);        // Terracotta doux

  // Mode jour - Couleurs pour les indicateurs
  static const Color lightSuccess = Color(0xFF6B9080);      // Vert sauge/forêt (même que primary)
  static const Color lightWarning = Color(0xFFDDA15E);      // Ocre doux
  static const Color lightDanger = Color(0xFFBC6C25);       // Brun-orange

  // Mode jour - Couleurs de fond pour les cartes
  static const Color lightCardSuccess = Color(0xFFCCE3DE);  // Vert menthe très pâle
  static const Color lightCardWarning = Color(0xFFFAEDCD);  // Beige doux
  static const Color lightCardDanger = Color(0xFFF4F1DE);   // Crème
  static const Color lightCardPrimary = Color(0xFFEAF4F4);  // Bleu-vert très pâle

  // Mode jour - Couleurs de texte
  static const Color lightTextPrimary = Color(0xFF3D5A6C);   // Bleu-gris foncé
  static const Color lightTextSecondary = Color(0xFF6D8A96); // Bleu-gris moyen
  static const Color lightTextHint = Color(0xFF9BBCC7);      // Bleu-gris clair

  // Mode nuit - Couleurs principales - thème forêt sombre
  static const Color darkPrimary = Color(0xFF4D8A6A);       // Vert forêt moyen (meilleur contraste)
  static const Color darkSecondary = Color(0xFF3A5F41);     // Vert forêt foncé
  static const Color darkBackground = Color(0xFF121A16);    // Noir verdatre très foncé
  static const Color darkSurface = Color(0xFF1A2520);       // Vert-noir foncé
  static const Color darkError = Color(0xFFB05A65);         // Rouge foncé avec meilleur contraste

  // Mode nuit - Couleurs pour les indicateurs
  static const Color darkSuccess = Color(0xFF4D8A6A);       // Vert forêt moyen (même que primary)
  static const Color darkWarning = Color(0xFFA88555);       // Ocre foncé (meilleur contraste)
  static const Color darkDanger = Color(0xFFA55555);        // Rouge foncé (meilleur contraste)

  // Mode nuit - Couleurs de fond pour les cartes
  static const Color darkCardSuccess = Color(0xFF1A2A1F);   // Vert forêt très foncé
  static const Color darkCardWarning = Color(0xFF252015);   // Beige très foncé
  static const Color darkCardDanger = Color(0xFF251A1A);    // Brun très foncé
  static const Color darkCardPrimary = Color(0xFF1A2520);   // Vert-noir foncé

  // Mode nuit - Couleurs de texte
  static const Color darkTextPrimary = Color(0xFFE0E0E0);    // Gris très clair (meilleur contraste)
  static const Color darkTextSecondary = Color(0xFFB0BEC5);  // Gris-bleu clair (meilleur contraste)
  static const Color darkTextHint = Color(0xFF78909C);       // Gris-bleu moyen (meilleur contraste)

  // Couleurs actuelles - par défaut en mode jour
  static const Color primary = lightPrimary;
  static const Color secondary = lightSecondary;
  static const Color background = lightBackground;
  static const Color surface = lightSurface;
  static const Color error = lightError;

  static const Color success = lightSuccess;
  static const Color warning = lightWarning;
  static const Color danger = lightDanger;

  static const Color cardSuccess = lightCardSuccess;
  static const Color cardWarning = lightCardWarning;
  static const Color cardDanger = lightCardDanger;
  static const Color cardPrimary = lightCardPrimary;

  static const Color textPrimary = lightTextPrimary;
  static const Color textSecondary = lightTextSecondary;
  static const Color textHint = lightTextHint;

  // Couleur spécifique pour le portefeuille (différente des ventes)
  static const Color wallet = lightSecondary;      // Vert menthe clair, différent du vert des ventes
}

// Textes de l'application - Clés de traduction
class AppTexts {
  // Titres des écrans
  static const String appName = "app_name";
  static const String homeTitle = "home_title";
  static const String sellTitle = "sell_title";
  static const String purchaseTitle = "purchase_title";
  static const String walletTitle = "wallet_title";
  static const String inventoryTitle = "inventory_title";
  static const String monthlyTitle = "monthly_title";

  // Textes de l'écran d'accueil
  static const String earnedThisMonth = "earned_this_month";
  static const String spentThisMonth = "spent_this_month";
  static const String walletBalance = "wallet_balance";
  static const String remainingMoney = "remaining_money";

  // Textes des formulaires
  static const String whatItem = "what_item";
  static const String price = "price";
  static const String isForStock = "is_for_stock";
  static const String soldFor = "sold_for";
  static const String soldMultiple = "sold_multiple";
  static const String addQuickSale = "add_quick_sale";

  // Boutons
  static const String save = "save";
  static const String cancel = "cancel";
  static const String add = "add";
  static const String edit = "edit";
  static const String delete = "delete";
  static const String export = "export";
}

// Dimensions et espacements
class AppSizes {
  static const double xs = 4.0;
  static const double s = 8.0;
  static const double m = 16.0;
  static const double l = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  static const double buttonHeight = 56.0;
  static const double cardRadius = 12.0;
  static const double iconSize = 24.0;
}
