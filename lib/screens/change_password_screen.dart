//Arquivo: lib/screens/change_password_screen.dart
// Tela para alterar a senha de login do app

import 'package:flutter/material.dart';
import '../services/settings_service.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  final _service = SettingsService();

  void _changePassword() async {
    final current = _currentController.text.trim();
    final newPass = _newController.text.trim();
    final confirm = _confirmController.text.trim();

    final isValid = await SettingsService.verifyMasterPassword(current);

    if (!isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Senha atual incorreta")),
      );
      return;
    }

    if (newPass.isEmpty || newPass != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nova senha inválida ou não confere")),
      );
      return;
    }

    await SettingsService.setMasterPasswordStatic(newPass);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Senha alterada com sucesso")),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Alterar Senha de Login")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _currentController,
              decoration: const InputDecoration(labelText: "Senha atual"),
              obscureText: true,
            ),
            TextField(
              controller: _newController,
              decoration: const InputDecoration(labelText: "Nova senha"),
              obscureText: true,
            ),
            TextField(
              controller: _confirmController,
              decoration: const InputDecoration(labelText: "Confirmar nova senha"),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _changePassword,
              child: const Text("Salvar"),
            ),
          ],
        ),
      ),
    );
  }
}
