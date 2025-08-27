// Arquivo register_screen.dart (mantido simples)
// Apenas acréscimo: após cadastrar, navegar para MainScreen chamando pelo nome.

import '../services/settings_service.dart'; // 🔹 importa o serviço
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'main_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final SettingsService _settingsService = SettingsService(); // 🔹 instância


  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final inputFill = isDark ? AppColors.darkInputBackground : AppColors.lightInputBackground;

    return Scaffold(
      appBar: AppBar(title: Text('Cadastro', style: TextStyle(color: textColor))),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
  TextField(
    controller: _nameController,
    style: TextStyle(color: textColor),
    autofocus: true, // 🔹 Alteração: já inicia com foco neste campo
    decoration: InputDecoration(
      labelText: 'Nome',
      filled: true,
      fillColor: inputFill,
      border: const OutlineInputBorder(),
    ),
    onSubmitted: (_) {
      FocusScope.of(context).nextFocus(); // 🔹 Alteração: Enter vai pro próximo campo
    },
  ),
  const SizedBox(height: 12),
  TextField(
    controller: _emailController,
    style: TextStyle(color: textColor),
    decoration: InputDecoration(
      labelText: 'E-mail',
      filled: true,
      fillColor: inputFill,
      border: const OutlineInputBorder(),
    ),
    onSubmitted: (_) {
      FocusScope.of(context).nextFocus(); // 🔹 Alteração: Enter vai pro próximo campo
    },
  ),
  const SizedBox(height: 12),
  TextField(
    controller: _passController,
    obscureText: true,
    style: TextStyle(color: textColor),
    decoration: InputDecoration(
      labelText: 'Senha',
      filled: true,
      fillColor: inputFill,
      border: const OutlineInputBorder(),
    ),
   onSubmitted: (_) async {
  final name = _nameController.text.trim();
  if (name.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Informe seu nome')),
    );
    return;
  }
  // 🔹 Agora salva a senha mestre
  await _settingsService.setMasterPassword(_passController.text.trim());

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (_) => MainScreen(userName: name)),
      );
    },
  ),
  const SizedBox(height: 20),
  ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.buttonPrimary,
      foregroundColor: AppColors.buttonText,
    ),
    onPressed: () async {
  final name = _nameController.text.trim();
  if (name.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Informe seu nome')),
    );
    return;
  }
  // 🔹 Agora salva a senha mestre
  await _settingsService.setMasterPassword(_passController.text.trim());

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (_) => MainScreen(userName: name)),
      );
    },
    child: const Text('Concluir Cadastro'),
            ),
          ],
        ),
      ),
    );
  }
}
