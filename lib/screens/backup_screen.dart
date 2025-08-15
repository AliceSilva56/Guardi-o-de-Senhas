//Archivo backup_screen.dart para Backup e Restauração do Guardião de Senhas
// Este arquivo implementa a funcionalidade de backup e restauração de senhas, permitindo exportar e importar dados de senhas em formato JSON.

import 'package:flutter/material.dart';
import '../services/password_service.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  String backupData = '';

  void exportBackup() {
    setState(() {
      backupData = PasswordService.exportBackup();
    });
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Backup Gerado'),
        content: SingleChildScrollView(
          child: SelectableText(backupData),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fechar')),
        ],
      ),
    );
  }

  void importBackupDialog() {
    final controller = TextEditingController();
    bool overwrite = false;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Importar Backup'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: controller,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: 'Cole o backup aqui',
                  border: OutlineInputBorder(),
                ),
              ),
              Row(
                children: [
                  Checkbox(
                    value: overwrite,
                    onChanged: (val) {
                      overwrite = val ?? false;
                    },
                  ),
                  const Text('Sobrescrever dados existentes'),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              await PasswordService.importBackup(controller.text, overwrite: overwrite);
              Navigator.pop(context);
            },
            child: const Text('Importar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Backup & Restauração')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            ElevatedButton.icon(
              onPressed: exportBackup,
              icon: const Icon(Icons.download),
              label: const Text('Exportar Backup'),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: importBackupDialog,
              icon: const Icon(Icons.upload),
              label: const Text('Importar Backup'),
            ),
          ],
        ),
      ),
    );
  }
}
