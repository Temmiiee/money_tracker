import 'dart:convert';
import 'dart:io';
// import 'dart:typed_data'; // Fourni par flutter/foundation.dart
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_html/html.dart' as html;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
// import 'package:flutter/services.dart' show rootBundle; // Non utilisé car nous n'utilisons pas de polices personnalisées
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../models/product.dart';
import '../utils/number_formatter.dart';
import 'storage_service.dart';

class DataExportService {
  final StorageService _storageService = StorageService();

  // Exporter toutes les données au format CSV
  Future<String> exportToCSV() async {
    try {
      // Récupérer toutes les données
      final transactions = await _storageService.getTransactions();
      final products = await _storageService.getProducts();

      // Créer le contenu CSV pour les transactions
      final transactionsCSV = _transactionsToCSV(transactions);

      // Créer le contenu CSV pour les produits
      final productsCSV = _productsToCSV(products);

      // Créer deux fichiers CSV séparés
      final transactionsFilePath = await _saveToFile(
        transactionsCSV,
        'money_tracker_transactions.csv',
        mimeType: 'text/csv'
      );

      await _saveToFile(
        productsCSV,
        'money_tracker_products.csv',
        mimeType: 'text/csv'
      );

      // Retourner le chemin du fichier de transactions (principal)
      return transactionsFilePath;
    } catch (e) {
      rethrow;
    }
  }

  // Exporter les données au format PDF
  Future<String> exportToPDF() async {
    try {
      // Récupérer les données pour le rapport
      final transactions = await _storageService.getTransactions();
      final products = await _storageService.getProducts();
      final totalSales = await _storageService.getCurrentMonthSales();
      final totalPurchases = await _storageService.getCurrentMonthPurchases();
      final balance = await _storageService.getGlobalBalance();

      // Créer un document PDF simple
      final pdf = pw.Document();

      // Note: Nous utilisons la police par défaut de la bibliothèque PDF
      // mais nous modifions le formatage pour éviter les problèmes avec le symbole €

      // Formater la date
      final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
      final currentDate = dateFormat.format(DateTime.now());

      // Ajouter une page au document
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          header: (pw.Context context) {
            return pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('RAPPORT MONEY TRACKER', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                  pw.Text('Date: $currentDate', style: const pw.TextStyle(fontSize: 14)),
                ],
              ),
            );
          },
          build: (pw.Context context) => [
            // Résumé financier
            pw.Header(level: 1, text: 'RÉSUMÉ FINANCIER'),
            pw.SizedBox(height: 10),
            pw.Table(
              border: pw.TableBorder.all(),
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text('Catégorie', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text('Montant', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Total des ventes')),
                    pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('${NumberFormatter.roundToTwoDecimals(totalSales)} EUR')),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Total des achats')),
                    pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('${NumberFormatter.roundToTwoDecimals(totalPurchases)} EUR')),
                  ],
                ),
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text('Solde', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        '${NumberFormatter.roundToTwoDecimals(balance)} EUR',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            pw.SizedBox(height: 20),

            // Transactions
            pw.Header(level: 1, text: 'TRANSACTIONS'),
            pw.SizedBox(height: 10),
            transactions.isEmpty
                ? pw.Text('Aucune transaction')
                : pw.Table(
                    border: pw.TableBorder.all(),
                    children: [
                      // En-tête
                      pw.TableRow(
                        decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text('Date', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text('Type', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text('Description', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text('Montant', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          ),
                        ],
                      ),
                      // Lignes de données
                      ...transactions.map((t) => pw.TableRow(
                            children: [
                              pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(dateFormat.format(t.date))),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(8),
                                child: pw.Text(_getTransactionTypeLabel(t.type)),
                              ),
                              pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(t.name)),
                              pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('${NumberFormatter.roundToTwoDecimals(t.amount)} EUR')),
                            ],
                          )),
                    ],
                  ),

            pw.SizedBox(height: 20),

            // Produits en stock
            pw.Header(level: 1, text: 'PRODUITS EN STOCK'),
            pw.SizedBox(height: 10),
            products.isEmpty
                ? pw.Text('Aucun produit en stock')
                : pw.Table(
                    border: pw.TableBorder.all(),
                    children: [
                      // En-tête
                      pw.TableRow(
                        decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text('Produit', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text('Quantité', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text('Prix unitaire', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text('Valeur totale', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          ),
                        ],
                      ),
                      // Lignes de données
                      ...products.map((p) => pw.TableRow(
                            children: [
                              pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(p.name)),
                              pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('${p.quantity}')),
                              pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('${NumberFormatter.roundToTwoDecimals(p.price)} EUR')),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(8),
                                child: pw.Text('${NumberFormatter.roundToTwoDecimals(p.price * p.quantity)} EUR'),
                              ),
                            ],
                          )),
                    ],
                  ),
          ],
        ),
      );

      // Générer le PDF
      final pdfBytes = await pdf.save();

      // Sauvegarder le PDF
      if (kIsWeb) {
        // Pour le web, créer un blob et déclencher le téléchargement
        final blob = html.Blob([pdfBytes], 'application/pdf');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', 'money_tracker_report.pdf')
          ..style.display = 'none';

        html.document.body!.children.add(anchor);
        anchor.click();
        html.document.body!.children.remove(anchor);
        html.Url.revokeObjectUrl(url);

        return 'Fichier téléchargé: money_tracker_report.pdf';
      } else {
        // Pour les plateformes mobiles/desktop
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/money_tracker_report.pdf';
        final file = File(filePath);
        await file.writeAsBytes(pdfBytes);

        return filePath;
      }
    } catch (e) {
      rethrow;
    }
  }

  // Obtenir le libellé du type de transaction
  String _getTransactionTypeLabel(TransactionType type) {
    switch (type) {
      case TransactionType.sale:
        return 'Vente';
      case TransactionType.purchase:
        return 'Achat';
      case TransactionType.wallet:
        return 'Portefeuille';
      // Tous les cas sont couverts
    }
  }

  // Importer des données depuis un fichier CSV
  Future<void> importFromCSV(String csvContent) async {
    try {
      // Vérifier si le contenu est valide
      if (csvContent.isEmpty) {
        throw Exception('Le fichier CSV est vide');
      }

      // Détecter le format du CSV
      if (csvContent.startsWith('id,name,amount,date,type')) {
        // Format standard CSV pour les transactions
        final transactions = _csvToTransactions(csvContent);

        // Sauvegarder les transactions
        for (final transaction in transactions) {
          await _storageService.addTransaction(transaction);
        }
      } else if (csvContent.startsWith('id,name,quantity,price')) {
        // Format standard CSV pour les produits
        final products = _csvToProducts(csvContent);

        // Sauvegarder les produits
        for (final product in products) {
          await _storageService.addProduct(product);
        }
      } else if (csvContent.contains('TRANSACTIONS') && csvContent.contains('PRODUCTS')) {
        // Ancien format avec sections
        final sections = csvContent.split('\n\n');

        // Traiter les transactions
        if (sections.isNotEmpty && sections[0].startsWith('TRANSACTIONS')) {
          final transactionsCSV = sections[0].replaceFirst('TRANSACTIONS\n', '');
          final transactions = _csvToTransactions(transactionsCSV);

          // Sauvegarder les transactions
          for (final transaction in transactions) {
            await _storageService.addTransaction(transaction);
          }
        }

        // Traiter les produits
        if (sections.length > 1 && sections[1].startsWith('PRODUCTS')) {
          final productsCSV = sections[1].replaceFirst('PRODUCTS\n', '');
          final products = _csvToProducts(productsCSV);

          // Sauvegarder les produits
          for (final product in products) {
            await _storageService.addProduct(product);
          }
        }
      } else {
        throw Exception('Format de fichier CSV non reconnu');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Réinitialiser toutes les données
  Future<void> resetAllData() async {
    try {
      // Vider les SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Réinitialiser explicitement les listes de transactions et produits
      await _storageService.saveTransactions([]);
      await _storageService.saveProducts([]);
    } catch (e) {
      rethrow;
    }
  }

  // Convertir les transactions en CSV
  String _transactionsToCSV(List<Transaction> transactions) {
    // En-tête
    final header = 'id,name,amount,date,type,categoryId,quantity,notes';

    // Lignes de données
    final rows = transactions.map((transaction) {
      return '${transaction.id},${_escapeCSV(transaction.name)},${transaction.amount},${transaction.date.toIso8601String()},${transaction.type.toString().split('.').last},${transaction.categoryId ?? ""},${transaction.quantity ?? ""},${_escapeCSV(transaction.notes ?? "")}';
    }).join('\n');

    return '$header\n$rows';
  }

  // Convertir les produits en CSV
  String _productsToCSV(List<Product> products) {
    // En-tête
    final header = 'id,name,quantity,price,categoryId,createdAt,updatedAt';

    // Lignes de données
    final rows = products.map((product) {
      return '${product.id},${_escapeCSV(product.name)},${product.quantity},${product.price},${product.categoryId ?? ""},${product.createdAt.toIso8601String()},${product.updatedAt.toIso8601String()}';
    }).join('\n');

    return '$header\n$rows';
  }

  // Convertir le CSV en transactions
  List<Transaction> _csvToTransactions(String csv) {
    final lines = csv.split('\n');
    if (lines.length < 2) return [];

    // Ignorer l'en-tête
    final dataLines = lines.sublist(1);

    return dataLines.where((line) => line.trim().isNotEmpty).map((line) {
      final values = line.split(',');
      if (values.length < 4) return null;

      return Transaction(
        id: values[0],
        name: values[1],
        amount: double.tryParse(values[2]) ?? 0.0,
        date: DateTime.tryParse(values[3]) ?? DateTime.now(),
        type: _stringToTransactionType(values[4]),
        categoryId: values.length > 5 ? (values[5].isEmpty ? null : values[5]) : null,
        quantity: values.length > 6 ? (values[6].isEmpty ? null : int.tryParse(values[6])) : null,
        notes: values.length > 7 ? values[7] : null,
      );
    }).whereType<Transaction>().toList();
  }

  // Convertir le CSV en produits
  List<Product> _csvToProducts(String csv) {
    final lines = csv.split('\n');
    if (lines.length < 2) return [];

    // Ignorer l'en-tête
    final dataLines = lines.sublist(1);

    return dataLines.where((line) => line.trim().isNotEmpty).map((line) {
      final values = line.split(',');
      if (values.length < 4) return null;

      return Product(
        id: values[0],
        name: values[1],
        quantity: int.tryParse(values[2]) ?? 0,
        price: double.tryParse(values[3]) ?? 0.0,
        categoryId: values.length > 4 ? (values[4].isEmpty ? null : values[4]) : null,
        createdAt: values.length > 5 ? (DateTime.tryParse(values[5]) ?? DateTime.now()) : DateTime.now(),
        updatedAt: values.length > 6 ? (DateTime.tryParse(values[6]) ?? DateTime.now()) : DateTime.now(),
      );
    }).whereType<Product>().toList();
  }

  // Convertir une chaîne en type de transaction
  TransactionType _stringToTransactionType(String typeStr) {
    switch (typeStr.toLowerCase()) {
      case 'sale':
        return TransactionType.sale;
      case 'purchase':
        return TransactionType.purchase;
      case 'wallet':
        return TransactionType.wallet;
      default:
        return TransactionType.sale;
    }
  }

  // Échapper les caractères spéciaux pour le CSV
  String _escapeCSV(String text) {
    if (text.contains(',') || text.contains('"') || text.contains('\n')) {
      return '"${text.replaceAll('"', '""')}"';
    }
    return text;
  }

  // Sauvegarder le contenu dans un fichier
  Future<String> _saveToFile(String content, String fileName, {String mimeType = 'text/plain'}) async {
    if (kIsWeb) {
      try {
        // Créer un blob avec le contenu et le type MIME approprié
        final blob = html.Blob([Uint8List.fromList(utf8.encode(content))], mimeType);

        // Créer une URL pour le blob
        final url = html.Url.createObjectUrlFromBlob(blob);

        // Créer un élément d'ancrage pour le téléchargement
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', fileName)
          ..style.display = 'none';

        // Ajouter l'ancrage au document
        html.document.body!.children.add(anchor);

        // Déclencher le téléchargement
        anchor.click();

        // Nettoyer
        html.document.body!.children.remove(anchor);
        html.Url.revokeObjectUrl(url);

        return 'Fichier téléchargé: $fileName';
      } catch (e) {
        throw Exception('Erreur lors du téléchargement du fichier: $e');
      }
    } else {
      try {
        // Obtenir le répertoire de documents
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/$fileName';

        // Écrire le fichier
        final file = File(filePath);
        await file.writeAsString(content);

        return filePath;
      } catch (e) {
        rethrow;
      }
    }
  }
}
