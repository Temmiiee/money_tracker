import 'package:intl/intl.dart';

class NumberFormatter {
  // Formater un nombre avec des espaces pour les milliers et 2 décimales maximum
  static String formatCurrency(double value) {
    // Arrondir à 2 décimales pour éviter les problèmes de précision
    final roundedValue = (value * 100).round() / 100;

    // Créer un formateur avec le séparateur de milliers et 2 décimales maximum
    final formatter = NumberFormat.currency(
      locale: 'fr_FR',
      symbol: '',  // Pas de symbole, on l'ajoutera manuellement
      decimalDigits: 2,
    );

    // Formater le nombre avec le formateur standard
    String formattedValue = formatter.format(roundedValue);

    // Remplacer l'espace fin par un espace normal pour plus de lisibilité
    // L'espace utilisé par défaut en fr_FR est un espace fin (\u202F)
    formattedValue = formattedValue.replaceAll('\u202F', ' ');

    return formattedValue;
  }

  // Formater un nombre avec des espaces pour les milliers et ajouter le symbole €
  static String formatEuro(double value) {
    return '${formatCurrency(value)} €';
  }

  // Arrondir un nombre à 2 décimales
  static double roundToTwoDecimals(double value) {
    return (value * 100).round() / 100;
  }
}
