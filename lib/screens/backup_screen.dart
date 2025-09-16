//Arquivo backup_screen.dart para Backup e Restauração do Guardião de Senhas
// Este arquivo implementa a funcionalidade de backup e restauração de senhas, permitindo exportar e importar dados de senhas em formato JSON.

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../services/password_service.dart';
import '../services/settings_service.dart';
import '../theme/app_colors.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  List<FileSystemEntity> backupFiles = [];
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadBackupFiles();
  }

  Future<void> _loadBackupFiles() async {
    if (!mounted) return;
    
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final files = await SettingsService.listBackupFiles();
      if (!mounted) return;
      
      setState(() {
        backupFiles = files;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = 'Erro ao carregar backups: $e';
      });
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> createBackup() async {
    if (!mounted) return;
    
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final backupFile = await SettingsService.createBackup();
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Backup criado com sucesso!\n${backupFile.path}'),
          backgroundColor: Colors.green,
        ),
      );
      
      await _loadBackupFiles();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = 'Erro ao criar backup: $e';
      });
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> restoreBackup(File backupFile) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restaurar Backup'),
        content: Text('Tem certeza que deseja restaurar o backup?\n${backupFile.path}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Restaurar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    if (!mounted) return;
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final success = await SettingsService.restoreBackup(backupFile);
      if (!mounted) return;
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Backup restaurado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Falha ao restaurar backup');
      }
      
      await _loadBackupFiles();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = 'Erro ao restaurar backup: $e';
      });
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> deleteBackup(FileSystemEntity file) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Backup'),
        content: const Text('Tem certeza que deseja excluir este backup?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await file.delete();
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Backup excluído com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
      
      await _loadBackupFiles();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = 'Erro ao excluir backup: $e';
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final secondaryTextColor = isDark ? Colors.white70 : Colors.black54;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Backup & Restauração'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadBackupFiles,
            tooltip: 'Atualizar lista',
          ),
        ],
      ),
      body: Column(
        children: [
          // Botão de criar novo backup
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: isLoading ? null : createBackup,
              icon: const Icon(Icons.backup),
              label: const Text('Criar Novo Backup'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ),
          
          // Mensagem de erro, se houver
          if (errorMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                errorMessage!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
          
          // Título da seção de backups
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Text(
                  'Backups Locais',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // Lista de backups
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : backupFiles.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.folder_off,
                              size: 64,
                              color: secondaryTextColor,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Nenhum backup local encontrado',
                              style: TextStyle(color: secondaryTextColor),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: backupFiles.length,
                        itemBuilder: (context, index) {
                          final file = backupFiles[index];
                          final fileName = file.path.split(Platform.pathSeparator).last;
                          final fileDate = File(file.path).lastModifiedSync();
                          final fileSize = (File(file.path).lengthSync() / 1024).toStringAsFixed(2);

                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            child: ListTile(
                              leading: const Icon(Icons.backup),
                              title: Text(
                                fileName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                '${fileDate.toString().substring(0, 16)} • $fileSize KB',
                                style: TextStyle(color: secondaryTextColor),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.restore, color: Colors.green),
                                    onPressed: () => restoreBackup(File(file.path)),
                                    tooltip: 'Restaurar este backup',
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => deleteBackup(file),
                                    tooltip: 'Excluir este backup',
                                  ),
                                ],
                              ),
                              onTap: () => restoreBackup(File(file.path)),
                            ),
                          );
                        },
                      ),
          ),
          ],
        ),
      );
  }
}
