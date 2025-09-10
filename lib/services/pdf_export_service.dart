// lib/services/pdf_export_service.dart
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:intl/intl.dart';
import 'password_service.dart';
import 'settings_service.dart';
import '../models/password_model.dart';

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

    final now = DateTime.now();
    
    // Obtém as senhas usando o PasswordService
    final normalPasswords = PasswordService.getAllPasswords(includeConfidential: false);
    final confidentialPasswords = PasswordService.getAllPasswords(includeConfidential: true)
        .where((p) => p.confidential)
        .toList();
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
                '[!] AVISO DE CONFIDENCIALIDADE\n\n'
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
          if (normalPasswords.isEmpty) {
            content.add(pw.Text('Nenhuma senha visível encontrada.', style: pw.TextStyle(fontSize: 10, fontStyle: pw.FontStyle.italic)));
          } else {
            for (final p in normalPasswords) {
              content.add(_buildPasswordEntry(p.toMap()));
            }
          }

          content.add(pw.SizedBox(height: 20));

          // Seção: Senhas Confidenciais
          content.add(pw.Text('SENHAS CONFIDENCIAIS', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)));
          content.add(pw.Divider());
          if (confidentialPasswords.isEmpty) {
            content.add(pw.Text('Nenhuma senha confidencial encontrada.', style: pw.TextStyle(fontSize: 10, fontStyle: pw.FontStyle.italic)));
          } else {
            for (final p in confidentialPasswords) {
              content.add(_buildPasswordEntry(p.toMap()));
            }
          }

          content.add(pw.SizedBox(height: 18));

          // Resumo final (contagem)
          content.add(pw.Divider());
          content.add(
            pw.Text(
              'Resumo: ${normalPasswords.length} senhas visíveis • ${confidentialPasswords.length} senhas confidenciais',
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

      // Salva o timestamp do backup
      await SettingsService.setLastBackupTimestamp();

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

  static pw.Widget _buildPasswordEntry(Map<String, dynamic> p) {
    // Função auxiliar para obter valor de forma segura
    String getValue(String key) {
      try {
        return p[key]?.toString() ?? '';
      } catch (e) {
        return '';
      }
    }

    // Obtém os valores diretamente do mapa
    final title = getValue('siteName').isNotEmpty 
        ? getValue('siteName')
        : getValue('title').isNotEmpty 
            ? getValue('title')
            : getValue('name').isNotEmpty
                ? getValue('name')
                : 'Sem título';

    final username = getValue('username').isNotEmpty
        ? getValue('username')
        : getValue('user').isNotEmpty
            ? getValue('user')
            : getValue('email').isNotEmpty
                ? getValue('email')
                : getValue('login').isNotEmpty
                    ? getValue('login')
                    : 'Não informado';

    // Mostra a senha real no PDF
    final password = getValue('password');
    
    final category = getValue('category').isNotEmpty
        ? getValue('category')
        : getValue('folder').isNotEmpty
            ? getValue('folder')
            : getValue('group').isNotEmpty
                ? getValue('group')
                : 'Geral';

    final notes = getValue('notes').isNotEmpty
        ? getValue('notes')
        : getValue('note').isNotEmpty
            ? getValue('note')
            : getValue('description').isNotEmpty
                ? getValue('description')
                : '';

    return pw.Container(
      margin: pw.EdgeInsets.only(bottom: 12),
      padding: pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(width: 0.5),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4),
          pw.Text('Usuário: $username', style: pw.TextStyle(fontSize: 10)),
          pw.Text('Senha: $password', style: pw.TextStyle(fontSize: 10)),
          if (category.isNotEmpty) 
            pw.Text('Categoria: $category', style: pw.TextStyle(fontSize: 10)),
          if (notes.isNotEmpty) ...[
            pw.SizedBox(height: 4),
            pw.Text('Notas: $notes', style: pw.TextStyle(fontSize: 9, fontStyle: pw.FontStyle.italic)),
          ],
        ],
      ),
    );
  }

  static String? _firstNonNullString(dynamic p, List<Function> accessors) {
    for (var accessor in accessors) {
      try {
        final value = accessor(p);
        if (value != null && value.toString().isNotEmpty) {
          return value.toString();
        }
      } catch (_) {}
    }
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
    try {
      await OpenFile.open(file.path);
    } catch (e) {
      debugPrint('Erro ao abrir o PDF: $e');
      rethrow;
    }
  }

  /// Exporta um arquivo de backup no formato .gbackup que pode ser importado posteriormente
  static Future<File> exportBackupFile({bool isConfidential = false}) async {
    try {
      // Obtém o diretório de documentos do aplicativo
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = 'backup_${isConfidential ? 'confidencial_' : ''}$timestamp.gbackup';
      final file = File('${directory.path}/$fileName');

      // Obtém as senhas
      final passwords = PasswordService.getAllPasswords(includeConfidential: isConfidential);
      
      // Obtém as configurações
      final settingsBox = await Hive.openBox('settings');
      final settings = {
        'theme': settingsBox.get('theme_mode', defaultValue: 'system'),
        'biometry': settingsBox.get('biometry_enabled', defaultValue: false),
      };
      
      // Obtém o perfil do usuário
      final profileBox = await Hive.openBox('profile');
      final profile = {
        'name': profileBox.get('name', defaultValue: ''),
        'email': profileBox.get('email', defaultValue: ''),
        'avatar': profileBox.get('avatar', defaultValue: ''),
      };

      // Prepara os dados para exportação
      final Map<String, dynamic> backupData = {
        'version': 1,
        'exportedAt': DateTime.now().toIso8601String(),
        'isConfidential': isConfidential,
        'settings': settings,
        'profile': profile,
        'passwords': passwords.map((p) => p.toMap()).toList(),
      };

      // Converte para JSON e salva o arquivo
      final jsonData = jsonEncode(backupData);
      await file.writeAsString(jsonData);
      
      // Salva o timestamp do último backup
      await SettingsService.setLastBackupTimestamp();
      
      return file;
    } catch (e) {
      debugPrint('Erro ao exportar backup: $e');
      rethrow;
    }
  }

  /// Extrai senhas de um arquivo PDF gerado pelo aplicativo
  static Future<List<PasswordModel>> extractPasswordsFromPDF(File pdfFile) async {
    try {
      final List<PasswordModel> passwords = [];
      
      debugPrint('🔄 Iniciando extração de senhas do arquivo: ${pdfFile.path}');
      
      // Verifica se o arquivo existe e tem conteúdo
      if (!await pdfFile.exists()) {
        debugPrint('❌ Erro: O arquivo não existe: ${pdfFile.path}');
        throw Exception('O arquivo não existe: ${pdfFile.path}');
      }
      
      final fileSize = await pdfFile.length();
      debugPrint('📄 Tamanho do arquivo: $fileSize bytes');
      
      if (fileSize == 0) {
        debugPrint('⚠️ Aviso: O arquivo está vazio');
        return [];
      }
      
      // Lê o conteúdo do PDF como texto
      debugPrint('🔍 Executando pdftotext no arquivo...');
      
      // Usa parâmetros adicionais para melhor extração de texto
      final process = await Process.run('pdftotext', [
        '-layout',  // Mantém o layout original
        '-eol', 'unix',  // Usa quebras de linha Unix
        '-enc', 'UTF-8',  // Codificação UTF-8
        pdfFile.path,  // Arquivo de entrada
        '-'  // Saída para stdout
      ]);
      
      if (process.exitCode != 0) {
        debugPrint('❌ Erro ao executar pdftotext. Código: ${process.exitCode}');
        debugPrint('📝 Saída de erro: ${process.stderr}');
        throw Exception('Falha ao ler o PDF: ${process.stderr}');
      }
      
      String pdfText = process.stdout.toString().trim();
      debugPrint('📝 Conteúdo bruto do PDF (${pdfText.length} caracteres)');
      
      // Log apenas do início e fim do conteúdo para não poluir os logs
      if (pdfText.isNotEmpty) {
        final sampleSize = 200;
        final start = pdfText.length > sampleSize 
            ? pdfText.substring(0, sampleSize) 
            : pdfText;
        final end = pdfText.length > sampleSize * 2 
            ? pdfText.substring(pdfText.length - sampleSize) 
            : '';
            
        debugPrint('--- INÍCIO DO CONTEÚDO (amostra) ---');
        debugPrint(start);
        if (end.isNotEmpty) {
          debugPrint('... [${pdfText.length - (sampleSize * 2)} caracteres omitidos] ...');
          debugPrint(end);
        }
        debugPrint('--- FIM DO CONTEÚDO ---');
      } else {
        debugPrint('⚠️ AVISO: O conteúdo extraído do PDF está vazio!');
        return [];
      }
      
      if (pdfText.isEmpty) {
        debugPrint('AVISO: O conteúdo extraído do PDF está vazio!');
        return [];
      }
      
      // Normaliza quebras de linha
      pdfText = pdfText.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
      
      // Padrão flexível para identificar entradas de senha
      final patterns = [
        // Padrão 1: Formato estruturado com rótulos
        RegExp(
          r'(?:Site|Aplicativo|App)[:/]?\s*([^\n]+?)\s*'  // Site/App
          r'(?:Usu[áa]rio(?:/|:)Email|Login|Email|Usu[áa]rio)[:/]?\s*([^\n]*?)\s*'  // Usuário/Email
          r'Senha[:/]?\s*([^\n]*?)\s*'  // Senha
          r'(?:Categoria[:/]?\s*([^\n]*?))?\s*'  // Categoria (opcional)
          r'(?=\n\S|\n\s*\n|\Z)',  // Lookahead para o próximo item ou fim
          caseSensitive: false,
          dotAll: true,
        ),
        // Padrão 2: Formato tabular
        RegExp(
          r'([^\n:]+?)[:/]?\s*([^\n]*?)\s*'  // Site/App
          r'([^\n:]+?)[:/]?\s*([^\n]*?)\s*'  // Usuário/Email
          r'([^\n:]+?)[:/]?\s*([^\n]*?)\s*'  // Senha
          r'(?:([^\n:]+?)[:/]?\s*([^\n]*?))?\s*',  // Categoria (opcional)
          caseSensitive: false,
          dotAll: true,
        )
      ];
      
      // Tenta cada padrão até encontrar correspondências
      for (final pattern in patterns) {
        debugPrint('🔍 Tentando padrão: ${pattern.pattern}');
        final matches = pattern.allMatches(pdfText);
        
        if (matches.isNotEmpty) {
          debugPrint('✅ Encontradas ${matches.length} correspondências com o padrão');
          
          for (final match in matches) {
            try {
              String siteName, username, password, category;
              
              // Determina os grupos de captura com base no padrão
              if (pattern == patterns[0]) {
                // Padrão estruturado com rótulos
                siteName = (match.group(1) ?? '').trim();
                username = (match.group(2) ?? '').trim();
                password = (match.group(3) ?? '').trim();
                category = (match.group(4) ?? 'Geral').trim();
              } else {
                // Padrão tabular
                siteName = (match.group(2) ?? '').trim();
                username = (match.group(4) ?? '').trim();
                password = (match.group(6) ?? '').trim();
                category = (match.group(8) ?? 'Geral').trim();
              }
              
              // Só adiciona se tiver pelo menos site/app e senha
              if (siteName.isNotEmpty && password.isNotEmpty) {
                debugPrint('🔑 Processando senha: $siteName - $username - $category');
                
                final passwordModel = PasswordModel(
                  id: 'pdf_${DateTime.now().millisecondsSinceEpoch}_${passwords.length}',
                  siteName: siteName,
                  username: username,
                  password: password,
                  category: category,
                  notes: 'Importado do PDF em ${DateTime.now().toIso8601String()}',
                  createdAt: DateTime.now(),
                  lastModified: DateTime.now(),
                  confidential: false,
                  isConfidential: false,
                );
                
                // Verifica se já existe uma senha idêntica
                final exists = passwords.any((p) => 
                  p.siteName == passwordModel.siteName &&
                  p.username == passwordModel.username &&
                  p.password == passwordModel.password &&
                  p.category == passwordModel.category
                );
                
                if (!exists) {
                  passwords.add(passwordModel);
                } else {
                  debugPrint('ℹ️ Senha duplicada ignorada: $siteName - $username');
                }
              }
            } catch (e) {
              debugPrint('⚠️ Erro ao processar entrada de senha: $e');
            }
          }
          
          // Se encontrou senhas com este padrão, não tenta os outros
          if (passwords.isNotEmpty) {
            debugPrint('✅ ${passwords.length} senhas importadas com sucesso');
            break;
          }
        } else {
          debugPrint('ℹ️ Nenhuma correspondência encontrada com este padrão');
        }
      }
      
      if (passwords.isEmpty) {
        debugPrint('⚠️ AVISO: Nenhuma senha foi encontrada no PDF. Verifique se o formato do PDF é compatível.');
        debugPrint('📝 Dica: O PDF deve conter as senhas em um formato estruturado com os campos:');
        debugPrint('       Site/App: [nome]');
        debugPrint('       Usuário/Email: [usuário]');
        debugPrint('       Senha: [senha]');
        debugPrint('       Categoria: [categoria]');
      } else {
        debugPrint('✅ ${passwords.length} senhas extraídas com sucesso do PDF');
      }
      
      return passwords;
    } catch (e, stackTrace) {
      debugPrint('❌ ERRO CRÍTICO ao extrair senhas do PDF:');
      debugPrint('🔍 Mensagem: $e');
      debugPrint('📝 Stack trace: $stackTrace');
      debugPrint('💡 Dica: Verifique se o arquivo PDF não está corrompido e se contém senhas no formato esperado.');
      rethrow;
    }
  }
}
