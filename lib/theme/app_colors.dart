// theme/app_colors.dart
// Definição centralizada de cores do Guardião de Senhas

import 'package:flutter/material.dart';

class AppColors {
  // 🎨 Cores principais
  static const Color primary = Color(0xFF00CFFF); // Azul neon
  static const Color secondary = Color(0xFF8A2BE2); // Violeta neon
  static const Color tertiary = Color(0xFFFFD700); // Dourado

  // 🖤 Tema Escuro
  static const Color darkBackground = Color(0xFF0D0D0D);
  static const Color darkAppBar = Color(0xFF1A1A1A);
  static const Color darkTextPrimary = Colors.white;
  static const Color darkTextSecondary = Colors.white70;
  static const Color darkInputBackground = Color(0xFF1E1E1E);

  // 🤍 Tema Claro
  static const Color lightBackground = Colors.white;
  static const Color lightAppBar = Colors.white;
  static const Color lightTextPrimary = Colors.black;
  static const Color lightTextSecondary = Colors.black87;
  static const Color lightInputBackground = Color(0xFFF5F5F5);

  // 🔘 Botões
  static const Color buttonPrimary = primary;
  static const Color buttonSecondary = secondary;
  static const Color buttonText = Colors.white;

  // ✏️ Campos de texto
  static const Color inputBorder = primary;
  static const Color inputHint = Colors.grey;
  static const Color inputText = Colors.white;

  // ❌ Erros e avisos
  static const Color error = Colors.red;
  static const Color warning = Colors.orange;
  static const Color success = Colors.green;
}


