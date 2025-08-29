// main.dart - Guardião de Senhas
// Ponto de entrada do aplicativo Guardião de Senhas.
// Configura tema, rotas e gerenciamento de estado global.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/elf_intro_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/main_screen.dart';
import 'screens/backup_screen.dart';
import 'screens/category_screen.dart';
import 'screens/registro_guardiao_flow.dart';
import 'services/password_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PasswordService.init();
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeController(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeController>(
      builder: (context, themeController, _) {
        return MaterialApp(
          title: 'Guardião de Senhas',
          themeMode: themeController.themeMode,
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          debugShowCheckedModeBanner: false,
          // Primeira tela exibida
          initialRoute: '/elf_intro',
          routes: {
            '/elf_intro': (context) => const ElfIntroScreen(),
            '/login': (context) => const LoginScreen(),
            '/register': (context) => const RegisterScreen(),
            '/main': (context) => const MainScreen(),
            '/backup': (context) => const BackupScreen(),
            '/category': (context) {
              final args = ModalRoute.of(context)!.settings.arguments as String;
              return CategoryScreen(category: args);
            },
            '/registro_guardiao': (context) => const RegistroGuardiaoFlow(),
          },
        );
      },
    );
  }
}

// Controlador de tema usando ChangeNotifier
class ThemeController extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  String _themeModeName = 'Sistema';

  ThemeMode get themeMode => _themeMode;
  String get themeModeName => _themeModeName;

  void setThemeMode(String mode) {
    switch (mode) {
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
