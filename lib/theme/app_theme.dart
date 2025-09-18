import 'package:flutter/material.dart';

class AppColors {
  // 🔹 Cores modo claro
  static const Color backgroundLight = Color(0xFFFEF5EC); // Bege claro personalizado
  static const Color primaryLight = Color.fromARGB(255, 43, 99, 197); // Azul claro
  static const Color textLight = Color(0xFF333333); // Cinza escuro para melhor contraste

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
    colorScheme: const ColorScheme.light(
      primary: AppColors.primaryLight,
      secondary: Color(0xFF8A4D76), // Cor secundária roxa
      surface: Colors.white,
      background: AppColors.backgroundLight,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.textLight,
      onBackground: AppColors.textLight,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primaryLight,
      foregroundColor: Colors.white,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: AppColors.textLight, fontSize: 32, fontWeight: FontWeight.bold),
      displayMedium: TextStyle(color: AppColors.textLight, fontSize: 28, fontWeight: FontWeight.bold),
      displaySmall: TextStyle(color: AppColors.textLight, fontSize: 24, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(color: AppColors.textLight, fontSize: 20, fontWeight: FontWeight.w600),
      headlineSmall: TextStyle(color: AppColors.textLight, fontSize: 18, fontWeight: FontWeight.w600),
      titleLarge: TextStyle(color: AppColors.textLight, fontSize: 16, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(color: AppColors.textLight, fontSize: 16),
      bodyMedium: TextStyle(color: AppColors.textLight, fontSize: 14),
      bodySmall: TextStyle(color: Color(0xB3333333), fontSize: 12), // 70% de opacidade
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: const TextStyle(color: Color(0xFF9E9E9E)), // Cinza 500
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryLight,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
      ),
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: Colors.white,
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
