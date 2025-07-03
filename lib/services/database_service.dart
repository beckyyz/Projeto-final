import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static Database? _db;

  // Retorna a instância do banco de dados
  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  // Inicializa o banco de dados
  static Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'diario_viagem.db');
    return await openDatabase(
      path,
      version: 2, // aumente a versão para forçar o upgrade
      onCreate: (db, version) async {
        // Tabela de viagens
        await db.execute('''
          CREATE TABLE viagens(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            titulo TEXT,
            descricao TEXT,
            dataInicio TEXT,
            dataFim TEXT
          )
        ''');
        // Tabela de usuários
        await db.execute('''
          CREATE TABLE usuarios(
            id TEXT PRIMARY KEY,
            name TEXT,
            email TEXT,
            password TEXT,
            profileImagePath TEXT,
            createdAt TEXT,
            updatedAt TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE usuarios ADD COLUMN updatedAt TEXT');
        }
      },
    );
  }

  // Métodos para viagens
  static Future<int> inserirViagem(Map<String, dynamic> viagem) async {
    final db = await database;
    return await db.insert('viagens', viagem);
  }

  static Future<List<Map<String, dynamic>>> listarViagens() async {
    final db = await database;
    return await db.query('viagens');
  }

  static Future<int> atualizarViagem(int id, Map<String, dynamic> viagem) async {
    final db = await database;
    return await db.update('viagens', viagem, where: 'id = ?', whereArgs: [id]);
  }

  static Future<int> deletarViagem(int id) async {
    final db = await database;
    return await db.delete('viagens', where: 'id = ?', whereArgs: [id]);
  }

  // Métodos para usuários
  static Future<void> inserirUsuario(Map<String, dynamic> usuario) async {
    final db = await database;
    await db.insert('usuarios', usuario, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<Map<String, dynamic>>> listarUsuarios() async {
    final db = await database;
    return await db.query('usuarios');
  }

  static Future<Map<String, dynamic>?> buscarUsuarioPorEmailESenha(String email, String password) async {
    final db = await database;
    final result = await db.query(
      'usuarios',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    return result.isNotEmpty ? result.first : null;
  }

  static Future<Map<String, dynamic>?> buscarUsuarioPorEmail(String email) async {
    final db = await database;
    final result = await db.query('usuarios', where: 'email = ?', whereArgs: [email]);
    return result.isNotEmpty ? result.first : null;
  }

  static Future<void> atualizarUsuario(Map<String, dynamic> usuario) async {
    final db = await database;
    await db.update('usuarios', usuario, where: 'id = ?', whereArgs: [usuario['id']]);
  }

  static Future<void> deletarUsuario(String id) async {
    final db = await database;
    await db.delete('usuarios', where: 'id = ?', whereArgs: [id]);
  }
}