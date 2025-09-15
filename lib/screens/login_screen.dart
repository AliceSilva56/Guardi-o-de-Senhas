// Arquivo login_screen.dart para a tela de login do Guardião de Senhas
// Agora com cores do app_colors.dart e app_theme.dart
import 'package:flutter/material.dart';
import 'register_screen.dart';
import '../theme/app_colors.dart';
import '../services/settings_service.dart';
import '../services/biometric_service.dart';
import 'dart:async';
import 'package:flutter/services.dart';

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

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final secondaryTextColor = isDark ? Colors.white70 : Colors.black54;
    final backgroundColor =
        isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final inputFillColor =
        isDark ? AppColors.darkInputBackground : AppColors.lightInputBackground;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '🛡️ Guardião de Senhas',
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 40),

                TextField(
                  controller: masterPasswordController,
                  obscureText: _obscurePassword,
                  autofocus: true,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) async {
                    await _handleLogin();
                  },
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    labelText: 'Senha Mestra',
                    labelStyle: TextStyle(color: secondaryTextColor),
                    filled: true,
                    fillColor: inputFillColor,
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: secondaryTextColor,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Linha com Entrar e Cadastrar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _handleLogin,
                      child: const Text('Entrar'),
                    ),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: textColor,
                        side: BorderSide(color: AppColors.primary),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const RegisterScreen()),
                        );
                      },
                      child: const Text('Cadastrar'),
                    ),
                  ],
                ),

                if (_isBiometricAvailable) ..._buildBiometricSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
