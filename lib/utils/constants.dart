import 'package:flutter/material.dart';

// Couleurs de l'application
class AppColors {
  // Mode jour - Couleurs principales - thème nature et doux
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

  // Mode nuit - Couleurs principales - thème sombre nature
  static const Color darkPrimary = Color(0xFF4A6670);       // Bleu-vert foncé
  static const Color darkSecondary = Color(0xFF5F8A8B);     // Bleu-vert moyen
  static const Color darkBackground = Color(0xFF1E2A2D);    // Gris très foncé avec teinte bleue
  static const Color darkSurface = Color(0xFF263238);       // Gris foncé avec teinte bleue
  static const Color darkError = Color(0xFFCF6679);         // Rose foncé

  // Mode nuit - Couleurs pour les indicateurs
  static const Color darkSuccess = Color(0xFF81C784);       // Vert plus vif pour contraste
  static const Color darkWarning = Color(0xFFFFD54F);       // Jaune plus vif pour contraste
  static const Color darkDanger = Color(0xFFE57373);        // Rouge plus vif pour contraste

  // Mode nuit - Couleurs de fond pour les cartes
  static const Color darkCardSuccess = Color(0xFF1B3C39);   // Vert très foncé
  static const Color darkCardWarning = Color(0xFF3E3527);   // Beige très foncé
  static const Color darkCardDanger = Color(0xFF3E2723);    // Brun très foncé
  static const Color darkCardPrimary = Color(0xFF263238);   // Bleu-gris foncé

  // Mode nuit - Couleurs de texte
  static const Color darkTextPrimary = Color(0xFFE0E0E0);    // Blanc cassé
  static const Color darkTextSecondary = Color(0xFFB0BEC5);  // Gris clair
  static const Color darkTextHint = Color(0xFF78909C);       // Gris moyen

  // Couleurs actuelles - seront définies en fonction du mode
  static const Color primary = Color(0xFF4A6670);           // Par défaut en mode nuit
  static const Color secondary = Color(0xFF5F8A8B);
  static const Color background = Color(0xFF1E2A2D);
  static const Color surface = Color(0xFF263238);
  static const Color error = Color(0xFFCF6679);

  static const Color success = Color(0xFF81C784);
  static const Color warning = Color(0xFFFFD54F);
  static const Color danger = Color(0xFFE57373);

  static const Color cardSuccess = Color(0xFF1B3C39);
  static const Color cardWarning = Color(0xFF3E3527);
  static const Color cardDanger = Color(0xFF3E2723);
  static const Color cardPrimary = Color(0xFF263238);

  static const Color textPrimary = Color(0xFFE0E0E0);
  static const Color textSecondary = Color(0xFFB0BEC5);
  static const Color textHint = Color(0xFF78909C);

  // Couleur spécifique pour le portefeuille (différente des ventes)
  static const Color wallet = Color(0xFF5F8A8B);      // Bleu-vert moyen, différent du vert des ventes

  // Note: Nous utilisons maintenant des couleurs constantes pour éviter les erreurs
  // avec const dans le code. Le mode nuit est appliqué par défaut.
}

// Textes de l'application
class AppTexts {
  // Titres des écrans
  static const String appName = "Money Tracker";
  static const String homeTitle = "Accueil";
  static const String sellTitle = "Je vends quelque chose";
  static const String purchaseTitle = "J'ai acheté quelque chose";
  static const String walletTitle = "Portefeuille";
  static const String inventoryTitle = "Mon stock";
  static const String monthlyTitle = "Mon mois";

  // Textes de l'écran d'accueil
  static const String earnedThisMonth = "Argent gagné ce mois";
  static const String spentThisMonth = "Argent dépensé ce mois";
  static const String walletBalance = "Solde du portefeuille";
  static const String remainingMoney = "Ce qu'il reste en poche";

  // Textes des formulaires
  static const String whatItem = "Quoi ?";
  static const String price = "Prix";
  static const String isForStock = "Est-ce pour refaire du stock ?";
  static const String soldFor = "Prix unitaire";
  static const String soldMultiple = "J'ai vendu plusieurs";
  static const String addQuickSale = "Ajouter rapidement une vente";

  // Boutons
  static const String save = "Enregistrer";
  static const String cancel = "Annuler";
  static const String add = "Ajouter";
  static const String edit = "Modifier";
  static const String delete = "Supprimer";
  static const String export = "Exporter en PDF";
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
