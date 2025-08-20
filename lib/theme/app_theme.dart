import 'package:flutter/material.dart';

class AppColors {
  // 🔹 Cores modo claro
  static const Color backgroundLight = Colors.white; // Branco
  static const Color primaryLight = Color.fromARGB(255, 43, 99, 197); // Azul claro
  static const Color textLight = Colors.black; // Preto

  // 🔹 Cores modo escuro
  static const Color backgroundDark = Color(0xFF0D0D0D); // Quase preto
  static const Color primaryDark = Color.fromARGB(255, 69, 9, 153); // Roxo escuro
  static const Color textDark = Colors.white; // Branco

// 🔹 Cores dos botões
  static const Color buttonPrimary = Color.fromARGB(255, 43, 99, 197); // Azul claro
  static const Color buttonText = Colors.white; // Branco

// cores dos butões secundários
  static const Color buttonSecondary = Color.fromARGB(255, 69, 9, 153); // Roxo escuro
  static const Color buttonSecondaryText = Colors.white;

}




// 🔹 Tema da aplicação
class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.backgroundLight,
    primaryColor: AppColors.primaryLight,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primaryLight,
      foregroundColor: Colors.white,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.textLight),
      bodyMedium: TextStyle(color: AppColors.textLight),
    ),
  );

// 🔹 Tema escuro 
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.backgroundDark,
    primaryColor: AppColors.primaryDark,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primaryDark,
      foregroundColor: Colors.white,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.textDark),
      bodyMedium: TextStyle(color: AppColors.textDark),
    ),
  );
}
