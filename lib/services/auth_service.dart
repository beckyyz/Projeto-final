import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/database_service.dart'; // Certifique-se de que o caminho está correto
import '../services/user_service.dart';

class AuthService {
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _userEmailKey = 'user_email';
  static const String _userNameKey = 'user_name';
  static const String _firstTimeKey = 'first_time';

  // Verificar se é a primeira vez que o usuário abre o app
  static Future<bool> isFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_firstTimeKey) ?? true;
  }

  // Marcar que o usuário já passou pelo onboarding
  static Future<void> setFirstTimeComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_firstTimeKey, false);
  }

  // Verificar se o usuário está logado
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  // Fazer login
  static Future<bool> login(String email, String password) async {
    // Autenticação real usando o banco SQLite
    final userMap = await DatabaseService.buscarUsuarioPorEmailESenha(email, password);
    if (userMap != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isLoggedInKey, true);
      await prefs.setString(_userEmailKey, email);
      await prefs.setString(_userNameKey, userMap['name'] ?? '');
      return true;
    }
    return false;
  }

  // Fazer registro
  static Future<bool> register(
    String name,
    String email,
    String password,
  ) async {
    try {
      await UserService.createUser(
        name: name,
        email: email,
        password: password,
      );
      return true;
    } catch (e, s) {
      print('Erro ao registrar usuário: $e\n$s');
      return false;
    }
  }

  // Fazer logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, false);
    await prefs.remove(_userEmailKey);
    await prefs.remove(_userNameKey);
  }

  // Obter dados do usuário atual
  static Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;

    if (!isLoggedIn) return null;

    final email = prefs.getString(_userEmailKey);
    final name = prefs.getString(_userNameKey);

    if (email != null) {
      return User(
        id: email, // Usando email como ID temporário
        email: email,
        name: name ?? '',
        password: '', // Adicione um valor padrão ou recupere a senha se possível
        createdAt: DateTime.now(),
      );
    }

    return null;
  }
}
