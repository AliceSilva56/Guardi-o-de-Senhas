// theme/app_colors.dart
// Definição centralizada de cores do Guardião de Senhas

import 'package:flutter/material.dart';

class AppColors {
  // 🎨 Cores principais
  static const Color primary = Color(0xFF00CFFF); // Azul neon
  static const Color secondary = Color(0xFF8A2BE2); // Violeta neon
  static const Color tertiary = Color(0xFFFFD700); // Dourado


  // 🖤 Tema Escuro
  static const Color darkBackground = Color(0xFF0D0D0D); // Fundo escuro
  static const Color darkAppBar = Color(0xFF1A1A1A); // Fundo escuro do AppBar
  static const Color darkTextPrimary = Colors.white; // Texto primário claro
  static const Color darkTextSecondary = Colors.white70; // Texto secundário mais suave
  static const Color darkInputBackground = Color(0xFF1E1E1E); // Fundo dos campos de entrada


  // 🤍 Tema Claro
  static const Color lightBackground = Colors.white; // Fundo claro
  static const Color lightAppBar = Colors.white; // Fundo claro do AppBar
  static const Color lightTextPrimary = Colors.black; // Texto primário escuro
  static const Color lightTextSecondary = Colors.black87; // Texto secundário mais suave
  static const Color lightInputBackground = Color(0xFFF5F5F5); // Fundo dos campos de entrada claros

  // 🔘 Botões
  static const Color buttonPrimary = primary; // Azul neon
  static const Color buttonSecondary = secondary; // Violeta neon
  static const Color buttonTertiary = tertiary; // Dourado
  static const Color buttonDisabled = Colors.grey; // Botão desativado
  static const Color buttonText = Colors.white; // Texto dos botões

  // ✏️ Campos de texto
  static const Color inputBorder = primary; // Borda dos campos de entrada
  static const Color inputBackground = lightInputBackground; // Fundo dos campos de entrada
  static const Color inputHint = Colors.grey; // Texto de dica nos campos de entrada
  static const Color inputdark = Colors.black87; // Texto nos campos de entrada
  static const Color inputText = Colors.white; // Texto nos campos de entrada claros

  // ❌ Erros e avisos
  static const Color error = Colors.red; // Vermelho para erros
  static const Color warning = Colors.orange; // Laranja para avisos
  static const Color success = Colors.green; // Verde para sucessos
}



