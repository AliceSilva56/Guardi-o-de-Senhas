//Arquivo settings_screen para Configurações do Guardião de Senhas
// Este arquivo contém as configurações do aplicativo, incluindo opções de segurança, personalização e dados
//Arquivo settings_screen.dart para Configurações do Guardião de Senhas

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive/hive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import '../services/settings_service.dart';
import '../services/pdf_export_service.dart';
import '../services/password_service.dart';
import '../main.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  // ======================= MÉTODOS DE EXPORTAÇÃO ========================
  Future<void> _exportBackup(BuildContext context, {required bool isConfidential}) async {
    final hasPasswords = await PDFExportService.hasPasswordsToExport();
    if (!hasPasswords) {
      if (context.mounted) {
        await showDialog(
          context: context,
          builder: (context) => const AlertDialog(
            title: Text('Nenhuma senha encontrada'),
            content: Text('Não há senhas para exportar.'),
            actions: [
              TextButton(
                onPressed: null,
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
      return;
    }

    if (isConfidential) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Atenção'),
          content: const Text(
            'O backup confidencial irá incluir todas as suas senhas em texto legível. '
            'Certifique-se de armazenar este arquivo em um local seguro.\n\n'
            'Deseja continuar?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Continuar'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final file = await PDFExportService.exportPasswordsToPDF(
        isConfidential: isConfidential,
      );

      if (context.mounted) {
        Navigator.of(context).pop();
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Backup ${isConfidential ? 'Confidencial ' : ''}Concluído'),
            content: Text(
              'O backup foi salvo em:\n${file.path}',
              style: const TextStyle(fontSize: 14),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fechar'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  PDFExportService.openPDF(file);
                },
                child: const Text('Abrir PDF'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao gerar backup: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ======================= BUILD ========================
  @override
  Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: const Text('Configurações')),
    body: ListView(
      children: [
        // Informações Básicas
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('Informações Básicas',
              style: Theme.of(context).textTheme.titleMedium),
        ),
        // Opção de Perfil
        ListTile(
          leading: const Icon(Icons.person),
          title: const Text('Perfil'),
          subtitle: const Text('Avatar, Nome, e-mail'),
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const ProfileScreen())),
        ),
        const Divider(),

        // Opções de Segurança
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('Opções de Segurança',
              style: Theme.of(context).textTheme.titleMedium),
        ),
        ListTile(
          leading: const Icon(Icons.lock),
          title: const Text('Senha mestra'),
          subtitle: const Text('Protege o acesso ao app'),
          onTap: () => _configureMasterPassword(context),
        ),
        ListTile(
          leading: const Icon(Icons.lock_outline),
          title: const Text('Senha do modo confidencial'),
          subtitle: const Text('Desbloqueia apenas conteúdo confidencial'),
          onTap: () => _configureConfidentialPassword(context),
        ),
        ListTile(
          leading: const Icon(Icons.fingerprint),
          title: const Text('Autenticação biométrica'),
          subtitle: const Text('Impressão digital ou reconhecimento facial'),
          onTap: () async {
            bool atual = await SettingsService.getBiometryEnabled();
            await SettingsService.setBiometryEnabled(!atual);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content:
                      Text('Biometria ${!atual ? "ativada" : "desativada"}')),
            );
          }, // implementar biometria
        ),
        const Divider(),

        // Personalização
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('Personalização',
              style: Theme.of(context).textTheme.titleMedium),
        ),
        ListTile(
          leading: const Icon(Icons.color_lens),
          title: const Text('Tema do aplicativo'),
          subtitle: const Text('Claro, escuro ou sistema'),
          onTap: () => _showThemeDialog(context),
        ),
        const Divider(),

        // Dados e Backup
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('Dados e Backup',
              style: Theme.of(context).textTheme.titleMedium),
        ),
        ListTile(
          leading: const Icon(Icons.picture_as_pdf),
          title: const Text('Exportar Backup em PDF'),
          subtitle: const Text(
              'Exporta todas as senhas (visíveis e confidenciais)'),
          onTap: () => PDFExportService.exportBackupPDF(context),
        ),
        ListTile(
          leading: const Icon(Icons.history),
          title: const Text('Último backup realizado'),
          subtitle: FutureBuilder<Widget>(
            future: _getLastBackupInfo(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Row(
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 8),
                    Text('Carregando...'),
                  ],
                );
              }
              if (snapshot.hasError) {
                return const Text(
                  'Erro ao carregar informações de backup',
                  style: TextStyle(color: Colors.red),
                );
              }
              return snapshot.data ?? const Text('Nenhum backup encontrado');
            },
          ),
          isThreeLine: true,
        ),
        ListTile(
          leading: const Icon(Icons.restore),
          title: const Text('Importar backup'),
          subtitle: const Text('Restaurar dados salvos'),
          onTap: () => _importBackup(context),
        ),
        const Divider(),

        // Conta
        Padding(
          padding: const EdgeInsets.all(16.0),
          child:
              Text('Conta', style: Theme.of(context).textTheme.titleMedium),
        ),
        ListTile(
          leading: const Icon(Icons.delete_forever, color: Colors.red),
          title: const Text('Excluir minha conta',
              style: TextStyle(color: Colors.red)),
          subtitle:
              const Text('Remove permanentemente todos os seus dados'),
          onTap: () => _showDeleteAccountConfirmation(context),
        ),
      ],
    ),
  );
}


  // ======================= DIALOGS ========================
  // Exibe um diálogo de erro
  void _showErrorDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Text(
            message,
            style: const TextStyle(fontSize: 14),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // ======================= TEMA ========================
  void _showThemeDialog(BuildContext context) {
    final themeOptions = [
      'Claro',
      'Escuro',
      'Sistema'
    ];
    
    final themeController = Provider.of<ThemeController>(context, listen: false);
    String currentTheme = themeController.themeModeName;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Escolher tema'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: themeOptions.map((option) {
                  return RadioListTile<String>(
                    title: Text(option),
                    value: option,
                    groupValue: currentTheme,
                    onChanged: (String? val) async {
                      if (val != null) {
                        await themeController.setThemeMode(val);
                        setState(() {
                          currentTheme = val;
                        });
                      }
                    },
                  );
                }).toList(),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Fechar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ======================= SENHA ========================
  // Mostra diálogo de confirmação para exclusão de conta
  Future<void> _showDeleteAccountConfirmation(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Conta'),
        content: const Text(
          'Tem certeza que deseja excluir sua conta? \nTodos os seus dados serão removidos permanentemente após 30 dias.\n\nVocê pode cancelar a exclusão a qualquer momento antes deste prazo fazendo login novamente.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir Conta'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _confirmDeleteAccount(context);
    }
  }

  // Confirma a exclusão da conta com a senha
  Future<void> _confirmDeleteAccount(BuildContext context) async {
    final password = await _showStaticPasswordDialog(context);
    if (password == null) return;
    
    // Verifica tanto a senha fixa '1234' quanto a senha mestra do usuário
    final isValid = password == '1234' || await SettingsService.verifyMasterPassword(password);
    if (!isValid) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Senha incorreta')),
        );
      }
      return;
    }

    // Agenda a exclusão da conta
    await SettingsService.scheduleAccountDeletion();
    
    if (context.mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sua conta será excluída em 30 dias. Faça login novamente para cancelar.'),
          duration: Duration(seconds: 5),
        ),
      );
    }
  }

  // Mostra diálogo para inserir a senha
  Future<String?> _showPasswordDialog(BuildContext context) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Senha'),
        content: TextField(
          controller: controller,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Digite sua senha mestra',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  // Mostra diálogo para inserir a senha fixa
  static Future<String?> _showStaticPasswordDialog(BuildContext context) async {
    final controller = TextEditingController();
    bool obscurePassword = true;
    
    return showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Confirmar Senha'),
          content: TextField(
            controller: controller,
            obscureText: obscurePassword,
            decoration: InputDecoration(
              labelText: 'Senha',
              suffixIcon: IconButton(
                icon: Icon(
                  obscurePassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    obscurePassword = !obscurePassword;
                  });
                },
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(controller.text),
              child: const Text('Confirmar'),
            ),
          ],
        ),
      ),
    );
  }

  // ======================= SENHA ========================
  // Configura a senha mestra
  void _configureMasterPassword(BuildContext context) async {
    final controller = TextEditingController();
    final confirmController = TextEditingController();
    bool obscurePassword = true;
    bool obscureConfirmPassword = true;
    
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Configurar Senha Mestra'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                obscureText: obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Nova senha mestra',
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscurePassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        obscurePassword = !obscurePassword;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: confirmController,
                obscureText: obscureConfirmPassword,
                decoration: InputDecoration(
                  labelText: 'Confirmar senha',
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        obscureConfirmPassword = !obscureConfirmPassword;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isEmpty ||
                    controller.text != confirmController.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Senhas não conferem')),
                  );
                  return;
                }
                PasswordService.setMasterPassword(controller.text);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Senha mestra configurada')),
                );
                Navigator.of(context).pop();
              },
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }

  void _configureConfidentialPassword(BuildContext context) async {
    final controller = TextEditingController();
    final confirmController = TextEditingController();
    bool obscurePassword = true;
    bool obscureConfirmPassword = true;
    
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Configurar Senha Confidencial'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                obscureText: obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Nova senha confidencial',
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscurePassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        obscurePassword = !obscurePassword;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: confirmController,
                obscureText: obscureConfirmPassword,
                decoration: InputDecoration(
                  labelText: 'Confirmar senha',
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        obscureConfirmPassword = !obscureConfirmPassword;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isEmpty ||
                    controller.text != confirmController.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Senhas não conferem')),
                  );
                  return;
                }
                PasswordService.setConfidentialPassword(controller.text);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Senha confidencial configurada')),
                );
                Navigator.pop(context);
              },
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }

  // ======================= BACKUP ========================
  // Exporta os dados do aplicativo para um arquivo de backup
Future<void> exportBackup(BuildContext context, {required bool isConfidential}) async {
  final hasPasswords = await PDFExportService.hasPasswordsToExport();
  if (!hasPasswords) {
    if (context.mounted) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Nenhuma senha encontrada'),
          content: const Text('Não há senhas para exportar.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
    return;
  }

  if (isConfidential) {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Atenção'),
        content: const Text(
          'O backup confidencial irá incluir todas as suas senhas em texto legível. '
          'Certifique-se de armazenar este arquivo em um local seguro.\n\n'
          'Deseja continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
  }

  // diálogo de carregamento
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const Center(
      child: CircularProgressIndicator(),
    ),
  );

  try {
    final file = await PDFExportService.exportPasswordsToPDF(
      isConfidential: isConfidential,
    );

    if (context.mounted) {
      Navigator.of(context).pop(); // fecha o loading

      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Backup ${isConfidential ? 'Confidencial ' : ''}Concluído'),
          content: Text(
            'O backup foi salvo em:\n${file.path}',
            style: const TextStyle(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fechar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                PDFExportService.openPDF(file);
              },
              child: const Text('Abrir PDF'),
            ),
          ],
        ),
      );
    }
  } catch (e) {
    if (context.mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao gerar backup: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}


  // Importa um arquivo de backup para restaurar os dados
  Future<void> _importBackup(BuildContext context) async {
    try {
      // Solicitar confirmação do usuário
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Importar Backup'),
          content: const Text('Tem certeza que deseja restaurar a partir de um backup? Isso substituirá os dados atuais.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Importar'),
            ),
          ],
        ),
      );

      if (confirm != true) return;

      // Abrir seletor de arquivos
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['gbackup'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        
        // Mostrar diálogo de carregamento
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return const AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Restaurando backup...'),
                ],
              ),
            );
          },
        );

        try {
          // Restaurar o backup
          final success = await SettingsService.restoreBackup(file);
          
          if (context.mounted) {
            Navigator.of(context).pop(); // Fechar diálogo de carregamento
            
            if (success) {
              // Mostrar diálogo de sucesso
              await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Backup Restaurado'),
                  content: const Text('Os dados foram restaurados com sucesso. O aplicativo será reiniciado para aplicar as alterações.'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // Fechar o diálogo
                        // Mostrar snackbar de sucesso
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Backup restaurado com sucesso!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                        // Reiniciar o aplicativo
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => const MyApp()),
                          (route) => false,
                        );
                      },
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            } else {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Falha ao restaurar o backup. O arquivo pode estar corrompido.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          }
        } catch (e) {
          // Fechar o diálogo de carregamento em caso de erro
          if (context.mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erro ao processar o arquivo: ${e.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } else {
        // Usuário cancelou a seleção
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Nenhum arquivo selecionado'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao selecionar o arquivo: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<Widget> _getLastBackupInfo() async {
    try {
      final backups = await SettingsService.listBackupFiles();
      if (backups.isEmpty) {
        return const Text(
          'Nenhum backup encontrado',
          style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
        );
      }
      
      // Ordena por data de modificação (mais recente primeiro)
      backups.sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));
      final lastBackup = backups.first;
      final file = File(lastBackup.path);
      final stat = await file.stat();
      final date = stat.modified;
      final fileSize = (stat.size / 1024).toStringAsFixed(2); // Tamanho em KB
      
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Último backup: ${DateFormat('dd/MM/yyyy HH:mm').format(date)}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Tamanho: $fileSize KB',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          Text(
            'Local: ${file.path}',
            style: const TextStyle(fontSize: 10, color: Colors.grey, fontFamily: 'monospace'),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      );
    } catch (e) {
      return Text(
        'Erro ao verificar backups: ${e.toString()}',
        style: const TextStyle(color: Colors.red, fontSize: 12),
      );
    }
  }
}

// ======================= PERFIL ========================
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  final List<String> emojis = ['😀', '🦸‍♂️', '👩‍💻', '🧑‍🎨', '🦄'];
  String selectedEmoji = '😀';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() async {
    final profile = await SettingsService.getProfile();
    setState(() {
      selectedEmoji = profile['avatar']!.isNotEmpty ? profile['avatar']! : '😀';
      nomeController.text = profile['name'] ?? '';
      emailController.text = profile['email'] ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              'Escolha seu avatar:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: emojis.map((emoji) {
                final isSelected = emoji == selectedEmoji;
                return GestureDetector(
                  onTap: () => setState(() => selectedEmoji = emoji),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey,
                        width: isSelected ? 3 : 1,
                      ),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      emoji,
                      style: TextStyle(
                        fontSize:
                            MediaQuery.of(context).size.width < 400 ? 28 : 36,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Nome do usuário
            TextField(
              controller: nomeController,
              decoration: const InputDecoration(labelText: 'Nome do usuário'),
            ),
            const SizedBox(height: 8),

            // Email
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: () async {
                await SettingsService.setProfile(
                  avatarPath: selectedEmoji,
                  name: nomeController.text,
                  email: emailController.text,
                );

                // Aqui você salva o nome e email (ex: Hive, SharedPreferences, SQLite, Firebase)
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Perfil salvo!')),
                );
                Navigator.pop(context);
              },
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}
