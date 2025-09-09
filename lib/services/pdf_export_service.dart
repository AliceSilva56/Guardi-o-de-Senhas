// lib/services/pdf_export_service.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:intl/intl.dart';

class PDFExportService {
  /// Exporta backup PDF com senhas "visíveis" (box 'passwords')
  /// e senhas "confidenciais" (box 'confidential_passwords').
  static Future<void> exportBackupPDF(BuildContext context) async {

    // Carrega fontes customizadas
    final fontRegular = pw.Font.ttf(await rootBundle.load("assets/fonts/Roboto-Regular.ttf"));
    final fontBold = pw.Font.ttf(await rootBundle.load("assets/fonts/Roboto-Bold.ttf"));

    // 🔹 Define o tema global do PDF
    final theme = pw.ThemeData.withFont(
      base: fontRegular,
      bold: fontBold,
    );

    // 🔹 Cria o documento com o tema aplicado
    final pdf = pw.Document(theme: theme);

    // open boxes dinamicamente (sem tipagem) para evitar problemas de model
    final normalBox = await Hive.openBox('passwords');
    final confidentialBox = await Hive.openBox('confidential_passwords');

    final now = DateTime.now();
    final generatedAt = DateFormat('dd/MM/yyyy HH:mm').format(now);

    // Construção do documento
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context ctx) {
          final List<pw.Widget> content = [];

          content.add(
            pw.Text(
              'Backup de Senhas - Guardião de Senhas',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
          );

          content.add(pw.SizedBox(height: 8));
          content.add(
            pw.Text('Gerado em: $generatedAt', style: pw.TextStyle(fontSize: 10)),
          );
          content.add(pw.SizedBox(height: 12));

          // Aviso de confidencialidade
          content.add(
            pw.Container(
              padding: pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(width: 0.8),
                borderRadius: pw.BorderRadius.all(pw.Radius.circular(4)),
              ),
              child: pw.Text(
                '⚠️ AVISO DE CONFIDENCIALIDADE\n\n'
                'Este documento contém informações sensíveis (senhas). '
                'Mantenha-o em local seguro e não compartilhe com terceiros.',
                style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
              ),
            ),
          );

          content.add(pw.SizedBox(height: 18));

          // Seção: Senhas Visíveis
          content.add(pw.Text('SENHAS VISÍVEIS', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)));
          content.add(pw.Divider());
          if (normalBox.isEmpty) {
            content.add(pw.Text('Nenhuma senha visível encontrada.', style: pw.TextStyle(fontSize: 10, fontStyle: pw.FontStyle.italic)));
          } else {
            for (final p in normalBox.values) {
              content.add(_buildPasswordEntry(p)); // ✅ Aqui garante que cada senha apareça
            }
          }

          content.add(pw.SizedBox(height: 20));

          // Seção: Senhas Confidenciais
          content.add(pw.Text('SENHAS CONFIDENCIAIS', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)));
          content.add(pw.Divider());
          if (confidentialBox.isEmpty) {
            content.add(pw.Text('Nenhuma senha confidencial encontrada.', style: pw.TextStyle(fontSize: 10, fontStyle: pw.FontStyle.italic)));
          } else {
            for (final p in confidentialBox.values) {
              content.add(_buildPasswordEntry(p)); // ✅ Aqui também
            }
          }

          content.add(pw.SizedBox(height: 18));

          // Resumo final (contagem)
          content.add(pw.Divider());
          content.add(
            pw.Text(
              'Resumo: ${normalBox.length} senhas visíveis • ${confidentialBox.length} senhas confidenciais',
              style: pw.TextStyle(fontSize: 10),
            ),
          );

          return content;
        },
      ),
    );

    // Salvar arquivo com timestamp no nome
    try {
      final dir = await getApplicationDocumentsDirectory();
      final ts = _formatForFilename(now);
      final fileName = 'backup_guardiao_$ts.pdf';
      final file = File('${dir.path}/$fileName');

      await file.writeAsBytes(await pdf.save());

      // Tenta abrir
      await OpenFile.open(file.path);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Backup exportado em: ${file.path}')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao gerar PDF: $e')),
        );
      }
    }
  }

  // ---------- Helpers ----------

  static String _twoDigits(int n) => n.toString().padLeft(2, '0');

  static String _formatForFilename(DateTime d) =>
      '${d.year}-${_twoDigits(d.month)}-${_twoDigits(d.day)}_${_twoDigits(d.hour)}-${_twoDigits(d.minute)}-${_twoDigits(d.second)}';

  static pw.Widget _buildPasswordEntry(dynamic p) {
    final title = _firstNonNullString(p, [
      (x) => x['title'],
      (x) => x['name'],
      (x) => x['site'],
      (x) => x['service'],
      (x) => (x as dynamic).title,
      (x) => (x as dynamic).name,
      (x) => (x as dynamic).site,
      (x) => (x as dynamic).service,
    ]);

    final username = _firstNonNullString(p, [
      (x) => x['username'],
      (x) => x['user'],
      (x) => x['email'],
      (x) => x['login'],
      (x) => (x as dynamic).username,
      (x) => (x as dynamic).user,
      (x) => (x as dynamic).email,
      (x) => (x as dynamic).login,
    ]);

    final pass = _firstNonNullString(p, [
      (x) => x['password'],
      (x) => x['pwd'],
      (x) => x['pass'],
      (x) => (x as dynamic).password,
      (x) => (x as dynamic).pwd,
      (x) => (x as dynamic).pass,
    ]);

    final category = _firstNonNullString(p, [
      (x) => x['category'],
      (x) => x['folder'],
      (x) => x['group'],
      (x) => (x as dynamic).category,
      (x) => (x as dynamic).folder,
      (x) => (x as dynamic).group,
    ]);

    final notes = _firstNonNullString(p, [
      (x) => x['notes'],
      (x) => x['note'],
      (x) => x['description'],
      (x) => (x as dynamic).notes,
      (x) => (x as dynamic).note,
      (x) => (x as dynamic).description,
    ]);

    final displayTitle = title ?? 'Sem título';
    final displayUsername = username ?? '—';
    final displayPass = pass ?? '—';
    final displayCategory = category ?? 'Sem Categoria';

    final children = <pw.Widget>[
      pw.Text('Site/Serviço: $displayTitle', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
      pw.SizedBox(height: 2),
      pw.Text('Usuário/Email: $displayUsername', style: pw.TextStyle(fontSize: 10)),
      pw.SizedBox(height: 2),
      pw.Text('Senha: $displayPass', style: pw.TextStyle(fontSize: 10)),
      pw.SizedBox(height: 2),
      pw.Text('Categoria: $displayCategory', style: pw.TextStyle(fontSize: 10)),
    ];

    if (notes != null && notes.trim().isNotEmpty) {
      children.add(pw.SizedBox(height: 2));
      children.add(pw.Text('Notas: ${notes.trim()}', style: pw.TextStyle(fontSize: 10)));
    }

    children.add(pw.SizedBox(height: 6));
    children.add(pw.Divider());

    return pw.Padding(
      padding: pw.EdgeInsets.symmetric(vertical: 6),
      child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: children),
    );
  }

  static String? _firstNonNullString(dynamic p, List<Function> accessors) {
    for (final accessor in accessors) {
      try {
        final val = accessor(p);
        if (val == null) continue;
        final s = val.toString();
        if (s.trim().isNotEmpty) return s;
      } catch (_) {}
    }

    try {
      final toJson = (p as dynamic).toJson;
      if (toJson is Function) {
        final map = toJson();
        if (map is Map) {
          for (final k in ['title','name','site','service','username','email','password','category','notes']) {
            if (map.containsKey(k) && map[k] != null && map[k].toString().trim().isNotEmpty) {
              return map[k].toString();
            }
          }
        }
      }
    } catch (_) {}

    return null;
  }
  // ============================================================
  // Métodos extras para integração com settings_screen.dart
  // ============================================================

  /// Verifica se existem senhas (visíveis ou confidenciais) para exportar
  static Future<bool> hasPasswordsToExport() async {
    final normalBox = await Hive.openBox('passwords');
    final confidentialBox = await Hive.openBox('confidential_passwords');
    return normalBox.isNotEmpty || confidentialBox.isNotEmpty;
  }

  /// Exporta apenas as senhas de um tipo (normal/confidencial)
  static Future<File> exportPasswordsToPDF({required bool isConfidential}) async {
    final pdf = pw.Document();
    final now = DateTime.now();
    final generatedAt = DateFormat('dd/MM/yyyy HH:mm').format(now);

    final box = await Hive.openBox(
        isConfidential ? 'confidential_passwords' : 'passwords');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (ctx) => [
          pw.Text(
            'Backup ${isConfidential ? "Confidencial" : "Normal"}',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.Text('Gerado em: $generatedAt', style: pw.TextStyle(fontSize: 10)),
          pw.SizedBox(height: 12),
          if (box.isEmpty)
            pw.Text('Nenhuma senha encontrada',
                style: pw.TextStyle(fontSize: 10, fontStyle: pw.FontStyle.italic))
          else
            ...box.values.map((p) => _buildPasswordEntry(p)),
        ],
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final ts = _formatForFilename(now);
    final file = File('${dir.path}/backup_${isConfidential ? "confidencial" : "normal"}_$ts.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  /// Abre o PDF com o aplicativo padrão do dispositivo
  static Future<void> openPDF(File file) async {
    await OpenFile.open(file.path);
  }
}
