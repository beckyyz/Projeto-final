import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

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
    // Simular validação de login (aqui você integraria com um backend real)
    await Future.delayed(const Duration(seconds: 2));

    if (email.isNotEmpty && password.length >= 6) {
      final prefs = await SharedPreferences.getInstance();

      // Verificar se o usuário existe (foi registrado anteriormente)
      final registeredEmail = prefs.getString(_userEmailKey);
      final registeredName = prefs.getString(_userNameKey);

      // Apenas permitir login se o usuário foi registrado E o email corresponde
      if (registeredEmail == email && registeredName != null) {
        await prefs.setBool(_isLoggedInKey, true);
        return true;
      }
    }

    // Se chegou aqui, credenciais são inválidas ou usuário não existe
    return false;
  }

  // Fazer registro
  static Future<bool> register(
    String name,
    String email,
    String password,
  ) async {
    // Simular registro (aqui você integraria com um backend real)
    await Future.delayed(const Duration(seconds: 2));

    // Por enquanto, aceita qualquer dados válidos
    if (name.isNotEmpty && email.isNotEmpty && password.length >= 6) {
      final prefs = await SharedPreferences.getInstance();
      // Salvar dados do usuário sem fazer login automático
      await prefs.setString(_userNameKey, name);
      await prefs.setString(_userEmailKey, email);
      // NÃO fazer login automático - usuário deve fazer login manualmente
      await prefs.setBool(_isLoggedInKey, false);
      return true;
    }

    return false;
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
        createdAt: DateTime.now(),
      );
    }

    return null;
  }
}
