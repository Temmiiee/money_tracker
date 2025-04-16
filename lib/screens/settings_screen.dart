import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../utils/constants.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import '../services/data_export_service.dart';
import '../localization/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  final Function(Locale)? onLanguageChanged;

  const SettingsScreen({super.key, this.onLanguageChanged});

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
        title: const Text('Paramètres'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.m),
        children: [
          // Section Langue
          _buildSectionHeader('Langue'),
          _buildLanguageCard(),

          const SizedBox(height: AppSizes.l),

          // Section Données
          _buildSectionHeader('Gestion des données'),
          _buildSettingCard(
            title: 'Exporter les données (CSV)',
            subtitle: 'Exporter toutes vos données au format CSV',
            icon: Icons.file_download,
            onTap: () {
              _exportDataToCSV();
            },
          ),
          _buildSettingCard(
            title: 'Exporter les données (PDF)',
            subtitle: 'Exporter un rapport au format PDF',
            icon: Icons.picture_as_pdf,
            onTap: () {
              _exportDataToPDF();
            },
          ),
          _buildSettingCard(
            title: 'Importer des données',
            subtitle: 'Importer des données depuis un fichier CSV',
            icon: Icons.file_upload,
            onTap: () {
              _importDataFromCSV();
            },
          ),
          _buildSettingCard(
            title: 'Réinitialiser les données',
            subtitle: 'Supprimer toutes les données de l\'application',
            icon: Icons.delete_forever,
            iconColor: AppColors.danger,
            onTap: () {
              _showResetConfirmationDialog();
            },
          ),

          const SizedBox(height: AppSizes.l),

          // Section À propos
          _buildSectionHeader('À propos'),
          _buildSettingCard(
            title: 'Version de l\'application',
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
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: FutureBuilder<Locale>(
        future: AppLocalizations.getLocale(),
        builder: (context, snapshot) {
          String languageText = 'Chargement...';
          if (snapshot.hasData) {
            languageText = snapshot.data!.languageCode == 'fr' ? 'Français' : 'English';
          }

          return ListTile(
            leading: const Icon(
              Icons.language,
              color: AppColors.primary,
            ),
            title: const Text(
              'Langue de l\'application',
              style: TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(languageText),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showLanguageDialog(),
          );
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
          title: const Text('Choisir la langue'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Français'),
                leading: const Icon(Icons.check, color: AppColors.primary),
                onTap: () => _changeLanguage('fr'),
              ),
              ListTile(
                title: const Text('English'),
                leading: const Icon(Icons.language),
                onTap: () => _changeLanguage('en'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
          ],
        );
      },
    );
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
          content: Text('Langue changée en ${languageCode == 'fr' ? 'français' : 'anglais'}'),
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
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
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
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: iconColor ?? AppColors.primary,
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
      _showLoadingDialog('Exportation des données en cours...');

      // Exporter les données
      final result = await _dataExportService.exportToCSV();

      // Fermer le dialogue de chargement
      if (mounted) Navigator.of(context).pop();

      // Afficher un message de succès
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(kIsWeb ? 'Fichier CSV téléchargé avec succès' : 'Données exportées avec succès dans: $result'),
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
            content: Text('Erreur lors de l\'exportation: $e'),
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
      _showLoadingDialog('Génération du PDF en cours...');

      // Exporter les données
      final result = await _dataExportService.exportToPDF();

      // Fermer le dialogue de chargement
      if (mounted) Navigator.of(context).pop();

      // Afficher un message de succès
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(kIsWeb ? 'Rapport PDF téléchargé avec succès' : 'PDF généré avec succès dans: $result'),
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
            content: Text('Erreur lors de la génération du PDF: $e'),
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
      _showLoadingDialog('Importation des données en cours...');

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
        throw Exception('Impossible de lire le fichier');
      }

      // Importer les données
      await _dataExportService.importFromCSV(csvContent);

      // Fermer le dialogue de chargement
      if (mounted) Navigator.of(context).pop();

      // Afficher un message de succès
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Données importées avec succès'),
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
            content: Text('Erreur lors de l\'importation: $e'),
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
          title: const Text('Réinitialiser les données'),
          content: const Text(
            'Êtes-vous sûr de vouloir supprimer toutes les données de l\'application ? Cette action est irréversible.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetAllData();
              },
              style: TextButton.styleFrom(
                foregroundColor: AppColors.danger,
              ),
              child: const Text('Réinitialiser'),
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
      _showLoadingDialog('Réinitialisation des données en cours...');

      // Réinitialiser les données
      await _dataExportService.resetAllData();

      // Fermer le dialogue de chargement
      if (mounted) Navigator.of(context).pop();

      // Afficher un message de succès
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Données réinitialisées avec succès'),
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
            content: Text('Erreur lors de la réinitialisation: $e'),
            backgroundColor: AppColors.danger,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
