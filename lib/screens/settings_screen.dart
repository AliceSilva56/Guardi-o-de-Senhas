//Arquivo settings_screen para Configurações do Guardião de Senhas
// Este arquivo contém as configurações do aplicativo, incluindo opções de segurança, personalização e dados
//Arquivo settings_screen.dart para Configurações do Guardião de Senhas

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/password_service.dart';
import '../main.dart';

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
            child: Text('Informações Básicas', style: Theme.of(context).textTheme.titleMedium),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Perfil'),
            subtitle: const Text('Nome, e-mail e foto de perfil'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
          ),
          const Divider(),

          // Opções de Segurança
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Opções de Segurança', style: Theme.of(context).textTheme.titleMedium),
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
            onTap: () {}, // implementar biometria
          ),
          const Divider(),

          // Personalização
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Personalização', style: Theme.of(context).textTheme.titleMedium),
          ),
          ListTile(
            leading: const Icon(Icons.color_lens),
            title: const Text('Tema do aplicativo'),
            subtitle: const Text('Claro, escuro ou sistema'),
            onTap: () => _showThemeDialog(context),
          ),
          ListTile(
            leading: const Icon(Icons.image),
            title: const Text('Imagem de fundo'),
            subtitle: const Text('Escolha uma imagem para o fundo'),
            onTap: () => _showBackgroundDialog(context),
          ),
          const Divider(),

          // Dados e Backup
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Dados e Backup', style: Theme.of(context).textTheme.titleMedium),
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Último backup realizado'), // Exibe a data do último backup
            subtitle: Text(_getLastBackupInfo()),
          ),
          ListTile(
            leading: const Icon(Icons.backup),
            title: const Text('Criar backup'), // Cria um backup dos dados // fazer a implementação do backup
            subtitle: const Text('Exportar senhas criptografadas'), // Exportar as senhas criptografadas // fazer a implementação do backup
            onTap: () => _exportBackup(context),
          ),
          ListTile(
            leading: const Icon(Icons.restore),
            title: const Text('Importar backup'), // Importa um backup de dados // fazer a implementação do backup
            subtitle: const Text('Restaurar dados salvos'), // Restaurar backup
            onTap: () => _importBackup(context),
          ),
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('Limpar dados'),
            subtitle: const Text('Excluir todos os dados do aplicativo'),
            onTap: () {
              // PasswordService.clearAllData();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Todos os dados foram excluídos')));
              Navigator.pop(context); // Volta para a tela anterior
            },
          ),
        ],
      ),
    );
  }

  // ======================= TEMA ========================
  void _showThemeDialog(BuildContext context) async {
    final themeOptions = ['꥟ Claro', '⏾ Escuro', '⚙️ Sistema']; // Opções de tema // Fazer a implementação do tema
    final themeController = Provider.of<ThemeController>(context, listen: false);
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
              onChanged: (val) {
                themeController.setThemeMode(val!);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  // ======================= BACKGROUND ========================
  // Fazer a implementação do background

  void _showBackgroundDialog(BuildContext context) async {
    final images = await BackgroundController.getAvailableImages();
    String? currentImage = BackgroundController.backgroundImage; // leitura direta

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Escolher imagem de fundo'),
        content: SizedBox(
          width: double.maxFinite,
          child: Wrap(
            spacing: 12,
            children: images.map((imgPath) {
              final isSelected = imgPath == currentImage;
              return GestureDetector(
                onTap: () {
                  BackgroundController.setBackground(imgPath); // chamada direta
                  Navigator.pop(context);
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Opacity(
                      opacity: 0.6,
                      child: Image.asset(imgPath, width: 80, height: 80, fit: BoxFit.cover),
                    ),
                    if (isSelected)
                      const Icon(Icons.check_circle, color: Colors.green, size: 32),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        ],
      ),
    );
  }

  // ======================= SENHA ========================
  // Configura a senha mestra
  // Configura a senha confidencial

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
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isEmpty || controller.text != confirmController.text) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Senhas não conferem')));
                return;
              }
              PasswordService.setMasterPassword(controller.text);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Senha mestra configurada')));
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
              decoration: const InputDecoration(labelText: 'Nova senha confidencial'),
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
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isEmpty || controller.text != confirmController.text) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Senhas não conferem')));
                return;
              }
              PasswordService.setConfidentialPassword(controller.text);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Senha confidencial configurada')));
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
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Backup exportado')));
  }

  void _importBackup(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Backup importado')));
  }

  String _getLastBackupInfo() => 'Nunca realizado';
}

// ======================= PERFIL ========================
// fazer a implementação do perfil
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController apelidoController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  final List<String> emojis = ['😀', '🦸‍♂️', '👩‍💻', '🧑‍🎨', '🦄'];
  String selectedEmoji = '😀';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Escolha seu avatar:', style: Theme.of(context).textTheme.titleMedium),
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
                        color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey,
                        width: isSelected ? 3 : 1,
                      ),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Text(emoji, style: const TextStyle(fontSize: 36)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            TextField(controller: nomeController, decoration: const InputDecoration(labelText: 'Nome do usuário')),
            const SizedBox(height: 8),
            TextField(controller: apelidoController, decoration: const InputDecoration(labelText: 'Apelido')),
            const SizedBox(height: 8),
            TextField(controller: emailController, decoration: const InputDecoration(labelText: 'E-mail de recuperação'), keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Perfil salvo!')));
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
