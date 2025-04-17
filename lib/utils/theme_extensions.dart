import 'package:flutter/material.dart';
import 'constants.dart';

/// Extension pour faciliter l'accès aux couleurs du thème en fonction du mode
extension ThemeExtensions on BuildContext {
  /// Vérifie si le thème actuel est en mode sombre
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  /// Retourne la couleur primaire en fonction du mode
  Color get primaryColor => isDarkMode ? AppColors.darkPrimary : AppColors.lightPrimary;

  /// Retourne la couleur secondaire en fonction du mode
  Color get secondaryColor => isDarkMode ? AppColors.darkSecondary : AppColors.lightSecondary;

  /// Retourne la couleur de fond en fonction du mode
  Color get backgroundColor => isDarkMode ? AppColors.darkBackground : AppColors.lightBackground;

  /// Retourne la couleur de surface en fonction du mode
  Color get surfaceColor => isDarkMode ? AppColors.darkSurface : AppColors.lightSurface;

  /// Retourne la couleur d'erreur en fonction du mode
  Color get errorColor => isDarkMode ? AppColors.darkError : AppColors.lightError;

  /// Retourne la couleur de succès en fonction du mode
  Color get successColor => isDarkMode ? AppColors.darkSuccess : AppColors.lightSuccess;

  /// Retourne la couleur d'avertissement en fonction du mode
  Color get warningColor => isDarkMode ? AppColors.darkWarning : AppColors.lightWarning;

  /// Retourne la couleur de danger en fonction du mode
  Color get dangerColor => isDarkMode ? AppColors.darkDanger : AppColors.lightDanger;

  /// Retourne la couleur de carte de succès en fonction du mode
  Color get cardSuccessColor => isDarkMode ? AppColors.darkCardSuccess : AppColors.lightCardSuccess;

  /// Retourne la couleur de carte d'avertissement en fonction du mode
  Color get cardWarningColor => isDarkMode ? AppColors.darkCardWarning : AppColors.lightCardWarning;

  /// Retourne la couleur de carte de danger en fonction du mode
  Color get cardDangerColor => isDarkMode ? AppColors.darkCardDanger : AppColors.lightCardDanger;

  /// Retourne la couleur de carte primaire en fonction du mode
  Color get cardPrimaryColor => isDarkMode ? AppColors.darkCardPrimary : AppColors.lightCardPrimary;

  /// Retourne la couleur de texte primaire en fonction du mode
  Color get textPrimaryColor => isDarkMode ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

  /// Retourne la couleur de texte secondaire en fonction du mode
  Color get textSecondaryColor => isDarkMode ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

  /// Retourne la couleur de texte hint en fonction du mode
  Color get textHintColor => isDarkMode ? AppColors.darkTextHint : AppColors.lightTextHint;

  /// Retourne la couleur de bordure en fonction du mode
  Color get borderColor => isDarkMode ? Colors.grey.shade700 : Colors.grey.shade200;
}
