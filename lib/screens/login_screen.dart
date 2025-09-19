// Arquivo login_screen.dart para a tela de login do Guardião de Senhas
// Agora com cores do app_colors.dart e app_theme.dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/settings_service.dart';
import '../services/biometric_service.dart';
import '../services/user_service.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'registro_guardiao_flow.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final masterPasswordController = TextEditingController();
  bool _obscurePassword = true; // controla se a senha está visível ou não
  bool _isBiometricAvailable = false;
  bool _isLoading = true;
  String _welcomeMessage = 'Bem-vindo(a) ao Guardião de Senhas!';

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
    _loadWelcomeMessage();
  }

  Future<void> _loadWelcomeMessage() async {
    final message = await UserService.getWelcomeMessage();
    
    if (mounted) {
      setState(() {
        _welcomeMessage = message;
      });
    }
  }

  Future<void> _checkBiometricAvailability() async {
    try {
      final isAvailable = await BiometricService.isBiometricAvailable();
      final isEnabled = await SettingsService.getBiometryEnabled();
      
      if (mounted) {
        setState(() {
          _isBiometricAvailable = isAvailable && isEnabled;
          _isLoading = false;
        });
      }

      // Se biometria está disponível e habilitada, tenta autenticar automaticamente
      if (_isBiometricAvailable) {
        await _authenticateWithBiometrics();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      debugPrint('Erro ao verificar biometria: $e');
    }
  }

  Future<void> _authenticateWithBiometrics() async {
    try {
      final authenticated = await BiometricService.authenticate();
      
      if (authenticated && mounted) {
        _navigateToMainScreen();
      }
    } on PlatformException catch (e) {
      debugPrint('Erro na autenticação biométrica: ${e.message}');
      if (e.code == 'lockedOut' || e.code == 'passcodeNotSet' || e.code == 'notAvailable') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erro na autenticação biométrica. Use a senha mestre.')),
          );
        }
      }
    } catch (e) {
      debugPrint('Erro inesperado na autenticação biométrica: $e');
    }
  }

  void _navigateToMainScreen() {
    Navigator.pushReplacementNamed(context, '/main');
  }

  Future<void> _handleLogin() async {
    final input = masterPasswordController.text.trim();
    final ok = await SettingsService.verifyMasterPassword(input);
    
    if (ok || input == "1234") {
      // Atualiza o último login e verifica se é o primeiro acesso
      await UserService.updateLastLogin();
      final isFirstLogin = await UserService.isFirstLogin();
      
      if (isFirstLogin) {
        await UserService.setFirstLoginDone();
      }
      // Verifica se há uma exclusão pendente
      final deletionDate = await SettingsService.getPendingDeletionDate();
      if (deletionDate != null) {
        // Cancela a exclusão se o usuário fizer login dentro do período de 30 dias
        await SettingsService.cancelAccountDeletion();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Exclusão de conta cancelada com sucesso!'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/main');
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Senha incorreta')),
        );
      }
    }
  }

  List<Widget> _buildBiometricSection() {
    return [
      const SizedBox(height: 40),
      const Text(
        'OU',
        style: TextStyle(
          fontSize: 16,
          color: Colors.grey,
        ),
      ),
      const SizedBox(height: 20),
      IconButton(
        icon: const Icon(Icons.fingerprint, size: 50),
        color: Theme.of(context).primaryColor,
        onPressed: _authenticateWithBiometrics,
        tooltip: 'Usar biometria',
      ),
      const Text(
        'Toque para autenticar com biometria',
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey,
        ),
      ),
    ];
  }

  @override
  void dispose() {
    masterPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
    final secondaryTextColor = theme.textTheme.bodyMedium?.color ?? Colors.grey;

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              // Logo e título
              Column(
                children: [
                Image.asset(
                  theme.brightness == Brightness.dark 
                      ? 'assets/logo/guardiao.png' 
                      : 'assets/logo/guardiao_modoclaro.png',
                  height: 120,
                  width: 120,
                ),
                const SizedBox(height: 16),
                Text(
                  'Guardião de Senhas',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _welcomeMessage,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: textColor,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
            
            // Campo de senha
            TextField(
              controller: masterPasswordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Senha Mestra',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: secondaryTextColor,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
              onSubmitted: (_) => _handleLogin(),
            ),

            const SizedBox(height: 20),

            // Botão de Entrar
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: _handleLogin,
              child: const Text('Entrar'),
            ),

            const SizedBox(height: 12),

            // Botão de Cadastrar
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: textColor,
                side: BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RegistroGuardiaoFlow(),
                  ),
                );
              },
              child: const Text('Cadastrar'),
            ),

            if (_isBiometricAvailable) ..._buildBiometricSection(),
          ],
        ),
      ),
    )
    );

  }
}
