// Arquivo main.dart para o aplicativo Guardião de Senhas
// Este arquivo inicializa o Hive, configura o tema do aplicativo e define as rotas principais
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'screens/login_screen.dart';
import 'screens/main_screen.dart';
import 'screens/backup_screen.dart';
import 'screens/register_screen.dart';
import 'screens/category_screen.dart'; // Import da tela de categorias
import 'services/password_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PasswordService.init();
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeController(),
      child: BackgroundController(
        child: const MyApp(),
      ),
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
          home: Stack(
            children: [
              if (BackgroundController.of(context).backgroundImage != null)
                Opacity(
                  opacity: 0.3,
                  child: Image.asset(
                    BackgroundController.of(context).backgroundImage!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              MainScreen(),
            ],
          ),
          debugShowCheckedModeBanner: false,
          initialRoute: '/login', // Rota inicial
          routes: {
            '/login': (context) => const LoginScreen(),
            '/register': (context) => const RegisterScreen(),
            '/main': (context) => const MainScreen(),
            '/backup': (context) => const BackupScreen(),
            '/category': (context) {
              // Recebe o argumento ao chamar Navigator.pushNamed
              final args = ModalRoute.of(context)!.settings.arguments as String;
              return CategoryScreen(category: args);
            },
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

class BackgroundController extends InheritedWidget {
  final String? backgroundImage;
  final void Function(String?) setBackgroundImage;

  BackgroundController({
    required Widget child,
  })  : backgroundImage = _backgroundImage,
        setBackgroundImage = _setBackgroundImage,
        super(child: child);

  static BackgroundController of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<BackgroundController>()!;

  static String? _backgroundImage;

  static void _setBackgroundImage(String? img) {
    _backgroundImage = img;
  }

  static Future<List<String>> getAvailableImages() async {
    // Retorne os caminhos das imagens da pasta assets/backgrounds/
    // Exemplo fixo, substitua pelos nomes reais dos arquivos
    return [
      'assets/backgrounds/bg1.png',
      'assets/backgrounds/bg2.png',
      'assets/backgrounds/bg3.png',
      'assets/backgrounds/bg4.png',
      'assets/backgrounds/bg5.png',
    ];
  }

  @override
  bool updateShouldNotify(BackgroundController oldWidget) {
    return backgroundImage != oldWidget.backgroundImage;
  }
}
