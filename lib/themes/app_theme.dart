import 'package:flutter/material.dart';

/// Classe que gerencia os temas do aplicativo
class AppTheme {
  // Fontes personalizadas - comentadas até que os arquivos estejam disponíveis
  // static const String _bodyFont = 'Poppins';
  // static const String _headingFont = 'Montserrat';

  // Cores primárias
  static const Color _lightPrimaryColor = Colors.blue;
  static const Color _darkPrimaryColor = Color(
    0xFF2196F3,
  ); // Azul mais vibrante para dark mode

  // Cores de fundo
  static const Color _lightBackgroundColor = Color(0xFFf0f4f8);
  static const Color _darkBackgroundColor = Color(0xFF121212);

  // Cores de superfície
  static const Color _lightSurfaceColor = Colors.white;
  static const Color _darkSurfaceColor = Color(0xFF1E1E1E);

  // Cores secundárias
  static const Color _lightAccentColor = Color(0xFF03A9F4);
  static const Color _darkAccentColor = Color(0xFF4FC3F7);

  /// Tema claro para o aplicativo
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    // fontFamily: _bodyFont, // Comentado temporariamente
    primaryColor: _lightPrimaryColor,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _lightPrimaryColor,
      brightness: Brightness.light,
      secondary: _lightAccentColor,
    ),
    scaffoldBackgroundColor: _lightBackgroundColor,
    cardColor: _lightSurfaceColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: _lightPrimaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: _lightPrimaryColor,
      foregroundColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _lightPrimaryColor,
        foregroundColor: Colors.white,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: _lightPrimaryColor),
    ),
    dialogTheme: DialogThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    // Definição de estilo de texto padrão (sem fontes personalizadas por enquanto)
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontWeight: FontWeight.bold),
      displayMedium: TextStyle(fontWeight: FontWeight.bold),
      displaySmall: TextStyle(fontWeight: FontWeight.bold),
      headlineLarge: TextStyle(fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(fontWeight: FontWeight.bold),
      headlineSmall: TextStyle(fontWeight: FontWeight.w500),
      titleLarge: TextStyle(fontWeight: FontWeight.w500),
      titleMedium: TextStyle(fontWeight: FontWeight.w500),
      titleSmall: TextStyle(fontWeight: FontWeight.w500),
      bodyLarge: TextStyle(),
      bodyMedium: TextStyle(),
      bodySmall: TextStyle(color: Colors.black54, fontSize: 14),
      labelLarge: TextStyle(fontWeight: FontWeight.w500),
      labelMedium: TextStyle(),
      labelSmall: TextStyle(),
    ),
  );

  /// Tema escuro para o aplicativo
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    // fontFamily: _bodyFont,  // Comentado temporariamente
    primaryColor: _darkPrimaryColor,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _darkPrimaryColor,
      brightness: Brightness.dark,
      secondary: _darkAccentColor,
      background: _darkBackgroundColor,
      surface: _darkSurfaceColor,
      onSurface: Colors.white, // Texto sobre superfícies (cards, etc)
      onBackground: Colors.white, // Texto sobre o fundo
      onPrimary: Colors.white, // Texto sobre a cor primária
      onSecondary: Colors.white, // Texto sobre a cor secundária
    ),
    scaffoldBackgroundColor: _darkBackgroundColor,
    cardColor: _darkSurfaceColor,
    popupMenuTheme: PopupMenuThemeData(
      color: _darkSurfaceColor,
      textStyle: const TextStyle(color: Colors.white),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: _darkSurfaceColor,
      foregroundColor: Colors.white,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: _darkPrimaryColor,
      foregroundColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _darkPrimaryColor,
        foregroundColor: Colors.white,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: _darkAccentColor),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: _darkSurfaceColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      titleTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      contentTextStyle: const TextStyle(color: Colors.white, fontSize: 16),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: _darkSurfaceColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      contentTextStyle: const TextStyle(color: Colors.white),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: _darkSurfaceColor,
    ),
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: _darkSurfaceColor,
      indicatorColor: _darkPrimaryColor,
      labelTextStyle: MaterialStatePropertyAll(TextStyle(color: Colors.white)),
    ),
    listTileTheme: const ListTileThemeData(
      tileColor: _darkSurfaceColor,
      textColor: Colors.white,
      iconColor: Colors.white,
    ),
    // Garante texto legível em temas escuros (fontes personalizadas temporariamente desativadas)
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      displayMedium: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      displaySmall: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      headlineLarge: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      headlineSmall: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w500,
      ),
      titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
      titleMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
      titleSmall: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white),
      bodySmall: TextStyle(color: Colors.white, fontSize: 14),
      labelLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
      labelMedium: TextStyle(color: Colors.white),
      labelSmall: TextStyle(color: Colors.white),
    ),
  );
}
