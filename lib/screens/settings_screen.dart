import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../utils/constants.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import '../services/data_export_service.dart';
import '../localization/app_localizations.dart';
import '../services/theme_service.dart';

class SettingsScreen extends StatefulWidget {
  final Function(Locale)? onLanguageChanged;
  final Function(ThemeMode)? onThemeChanged;

  const SettingsScreen({super.key, this.onLanguageChanged, this.onThemeChanged});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _appVersion = '';
  final DataExportService _dataExportService = DataExportService();

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = '${packageInfo.version} (${packageInfo.buildNumber})';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('settings_title')),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.m),
        children: [
          // Section Apparence
          _buildSectionHeader(AppLocalizations.of(context).translate('appearance')),
          _buildLanguageCard(),
          _buildThemeCard(),

          const SizedBox(height: AppSizes.l),

          // Section Données
          _buildSectionHeader(AppLocalizations.of(context).translate('data_management')),
          _buildSettingCard(
            title: AppLocalizations.of(context).translate('export_csv'),
            subtitle: AppLocalizations.of(context).translate('export_csv_desc'),
            icon: Icons.file_download,
            onTap: () {
              _exportDataToCSV();
            },
          ),
          _buildSettingCard(
            title: AppLocalizations.of(context).translate('export'),
            subtitle: AppLocalizations.of(context).translate('export_pdf_desc'),
            icon: Icons.picture_as_pdf,
            onTap: () {
              _exportDataToPDF();
            },
          ),
          _buildSettingCard(
            title: AppLocalizations.of(context).translate('import_csv'),
            subtitle: AppLocalizations.of(context).translate('import_csv_desc'),
            icon: Icons.file_upload,
            onTap: () {
              _importDataFromCSV();
            },
          ),
          _buildSettingCard(
            title: AppLocalizations.of(context).translate('reset_data'),
            subtitle: AppLocalizations.of(context).translate('reset_data_desc'),
            icon: Icons.delete_forever,
            iconColor: AppColors.danger,
            onTap: () {
              _showResetConfirmationDialog();
            },
          ),

          const SizedBox(height: AppSizes.l),

          // Section À propos
          _buildSectionHeader(AppLocalizations.of(context).translate('about')),
          _buildSettingCard(
            title: AppLocalizations.of(context).translate('version'),
            subtitle: _appVersion,
            icon: Icons.info,
            onTap: () {},
            trailing: const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageCard() {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: AppSizes.s),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        side: BorderSide(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade700 : Colors.grey.shade200),
      ),
      child: FutureBuilder<Locale>(
        future: AppLocalizations.getLocale(),
        builder: (context, snapshot) {
          String languageText = AppLocalizations.of(context).translate('loading');
          if (snapshot.hasData) {
            languageText = snapshot.data!.languageCode == 'fr' ? AppLocalizations.of(context).translate('french') : AppLocalizations.of(context).translate('english');
          }

          return ListTile(
            leading: Icon(
              Icons.language,
              color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkPrimary : AppColors.lightPrimary,
            ),
            title: Text(
              AppLocalizations.of(context).translate('language_setting'),
              style: TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(languageText),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showLanguageDialog(),
          );
        },
      ),
    );
  }

  // Carte pour le thème avec switch
  Widget _buildThemeCard() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: AppSizes.s),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        side: BorderSide(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade700 : Colors.grey.shade200),
      ),
      child: SwitchListTile(
        secondary: Icon(
          isDarkMode ? Icons.dark_mode : Icons.light_mode,
          color: isDarkMode ? AppColors.darkPrimary : AppColors.lightPrimary,
        ),
        title: Text(
          AppLocalizations.of(context).translate('dark_mode_setting'),
          style: TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(isDarkMode ? AppLocalizations.of(context).translate('enabled') : AppLocalizations.of(context).translate('disabled')),
        value: isDarkMode,
        activeColor: AppColors.darkPrimary,
        onChanged: (bool value) {
          _toggleTheme();
        },
      ),
    );
  }

  // Boîte de dialogue pour changer la langue
  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).translate('choose_language')),
          content: FutureBuilder<Locale>(
            future: AppLocalizations.getLocale(),
            builder: (context, snapshot) {
              final currentLanguage = snapshot.data?.languageCode ?? 'fr';
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Text(AppLocalizations.of(context).translate('french')),
                    leading: Icon(
                      currentLanguage == 'fr' ? Icons.check : Icons.language,
                      color: currentLanguage == 'fr' ? (Theme.of(context).brightness == Brightness.dark ? AppColors.darkPrimary : AppColors.lightPrimary) : null,
                    ),
                    onTap: () => _changeLanguage('fr'),
                  ),
                  ListTile(
                    title: Text(AppLocalizations.of(context).translate('english')),
                    leading: Icon(
                      currentLanguage == 'en' ? Icons.check : Icons.language,
                      color: currentLanguage == 'en' ? (Theme.of(context).brightness == Brightness.dark ? AppColors.darkPrimary : AppColors.lightPrimary) : null,
                    ),
                    onTap: () => _changeLanguage('en'),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context).translate('cancel')),
            ),
          ],
        );
      },
    );
  }

  // Basculer entre les thèmes
  void _toggleTheme() async {
    final newThemeMode = await ThemeService.toggleThemeMode();

    // Notifier le widget parent du changement de thème
    if (widget.onThemeChanged != null) {
      widget.onThemeChanged!(newThemeMode);
    }

    // Afficher un message de confirmation
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppLocalizations.of(context).translate('theme_changed')} ${newThemeMode == ThemeMode.dark ? AppLocalizations.of(context).translate('dark_mode') : AppLocalizations.of(context).translate('light_mode')}'),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }



  // Changer la langue
  void _changeLanguage(String languageCode) async {
    await AppLocalizations.setLocale(languageCode);
    if (mounted) {
      Navigator.pop(context); // Fermer la boîte de dialogue

      // Notifier le widget parent du changement de langue
      if (widget.onLanguageChanged != null) {
        widget.onLanguageChanged!(Locale(languageCode));
      }

      // Afficher un message de confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppLocalizations.of(context).translate('language_changed')} ${languageCode == 'fr' ? AppLocalizations.of(context).translate('to_french') : AppLocalizations.of(context).translate('to_english')}'),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 2),
        ),
      );

      // Redémarrer l'application pour appliquer le changement de langue
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
        }
      });
    }
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSizes.s, bottom: AppSizes.s),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkPrimary : AppColors.lightPrimary,
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    Color? iconColor,
    Widget? trailing,
  }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: AppSizes.s),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        side: BorderSide(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade700 : Colors.grey.shade200),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: iconColor ?? (Theme.of(context).brightness == Brightness.dark ? AppColors.darkPrimary : AppColors.lightPrimary),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  // Fonction pour exporter les données au format CSV
  Future<void> _exportDataToCSV() async {
    try {
      // Afficher un indicateur de chargement
      _showLoadingDialog(AppLocalizations.of(context).translate('exporting_data'));

      // Exporter les données
      final result = await _dataExportService.exportToCSV();

      // Fermer le dialogue de chargement
      if (mounted) Navigator.of(context).pop();

      // Afficher un message de succès
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(kIsWeb ? AppLocalizations.of(context).translate('csv_downloaded') : '${AppLocalizations.of(context).translate('data_exported')}: $result'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      // Fermer le dialogue de chargement en cas d'erreur
      if (mounted) Navigator.of(context).pop();

      // Afficher un message d'erreur
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context).translate('error_exporting')}: $e'),
            backgroundColor: AppColors.danger,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // Fonction pour exporter les données au format PDF
  Future<void> _exportDataToPDF() async {
    try {
      // Afficher un indicateur de chargement
      _showLoadingDialog(AppLocalizations.of(context).translate('generating_pdf'));

      // Exporter les données
      final result = await _dataExportService.exportToPDF();

      // Fermer le dialogue de chargement
      if (mounted) Navigator.of(context).pop();

      // Afficher un message de succès
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(kIsWeb ? AppLocalizations.of(context).translate('pdf_downloaded') : '${AppLocalizations.of(context).translate('pdf_generated')}: $result'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      // Fermer le dialogue de chargement en cas d'erreur
      if (mounted) Navigator.of(context).pop();

      // Afficher un message d'erreur
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context).translate('error_generating_pdf')}: $e'),
            backgroundColor: AppColors.danger,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // Fonction pour importer des données depuis un fichier CSV
  Future<void> _importDataFromCSV() async {
    try {
      // Sélectionner un fichier CSV
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result == null || result.files.isEmpty) {
        return; // L'utilisateur a annulé la sélection
      }

      // Afficher un indicateur de chargement
      _showLoadingDialog(AppLocalizations.of(context).translate('importing_data'));

      // Lire le contenu du fichier
      String csvContent = '';
      if (result.files.single.bytes != null) {
        // Web
        csvContent = String.fromCharCodes(result.files.single.bytes!);
      } else if (result.files.single.path != null) {
        // Mobile/Desktop
        final file = File(result.files.single.path!);
        csvContent = await file.readAsString();
      } else {
        throw Exception(AppLocalizations.of(context).translate('cannot_read_file'));
      }

      // Importer les données
      await _dataExportService.importFromCSV(csvContent);

      // Fermer le dialogue de chargement
      if (mounted) Navigator.of(context).pop();

      // Afficher un message de succès
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).translate('data_imported')),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Fermer le dialogue de chargement en cas d'erreur
      if (mounted) Navigator.of(context).pop();

      // Afficher un message d'erreur
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context).translate('error_importing')}: $e'),
            backgroundColor: AppColors.danger,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // Afficher un dialogue de chargement
  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: AppSizes.m),
              Expanded(
                child: Text(message),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showResetConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).translate('reset_data')),
          content: Text(
            AppLocalizations.of(context).translate('reset_confirmation'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(AppLocalizations.of(context).translate('cancel')),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetAllData();
              },
              style: TextButton.styleFrom(
                foregroundColor: AppColors.danger,
              ),
              child: Text(AppLocalizations.of(context).translate('reset')),
            ),
          ],
        );
      },
    );
  }

  // Fonction pour réinitialiser toutes les données
  Future<void> _resetAllData() async {
    try {
      // Afficher un indicateur de chargement
      _showLoadingDialog(AppLocalizations.of(context).translate('resetting_data'));

      // Réinitialiser les données
      await _dataExportService.resetAllData();

      // Fermer le dialogue de chargement
      if (mounted) Navigator.of(context).pop();

      // Afficher un message de succès
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).translate('data_reset')),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 2),
          ),
        );

        // Retourner à l'écran d'accueil après un court délai
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            // Retourner à l'écran d'accueil et remplacer la pile de navigation
            Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
          }
        });
      }
    } catch (e) {
      // Fermer le dialogue de chargement en cas d'erreur
      if (mounted) Navigator.of(context).pop();

      // Afficher un message d'erreur
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context).translate('error_resetting')}: $e'),
            backgroundColor: AppColors.danger,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
