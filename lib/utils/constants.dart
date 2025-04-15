import 'package:flutter/material.dart';

// Couleurs de l'application
class AppColors {
  // Couleurs principales - thème nature et doux
  static const Color primary = Color(0xFF6B9080);      // Vert sauge/forêt
  static const Color secondary = Color(0xFFA4C3B2);    // Vert menthe clair
  static const Color background = Color(0xFFF6FFF8);   // Blanc cassé verdatre
  static const Color surface = Colors.white;
  static const Color error = Color(0xFFCB997E);         // Terracotta doux

  // Couleurs pour les indicateurs - plus douces mais lisibles
  static const Color success = Color(0xFF6B9080);       // Vert sauge/forêt (même que primary)
  static const Color warning = Color(0xFFDDA15E);       // Ocre doux
  static const Color danger = Color(0xFFBC6C25);        // Brun-orange

  // Couleurs de fond pour les cartes - très douces
  static const Color cardSuccess = Color(0xFFCCE3DE);   // Vert menthe très pâle
  static const Color cardWarning = Color(0xFFFAEDCD);   // Beige doux
  static const Color cardDanger = Color(0xFFF4F1DE);    // Crème
  static const Color cardPrimary = Color(0xFFEAF4F4);   // Bleu-vert très pâle

  // Couleurs de texte - plus douces
  static const Color textPrimary = Color(0xFF3D5A6C);   // Bleu-gris foncé
  static const Color textSecondary = Color(0xFF6D8A96); // Bleu-gris moyen
  static const Color textHint = Color(0xFF9BBCC7);      // Bleu-gris clair
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
