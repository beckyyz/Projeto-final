import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Gerenciador de tema que permite alternar entre temas claros e escuros
/// e persistir a escolha do usuário
class ThemeManager with ChangeNotifier {
  // Chave para armazenar a preferência de tema
  static const String _themeModeKey = 'theme_mode';

  // Modo de tema atual
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  // Verificar se está no modo escuro
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  // Construtor que carrega o tema salvo
  ThemeManager() {
    _loadThemeMode();
  }

  /// Carregar modo de tema das preferências
  void _loadThemeMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final savedMode = prefs.getString(_themeModeKey);

    if (savedMode != null) {
      _themeMode = _themeStringToEnum(savedMode);
      notifyListeners();
    }
  }

  /// Converter string para enum ThemeMode
  ThemeMode _themeStringToEnum(String themeString) {
    switch (themeString) {
      case 'dark':
        return ThemeMode.dark;
      case 'light':
        return ThemeMode.light;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.light;
    }
  }

  /// Alternar entre os temas claro e escuro
  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    _saveThemeMode();
    notifyListeners();
  }

  /// Definir um tema específico
  void setTheme(ThemeMode mode) {
    _themeMode = mode;
    _saveThemeMode();
    notifyListeners();
  }

  /// Salvar o modo de tema nas preferências
  void _saveThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    String themeString;

    switch (_themeMode) {
      case ThemeMode.dark:
        themeString = 'dark';
        break;
      case ThemeMode.light:
        themeString = 'light';
        break;
      case ThemeMode.system:
        themeString = 'system';
        break;
    }

    await prefs.setString(_themeModeKey, themeString);
  }
}
