// Arquivo: lib/theme/app_theme.dart
// Este arquivo define o tema principal do aplicativo Guardião de Senhas,
// incluindo cores, fontes e estilos para diferentes elementos da interface.
// Ele é usado para garantir uma aparência consistente em todo o aplicativo.
import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  /// Retorna cor de texto primário dependendo do tema
  static Color textPrimary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
  }

  /// Cor de texto secundário
  static Color textSecondary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;
  }

  /// Cor do background
  static Color background(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? AppColors.darkBackground
        : AppColors.lightBackground;
  }

  /// 🎨 Tema Escuro - Dark Tech Futurista
  static ThemeData darkTechTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.darkBackground,
    primaryColor: AppColors.primary,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      tertiary: AppColors.tertiary,
    ),
    fontFamily: 'Rajdhani',
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.darkTextPrimary),
      bodyMedium: TextStyle(color: AppColors.darkTextSecondary),
    ),
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
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.buttonPrimary,
        foregroundColor: AppColors.buttonText,
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
      ),
    ),
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
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      tertiary: AppColors.tertiary,
    ),
    fontFamily: 'Rajdhani',
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.lightTextPrimary),
      bodyMedium: TextStyle(color: AppColors.lightTextSecondary),
    ),
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
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.buttonPrimary,
        foregroundColor: AppColors.buttonText,
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.lightInputBackground,
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
}
