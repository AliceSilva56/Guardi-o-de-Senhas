// main.dart - Guardião de Senhas
// Ponto de entrada do aplicativo Guardião de Senhas.
// Configura tema, rotas e gerenciamento de estado global.

import 'package:flutter/material.dart'; // Importa o pacote Flutter
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart'; // Importa o pacote Provider
import 'screens/initial_screen.dart'; // Tela inicial que decide qual tela mostrar
import 'screens/elf_intro_screen.dart'; // Importa a tela de introdução do elfo
import 'screens/login_screen.dart'; // Importa a tela de login
import 'screens/main_screen.dart'; // Importa a tela principal
import 'screens/backup_screen.dart'; // Importa a tela de backup
import 'screens/category_screen.dart'; // Importa a tela de categoria
import 'screens/registro_guardiao_flow.dart'; // Importa a tela de registro do guardião
import 'services/password_service.dart'; // Importa o serviço de senhas
import 'services/settings_service.dart';
import 'theme/app_theme.dart'; // Importa o tema personalizado
import 'theme/theme_wrapper.dart'; // Importa o wrapper de tema personalizado

void main() async {
  // Initialize Flutter bindings
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Open Hive boxes
  if (!Hive.isBoxOpen('guardiao_passwords')) {
    await Hive.openBox('guardiao_passwords');
  }
  // Open settings and profile boxes
  if (!Hive.isBoxOpen('settings')) {
    await Hive.openBox('settings');
  }
  // Open additional boxes as needed
  if (!Hive.isBoxOpen('profile')) {
    await Hive.openBox('profile');
  }
  // Open user preferences box
  if (!Hive.isBoxOpen('user_preferences')) {
    await Hive.openBox('user_preferences');
  }
  
  // Check for pending account deletion
  // check a pedir exclusao de conta
  final shouldDelete = await SettingsService.checkAndProcessDeletion();
  
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeController(),
      child: MyApp(shouldDelete: shouldDelete),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool shouldDelete;
  
  const MyApp({super.key, this.shouldDelete = false});
  
  // Mostra um diálogo se o usuário tiver solicitado exclusão recentemente
  void _showDeletionNotice(BuildContext context, DateTime deletionDate) {
    final now = DateTime.now();
    final daysLeft = deletionDate.difference(now).inDays;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Exclusão de Conta Pendente'),
        content: Text(
          'Você solicitou a exclusão da sua conta. Faltam $daysLeft dias para a remoção completa dos seus dados.\n\nDeseja cancelar a exclusão?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showFarewellDialog(context);
            },
            child: const Text('Não, sair do app'),
          ),
          TextButton(
            onPressed: () async {
              await SettingsService.cancelAccountDeletion();
              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Exclusão de conta cancelada com sucesso!')),
                );
              }
            },
            child: const Text('Sim, cancelar exclusão'),
          ),
        ],
      ),
    );
  }
  
  void _showFarewellDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Até logo!'),
        content: const Text('Sua conta será excluída em breve. Obrigado por usar nosso aplicativo!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Verifica se há uma exclusão pendente ao iniciar o app
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!shouldDelete) {
        final deletionDate = await SettingsService.getPendingDeletionDate();
        if (deletionDate != null && context.mounted) {
          _showDeletionNotice(context, deletionDate);
        }
      }
    });
    
    return Consumer<ThemeController>(
      builder: (context, themeController, _) {
        return MaterialApp(
          title: 'Guardião de Senhas',
          themeMode: themeController.themeMode,
          theme: AppTheme.lightTheme.copyWith(
            scaffoldBackgroundColor: AppColors.lightBackground,
          ),
          darkTheme: AppTheme.darkTheme.copyWith(
            scaffoldBackgroundColor: AppColors.backgroundDark,
          ),
          debugShowCheckedModeBanner: false,
          builder: (context, child) {
            return ThemeWrapper(
              child: child!,
            );
          },
          // Primeira tela exibida
          home: const InitialScreen(),
          routes: {
            '/elf_intro': (context) => const ThemeWrapper(child: ElfIntroScreen()),
            '/login': (context) => const ThemeWrapper(child: LoginScreen()),
            '/main': (context) => const ThemeWrapper(child: MainScreen()),
            '/backup': (context) => const ThemeWrapper(child: BackupScreen()),
            '/category': (context) {
              final args = ModalRoute.of(context)!.settings.arguments as String;
              return ThemeWrapper(child: CategoryScreen(category: args));
            },
            '/registro_guardiao': (context) => const ThemeWrapper(child: RegistroGuardiaoFlow()),
          },
        );
      },
    );
  }
}

// Controlador de tema usando ChangeNotifier
class ThemeController extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system; // valor inicial
  String _themeModeName = 'Sistema';       // valor inicial

  ThemeController() {
    _loadTheme();
  }

  ThemeMode get themeMode => _themeMode;
  String get themeModeName => _themeModeName;

  Future<void> _loadTheme() async {
    try {
      final savedTheme = await SettingsService.getSavedThemeMode();
      _applyTheme(savedTheme);
    } catch (e) {
      _themeMode = ThemeMode.system;
      _themeModeName = 'Sistema';
    }
  }

  Future<void> setThemeMode(String mode) async {
    _applyTheme(mode);
    await SettingsService.setThemeMode(mode);
  }

  void _applyTheme(String mode) {
    final cleanMode = mode.replaceAll(RegExp(r'[^\x00-\x7F]+'), '').trim();
    
    switch (cleanMode) {
      case 'Claro':
        _themeMode = ThemeMode.light;
        _themeModeName = 'Claro';
        break;
      case 'Escuro':
        _themeMode = ThemeMode.dark;
        _themeModeName = 'Escuro';
        break;
      default:
        _themeMode = ThemeMode.system;
        _themeModeName = 'Sistema';
    }
    notifyListeners();
  }
}

