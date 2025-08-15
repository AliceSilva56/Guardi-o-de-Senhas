// Arquivo login_screen.dart para a tela de login do Guardião de Senhas
// Agora com cores do app_colors.dart e app_theme.dart
import 'package:flutter/material.dart';
import 'register_screen.dart';
import '../theme/app_colors.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final masterPasswordController = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final secondaryTextColor = isDark ? Colors.white70 : Colors.black54;
    final backgroundColor = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final inputFillColor = isDark ? AppColors.darkInputBackground : AppColors.lightInputBackground;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Padding(
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
              const SizedBox(height: 20),
              TextField(
                controller: masterPasswordController,
                obscureText: true,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  labelText: 'Senha Mestra',
                  labelStyle: TextStyle(color: secondaryTextColor),
                  filled: true,
                  fillColor: inputFillColor,
                  border: const OutlineInputBorder(),
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
                    onPressed: () {
                      if (masterPasswordController.text.trim() == '1234') {
                        Navigator.pushReplacementNamed(context, '/main');
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Senha incorreta')),
                        );
                      }
                    },
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
                        MaterialPageRoute(builder: (context) => const RegisterScreen()),
                      );
                    },
                    child: const Text('Cadastrar'),
                  ),
                ],
              ),

              TextButton(
                onPressed: () {
                  // Aqui simulação de login biométrico
                },
                child: Text(
                  'Acesso Biométrico 👆',
                  style: TextStyle(color: secondaryTextColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
