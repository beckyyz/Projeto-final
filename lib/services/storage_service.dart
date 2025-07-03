import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StorageService {
  // Salvar string
  static Future<void> saveString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  // Obter string
  static Future<String?> getString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  // Salvar boolean
  static Future<void> saveBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  // Obter boolean
  static Future<bool> getBool(String key, {bool defaultValue = false}) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? defaultValue;
  }

  // Salvar int
  static Future<void> saveInt(String key, int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, value);
  }

  // Obter int
  static Future<int> getInt(String key, {int defaultValue = 0}) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(key) ?? defaultValue;
  }

  // Salvar lista de objetos (como JSON)
  static Future<void> saveList(
    String key,
    List<Map<String, dynamic>> list,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonString = json.encode(list);
    await prefs.setString(key, jsonString);
  }

  // Obter lista de objetos
  static Future<List<Map<String, dynamic>>> getList(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(key);

    if (jsonString != null) {
      final List<dynamic> decodedList = json.decode(jsonString);
      return decodedList
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }

    return [];
  }

  // Salvar Map como JSON
  static Future<void> saveMap(String key, Map<String, dynamic> map) async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonString = json.encode(map);
    await prefs.setString(key, jsonString);
  }

  // Obter Map
  static Future<Map<String, dynamic>?> getMap(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(key);

    if (jsonString != null) {
      return Map<String, dynamic>.from(json.decode(jsonString));
    }

    return null;
  }

  // Remover chave
  static Future<void> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  // Limpar todos os dados
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Verificar se a chave existe
  static Future<bool> containsKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(key);
  }

  // Obter todas as chaves
  static Future<Set<String>> getAllKeys() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getKeys();
  }
}
