// Arquivo register_screen.dart para a tela de registro do Guardião de Senhas
// Agora com cores do app_colors.dart e app_theme.dart
import 'package:flutter/material.dart';
import 'login_screen.dart';
import '../theme/app_colors.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

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
          child: SingleChildScrollView(
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
                  controller: nameController,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    labelText: 'Nome',
                    labelStyle: TextStyle(color: secondaryTextColor),
                    filled: true,
                    fillColor: inputFillColor,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),

                TextField(
                  controller: emailController,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    labelText: 'E-mail',
                    labelStyle: TextStyle(color: secondaryTextColor),
                    filled: true,
                    fillColor: inputFillColor,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),

                TextField(
                  controller: passwordController,
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
                const SizedBox(height: 15),

                TextField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    labelText: 'Confirmar Senha Mestra',
                    labelStyle: TextStyle(color: secondaryTextColor),
                    filled: true,
                    fillColor: inputFillColor,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        if (passwordController.text != confirmPasswordController.text) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('As senhas não coincidem')),
                          );
                          return;
                        }
                        Navigator.pushReplacementNamed(context, '/main');
                      },
                      child: const Text('Criar Cadastro'),
                    ),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: textColor,
                        side: BorderSide(color: AppColors.primary),
                      ),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                        );
                      },
                      child: const Text('Já tenho login'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
