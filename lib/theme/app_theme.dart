import 'package:flutter/material.dart';

class AppTheme {
  /// 🎨 Tema Escuro - Dark Tech Futurista
  static ThemeData darkTechTheme = ThemeData(
    brightness: Brightness.dark, // Define que o tema é escuro
    scaffoldBackgroundColor: const Color(0xFF0D0D0D), // Cor de fundo principal
    primaryColor: const Color(0xFF00CFFF), // Cor principal (azul neon)
    
    // Paleta de cores personalizada
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF00CFFF), // Azul neon
      secondary: Color(0xFF8A2BE2), // Violeta neon
      tertiary: Color(0xFFFFD700), // Dourado (destaques)
    ),
    
    fontFamily: 'Rajdhani', // Fonte padrão
    
    // Cores padrão para textos
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white), // Texto grande
      bodyMedium: TextStyle(color: Colors.white70), // Texto médio
    ),
    
    // Estilo da AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1A1A1A), // Fundo da AppBar
      elevation: 0, // Remove sombra
      centerTitle: true, // Centraliza título
      titleTextStyle: TextStyle(
        fontFamily: 'Orbitron',
        fontWeight: FontWeight.bold,
        fontSize: 20,
        color: Colors.white,
      ),
    ),
  );

  /// ☀️ Tema Claro - Baseado no Dark Tech, mas com fundo claro
  static ThemeData lightTechTheme = ThemeData(
    brightness: Brightness.light, // Define que o tema é claro
    scaffoldBackgroundColor: Colors.white, // Cor de fundo principal clara
    primaryColor: const Color(0xFF00CFFF), // Azul neon (mantido)
    
    // Paleta de cores adaptada para fundo claro
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF00CFFF), // Azul neon
      secondary: Color(0xFF8A2BE2), // Violeta neon
      tertiary: Color(0xFFFFD700), // Dourado
    ),
    
    fontFamily: 'Rajdhani', // Fonte padrão
    
    // Cores padrão para textos
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black), // Texto grande escuro
      bodyMedium: TextStyle(color: Colors.black87), // Texto médio escuro
    ),
    
    // Estilo da AppBar no tema claro
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white, // Fundo branco
      elevation: 0, // Sem sombra
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: 'Orbitron',
        fontWeight: FontWeight.bold,
        fontSize: 20,
        color: Colors.black, // Texto preto
      ),
      iconTheme: IconThemeData(color: Colors.black), // Ícones escuros
    ),
  );
}
