import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'theme/app_theme.dart';
import 'screens/login_screen.dart';
import 'screens/main_screen.dart';
import 'screens/backup_screen.dart';
import 'services/password_service.dart';
import 'screens/register_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await PasswordService.init();
  runApp(const GuardiaoDeSenhasApp());
}

class GuardiaoDeSenhasApp extends StatelessWidget {
  const GuardiaoDeSenhasApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Guardião de Senhas',
      theme: AppTheme.lightTechTheme, // Tema claro
      debugShowCheckedModeBanner: false,
      darkTheme: AppTheme.darkTechTheme, // Tema escuro
      themeMode: ThemeMode.system, // Segue a configuração do sistema
      initialRoute: '/login', // Rota inicial
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/main': (context) => const MainScreen(),
      },
    );
  }
}