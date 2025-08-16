// main.dart - Guardião de Senhas
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/main_screen.dart';
import 'screens/backup_screen.dart';
import 'screens/category_screen.dart';
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
          initialRoute: '/login',
          onGenerateRoute: (settings) {
            // Rotas com suporte para backgrounds
            Widget page;
            switch (settings.name) {
              case '/login':
                page = const LoginScreen();
                break;
              case '/register':
                page = const RegisterScreen();
                break;
              case '/main':
                page = const MainScreen();
                break;
              case '/backup':
                page = const BackupScreen();
                break;
              case '/category':
                final args = settings.arguments as String;
                page = CategoryScreen(category: args);
                break;
              default:
                page = const LoginScreen();
            }
            return MaterialPageRoute(
              builder: (context) => BackgroundWrapper(child: page),
            );
          },
        );
      },
    );
  }
}

// Wrapper que aplica o background a qualquer tela
class BackgroundWrapper extends StatelessWidget {
  final Widget child;
  const BackgroundWrapper({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (BackgroundController.backgroundImage != null)
          Opacity(
            opacity: 0.3,
            child: Image.asset(
              BackgroundController.backgroundImage!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        child,
      ],
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

// Controlador de background global
class BackgroundController {
  static String? backgroundImage;

  static void setBackground(String? img) {
    backgroundImage = img;
  }

  static Future<List<String>> getAvailableImages() async {
    return [
      'assets/backgrounds/bg1.png',
      'assets/backgrounds/bg2.png',
      'assets/backgrounds/bg3.png',
      'assets/backgrounds/bg4.png',
      'assets/backgrounds/bg5.png',
    ];
  }
}
