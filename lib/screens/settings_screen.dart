//Arquivo settings_screen para Configurações do Guardião de Senhas
// Este arquivo contém as configurações do aplicativo, incluindo opções de segurança, personalização e dados
//Arquivo settings_screen.dart para Configurações do Guardião de Senhas

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/password_service.dart';
import '../main.dart';
import '../services/settings_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
            leading: const Icon(Icons.history),
            title: const Text('Último backup realizado'),
            subtitle: FutureBuilder<String>(
              future: _getLastBackupInfo(),
              builder: (context, snapshot) {
                // Constrói o widget com base no estado da Future
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // Enquanto espera a Future completar
                  return const Text(
                      'Carregando...'); // Exibe um texto de carregamento
                } else if (snapshot.hasError) {
                  return const Text(
                      'Erro ao carregar backup'); // Exibe um texto de erro
                } else {
                  return Text(snapshot.data ??
                      'Nunca realizado'); // Exibe a data do último backup ou 'Nunca realizado' se for nulo
                }
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.backup),
            title: const Text(
                'Criar backup'), // Cria um backup dos dados // fazer a implementação do backup
            subtitle: const Text(
                'Exportar senhas criptografadas'), // Exportar as senhas criptografadas // fazer a implementação do backup
            onTap: () => _exportBackup(context),
          ),
          ListTile(
            leading: const Icon(Icons.restore),
            title: const Text(
                'Importar backup'), // Importa um backup de dados // fazer a implementação do backup
            subtitle: const Text('Restaurar dados salvos'), // Restaurar backup
            onTap: () => _importBackup(context),
          ),
          // Opção para excluir conta
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Conta',
                style: Theme.of(context).textTheme.titleMedium),
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('Excluir minha conta', style: TextStyle(color: Colors.red)),
            subtitle: const Text('Remove permanentemente todos os seus dados'),
            onTap: () => _showDeleteAccountConfirmation(context),
          ),
        ],
      ),
    );
  }

  // ======================= TEMA ========================
  void _showThemeDialog(BuildContext context) async {
    final themeOptions = [
      '꥟ Claro',
      '⏾ Escuro',
      '⚙️ Sistema'
    ]; // Opções de tema // Fazer a implementação do tema
    final themeController =
        Provider.of<ThemeController>(context, listen: false);
    String currentTheme = themeController.themeModeName;
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Escolher tema'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: themeOptions.map((option) {
            return RadioListTile<String>(
              title: Text(option),
              value: option,
              groupValue: currentTheme,
              onChanged: (val) async {
                themeController.setThemeMode(val!);
                await SettingsService.setThemeMode(val); // 🔥 Salva no Hive
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
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
    return showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar Senha'),
        content: TextField(
          controller: controller,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'Senha'),
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

  // ======================= SENHA ========================
  // Configura a senha mestra
  void _configureMasterPassword(BuildContext context) async {
    final controller = TextEditingController();
    final confirmController = TextEditingController();
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Configurar Senha Mestra'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Nova senha mestra'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: confirmController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Confirmar senha'),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isEmpty ||
                  controller.text != confirmController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Senhas não conferem')));
                return;
              }
              PasswordService.setMasterPassword(controller.text);
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Senha mestra configurada')));
              Navigator.pop(context);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _configureConfidentialPassword(BuildContext context) async {
    final controller = TextEditingController();
    final confirmController = TextEditingController();
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Configurar Senha Confidencial'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              obscureText: true,
              decoration:
                  const InputDecoration(labelText: 'Nova senha confidencial'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: confirmController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Confirmar senha'),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isEmpty ||
                  controller.text != confirmController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Senhas não conferem')));
                return;
              }
              PasswordService.setConfidentialPassword(controller.text);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Senha confidencial configurada')));
              Navigator.pop(context);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  // ======================= BACKUP ========================
  void _exportBackup(BuildContext context) async {
    await SettingsService.setBackupStatus(done: true, location: 'local');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Backup exportado')),
    );
  }

  void _importBackup(BuildContext context) async {
    await SettingsService.setBackupStatus(done: true, location: 'importado');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Backup importado')),
    );
  }

  Future<String> _getLastBackupInfo() async {
    final status = await SettingsService.getBackupStatus();
    return status['done']
        ? "Último backup: ${status['location']}"
        : "Nunca realizado";
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
