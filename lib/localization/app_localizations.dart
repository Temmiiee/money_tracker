import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'languages/french.dart';
import 'languages/english.dart';

class AppLocalizations {
  final Locale locale;
  
  AppLocalizations(this.locale);
  
  // Méthode d'aide pour obtenir les traductions
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }
  
  // Méthode pour obtenir la langue actuelle
  static Future<Locale> getLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('languageCode') ?? 'fr';
    return Locale(languageCode);
  }
  
  // Méthode pour changer la langue
  static Future<void> setLocale(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', languageCode);
  }
  
  // Méthode pour obtenir les traductions
  static Map<String, Map<String, String>> _localizedValues = {
    'fr': french,
    'en': english,
  };
  
  // Méthode pour obtenir une traduction
  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }
  
  // Méthode pour obtenir toutes les langues disponibles
  static List<Locale> supportedLocales() {
    return [
      const Locale('fr', ''), // Français
      const Locale('en', ''), // Anglais
    ];
  }
}

// Délégué pour la localisation
class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();
  
  @override
  bool isSupported(Locale locale) {
    return ['fr', 'en'].contains(locale.languageCode);
  }
  
  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }
  
  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
