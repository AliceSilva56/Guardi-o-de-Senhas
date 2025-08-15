// Arquivo app_theme.dart para o tema do Guardião de Senhas
// Este arquivo define os temas escuro e claro do aplicativo, com uma estética futurista e tecnológica, utilizando cores neon e uma fonte de estilo futurista.
// O tema escuro é inspirado em tecnologia futurista, enquanto o tema claro mantém a mesma paleta de cores, mas com um fundo claro.
// Ambos os temas são aplicados ao MaterialApp do Flutter, permitindo uma experiência de usuário consistente e atraente.
// As cores e fontes foram escolhidas para criar uma atmosfera de segurança e modernidade, refletindo a proposta do aplicativo como um guardião de senhas.

import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  /// 🎨 Tema Escuro - Dark Tech Futurista
  static ThemeData darkTechTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.darkBackground,
    primaryColor: AppColors.primary,

// Definição da cor primária do tema
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      tertiary: AppColors.tertiary,
    ),

    // Definição da fonte principal do tema
    fontFamily: 'Rajdhani',

// Definição do tema de texto
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.darkTextPrimary),
      bodyMedium: TextStyle(color: AppColors.darkTextSecondary),
    ),

// Definição do tema da AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkAppBar,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: 'Orbitron',
        fontWeight: FontWeight.bold,
        fontSize: 20,
        color: AppColors.darkTextPrimary,
      ),
    ),

// Definição do tema dos botões elevados
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.buttonPrimary,
        foregroundColor: AppColors.buttonText,
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
      ),
    ),

// Definição do tema dos campos de entrada
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkInputBackground,
      hintStyle: const TextStyle(color: AppColors.inputHint),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.inputBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
      errorStyle: const TextStyle(color: AppColors.error),
    ),
  );

  /// ☀️ Tema Claro - Light Tech
  static ThemeData lightTechTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.lightBackground,
    primaryColor: AppColors.primary,

    // Definição da cor primária do tema
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      tertiary: AppColors.tertiary,
    ),

    // Definição da fonte principal do tema
    fontFamily: 'Rajdhani',

    // Definição do tema de texto
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.lightTextPrimary),
      bodyMedium: TextStyle(color: AppColors.lightTextSecondary),
    ),

  // Definição do tema da AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.lightAppBar,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: 'Orbitron',
        fontWeight: FontWeight.bold,
        fontSize: 20,
        color: AppColors.lightTextPrimary,
      ),
      iconTheme: IconThemeData(color: AppColors.lightTextPrimary),
    ),

  // Definição do tema dos botões elevados
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.buttonPrimary,
        foregroundColor: AppColors.buttonText,
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
      ),
    ),

// Definição do tema dos campos de entrada
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.lightInputBackground, // Cor de fundo dos campos de entrada
      hintStyle: const TextStyle(color: AppColors.inputHint), // Estilo do texto de dica
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.inputBorder), // Cor da borda dos campos de entrada
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.primary, width: 2), // Cor da borda ao focar no campo de entrada
      ),
      errorStyle: const TextStyle(color: AppColors.error), // Estilo do texto de erro
    ),
  );
}
