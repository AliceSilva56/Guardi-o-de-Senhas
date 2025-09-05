import 'dart:io';
import 'package:guardiao_de_senhas/theme/app_colors.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:path/path.dart' as path;
import 'package:intl/intl.dart';
import 'package:hive/hive.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/app_pdf_colors.dart';

class PDFExportService {
  // Exporta todas as senhas para um PDF
  static Future<File> exportPasswordsToPDF({bool isConfidential = false}) async {
    try {
      final pdf = pw.Document();
      final now = DateTime.now();
      final formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(now);
      
      // Carrega as senhas do Hive
      final passwordsBox = await Hive.openBox('passwords');
      final List<Map<String, dynamic>> passwords = [];
      
      // Converte cada senha para um Map
      for (var key in passwordsBox.keys) {
        try {
          final passwordData = passwordsBox.get(key);
          if (passwordData is Map) {
            passwords.add(Map<String, dynamic>.from(passwordData));
          }
        } catch (e) {
          print('Erro ao processar senha: $e');
        }
      }
      
      // Agrupa senhas por categoria
      final Map<String, List<Map<String, dynamic>>> passwordsByCategory = {};
      for (var password in passwords) {
        final category = password['category'] ?? 'Sem Categoria';
        if (!passwordsByCategory.containsKey(category)) {
          passwordsByCategory[category] = [];
        }
        passwordsByCategory[category]!.add(password);
      }
      
      // Cria o documento PDF
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4.copyWith(
            marginTop: 1.0 * PdfPageFormat.cm,
            marginLeft: 1.0 * PdfPageFormat.cm,
            marginRight: 1.0 * PdfPageFormat.cm,
            marginBottom: 1.0 * PdfPageFormat.cm,
          ),
          build: (context) {
            final List<pw.Widget> widgets = [];
            
            // Cabeçalho
            widgets.add(
              pw.Header(
                level: 0,
                child: pw.Text(
                  isConfidential 
                    ? 'Backup Confidencial de Senhas' 
                    : 'Backup de Senhas',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            );
            
            widgets.add(pw.SizedBox(height: 10));
            widgets.add(
              pw.Text('Gerado em: $formattedDate'),
            );
            widgets.add(pw.Divider());
            widgets.add(pw.SizedBox(height: 20));
            
            // Adiciona aviso de confidencialidade se for o caso
            if (isConfidential) {
              widgets.add(
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    color: AppPdfColors.red50,
                    border: pw.Border.all(color: AppPdfColors.red300, width: 1),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
                  ),
                  child: pw.Text(
                    'CONFIDENCIAL - Este documento contém informações sensíveis. Mantenha-o em local seguro.',
                    style: pw.TextStyle(
                      color: AppPdfColors.red900,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              );
              widgets.add(pw.SizedBox(height: 20));
            }
            
            // Adiciona senhas por categoria
            for (var category in passwordsByCategory.keys) {
              // Título da categoria
              widgets.add(
                pw.Header(
                  level: 1,
                  child: pw.Text(
                    category,
                    style: const pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              );
              
              // Tabela de senhas
              final tableHeaders = [
                'Site/Serviço',
                'Usuário/E-mail',
                'Senha',
                'Notas',
              ];
              
              final tableData = <List<pw.Widget>>[];
              
              // Adiciona linhas da tabela
              for (var password in passwordsByCategory[category]!) {
                tableData.add([
                  pw.Text(password['title'] ?? 'Sem título'),
                  pw.Text(password['username'] ?? 'Sem usuário'),
                  pw.Text(
                    isConfidential 
                      ? password['password'] ?? '' 
                      : '••••••••',
                    style: isConfidential 
                      ? null 
                      : pw.TextStyle(fontStyle: pw.FontStyle.italic),
                  ),
                  pw.Text(
                    password['notes']?.toString().replaceAll('\n', ' ') ?? '',
                    maxLines: 2,
                    overflow: pw.TextOverflow.ellipsis,
                  ),
                ]);
              }
              
              // Cria a tabela
              widgets.add(
                pw.TableHelper.fromTextArray(
                  headers: tableHeaders,
                  data: tableData,
                  border: null,
                  headerStyle: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    color: AppPdfColors.white,
                  ),
                  headerDecoration: const pw.BoxDecoration(
                    color: AppPdfColors.blue700,
                  ),
                  rowDecoration: const pw.BoxDecoration(
                    border: pw.Border(
                      bottom: pw.BorderSide(
                        color: AppPdfColors.grey300,
                        width: 0.5,
                      ),
                    ),
                  ),
                  cellAlignment: pw.Alignment.centerLeft,
                  cellPadding: const pw.EdgeInsets.all(6),
                  cellStyle: const pw.TextStyle(fontSize: 10),
                  headerPadding: const pw.EdgeInsets.all(8),
                ),
              );
              
              widgets.add(pw.SizedBox(height: 20));
            }
            
            // Rodapé
            widgets.add(
              pw.Container(
                alignment: pw.Alignment.center,
                margin: const pw.EdgeInsets.only(top: 20),
                child: pw.Text(
                  'Gerado por Guardião de Senhas • ${now.year}',
                  style: pw.TextStyle(
                    fontSize: 10,
                    color: AppPdfColors.grey600,
                  ),
                ),
              ),
            );
            
            return widgets;
          },
        ),
      );
      
      // Salva o PDF
      final output = await getTemporaryDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(now);
      final fileName = isConfidential 
          ? 'backup_confidencial_$timestamp.pdf' 
          : 'backup_senhas_$timestamp.pdf';
      
      final file = File('${output.path}/$fileName');
      await file.writeAsBytes(await pdf.save());
      
      return file;
    } catch (e) {
      print('Erro ao gerar PDF: $e');
      rethrow;
    }
  }
  
  // Verifica se existem senhas para exportar
  static Future<bool> hasPasswordsToExport() async {
    try {
      final passwordsBox = await Hive.openBox('passwords');
      return passwordsBox.isNotEmpty;
    } catch (e) {
      debugPrint('Erro ao verificar senhas: $e');
      return false;
    }
  }

  // Abre o visualizador de PDF
  static Future<void> openPDF(File file) async {
    try {
      // Tenta abrir com o visualizador nativo primeiro
      final result = await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => file.readAsBytes(),
        name: 'Backup_Senhas_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
      
      // Se não conseguir abrir com o visualizador nativo, tenta abrir com o visualizador padrão do dispositivo
      if (result == false) {
        if (await file.exists()) {
          if (await canLaunchUrl(Uri.file(file.path))) {
            await launchUrl(Uri.file(file.path));
          } else {
            throw Exception('Não foi possível encontrar um visualizador de PDF no dispositivo');
          }
        } else {
          throw Exception('O arquivo PDF não foi encontrado');
        }
      }
    } catch (e) {
      debugPrint('Erro ao abrir visualizador de PDF: $e');
      rethrow;
    }
  }
}
