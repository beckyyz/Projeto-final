import '../models/user.dart';
import 'storage_service.dart';
import 'auth_service.dart';
import 'package:diario_viagem/services/database_service.dart';

class UserService {
  static const String _usersKey = 'users';
  static const String _currentUserKey = 'current_user';

  // CREATE - Criar novo usuário
  static Future<String> createUser({
    required String name,
    required String email,
    required String password,
    String? profileImagePath,
  }) async {
    try {
      final userId = DateTime.now().millisecondsSinceEpoch.toString();
      final user = User(
        id: userId,
        email: email,
        name: name,
        password: password,
        profileImagePath: profileImagePath,
        createdAt: DateTime.now(),
      );

      // Verificar se email já existe
      final existing = await DatabaseService.buscarUsuarioPorEmail(email);
      if (existing != null) {
        throw Exception('Email já está em uso');
      }

      await DatabaseService.inserirUsuario(user.toMap());
      return userId;
    } catch (e) {
      throw Exception('Erro ao criar usuário: $e');
    }
  }

  // READ - Obter todos os usuários
  static Future<List<User>> getAllUsers() async {
    try {
      final List<Map<String, dynamic>> usersData = await StorageService.getList(
        _usersKey,
      );

      return usersData.map((data) => User.fromMap(data)).toList();
    } catch (e) {
      return [];
    }
  }

  // READ - Obter usuário por ID
  static Future<User?> getUserById(String userId) async {
    try {
      final users = await getAllUsers();
      return users.firstWhere(
        (user) => user.id == userId,
        orElse: () => throw Exception('Usuário não encontrado'),
      );
    } catch (e) {
      return null;
    }
  }

  // READ - Obter usuário por email
  static Future<User?> getUserByEmail(String email) async {
    try {
      final users = await getAllUsers();
      return users.firstWhere(
        (user) => user.email == email,
        orElse: () => throw Exception('Usuário não encontrado'),
      );
    } catch (e) {
      return null;
    }
  }

  // READ - Obter usuário atual
  static Future<User?> getCurrentUser() async {
    try {
      // Usar o AuthService para verificar se o usuário está logado
      final isLoggedIn = await AuthService.isLoggedIn();
      if (!isLoggedIn) {
        return null;
      }

      // Obter dados do usuário do AuthService
      return await AuthService.getCurrentUser();
    } catch (e) {
      return null;
    }
  }

  // UPDATE - Atualizar usuário
  static Future<void> updateUser(User updatedUser) async {
    try {
      final users = await getAllUsers();
      final index = users.indexWhere((user) => user.id == updatedUser.id);

      if (index != -1) {
        users[index] = updatedUser.copyWith(updatedAt: DateTime.now());
        await _saveUsers(users);

        // Atualizar usuário atual se for o mesmo
        final currentUser = await getCurrentUser();
        if (currentUser?.id == updatedUser.id) {
          await setCurrentUser(users[index]);
        }
      } else {
        throw Exception('Usuário não encontrado');
      }
    } catch (e) {
      throw Exception('Erro ao atualizar usuário: $e');
    }
  }

  // UPDATE - Atualizar perfil do usuário atual
  static Future<void> updateCurrentUserProfile({
    String? name,
    String? profileImagePath,
  }) async {
    try {
      final currentUser = await getCurrentUser();
      if (currentUser == null) {
        throw Exception('Nenhum usuário logado');
      }

      final updatedUser = currentUser.copyWith(
        name: name,
        profileImagePath: profileImagePath,
        updatedAt: DateTime.now(),
      );

      await updateUser(updatedUser);
    } catch (e) {
      throw Exception('Erro ao atualizar perfil: $e');
    }
  }

  // UPDATE - Alterar senha (simulado)
  static Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      // Em um app real, você validaria a senha atual aqui
      await Future.delayed(const Duration(milliseconds: 500));

      // Por enquanto, apenas simula a alteração
      final currentUser = await getCurrentUser();
      if (currentUser == null) {
        throw Exception('Nenhum usuário logado');
      }

      // Aqui você salvaria a nova senha de forma segura
      // Para este exemplo, apenas simulamos o sucesso
    } catch (e) {
      throw Exception('Erro ao alterar senha: $e');
    }
  }

  // DELETE - Deletar usuário
  static Future<void> deleteUser(String userId) async {
    try {
      final users = await getAllUsers();
      users.removeWhere((user) => user.id == userId);
      await _saveUsers(users);

      // Se for o usuário atual, fazer logout
      final currentUser = await getCurrentUser();
      if (currentUser?.id == userId) {
        await logout();
      }
    } catch (e) {
      throw Exception('Erro ao deletar usuário: $e');
    }
  }

  // DELETE - Deletar conta atual
  static Future<void> deleteCurrentAccount() async {
    try {
      final currentUser = await getCurrentUser();
      if (currentUser == null) {
        throw Exception('Nenhum usuário logado');
      }

      await deleteUser(currentUser.id);
    } catch (e) {
      throw Exception('Erro ao deletar conta: $e');
    }
  }

  // AUTENTICAÇÃO - Definir usuário atual
  static Future<void> setCurrentUser(User user) async {
    try {
      await StorageService.saveMap(_currentUserKey, user.toMap());
    } catch (e) {
      throw Exception('Erro ao definir usuário atual: $e');
    }
  }

  // AUTENTICAÇÃO - Fazer logout
  static Future<void> logout() async {
    try {
      await StorageService.remove(_currentUserKey);
    } catch (e) {
      throw Exception('Erro ao fazer logout: $e');
    }
  }

  // AUTENTICAÇÃO - Verificar se está logado
  static Future<bool> isLoggedIn() async {
    try {
      final user = await getCurrentUser();
      return user != null;
    } catch (e) {
      return false;
    }
  }

  // BUSCA - Buscar usuários por nome
  static Future<List<User>> searchUsersByName(String query) async {
    try {
      final users = await getAllUsers();
      final lowercaseQuery = query.toLowerCase();

      return users
          .where((user) => user.name.toLowerCase().contains(lowercaseQuery))
          .toList();
    } catch (e) {
      throw Exception('Erro na busca: $e');
    }
  }

  // VALIDAÇÃO - Verificar se email existe
  static Future<bool> emailExists(String email) async {
    try {
      final user = await getUserByEmail(email);
      return user != null;
    } catch (e) {
      return false;
    }
  }

  // ESTATÍSTICAS - Obter estatísticas do usuário
  static Future<Map<String, dynamic>> getUserStats(String userId) async {
    try {
      // Aqui você integraria com outros serviços para obter estatísticas
      return {
        'totalTrips': 0,
        'totalPhotos': 0,
        'totalNotes': 0,
        'memberSince': DateTime.now(),
      };
    } catch (e) {
      throw Exception('Erro ao obter estatísticas: $e');
    }
  }

  // PRIVADOS - Salvar lista de usuários
  static Future<void> _saveUsers(List<User> users) async {
    final usersData = users.map((user) => user.toMap()).toList();
    await StorageService.saveList(_usersKey, usersData);
  }

  // UTILITÁRIO - Gerar ID único para usuário
  static String generateUserId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  // UPDATE - Atualizar foto de perfil do usuário atual
  static Future<void> updateProfilePhoto(String photoPath) async {
    try {
      final currentUser = await getCurrentUser();
      if (currentUser == null) {
        throw Exception('Nenhum usuário logado');
      }

      await updateCurrentUserProfile(profileImagePath: photoPath);
    } catch (e) {
      throw Exception('Erro ao atualizar foto de perfil: $e');
    }
  }

  // UPDATE - Remover foto de perfil do usuário atual
  static Future<void> removeProfilePhoto() async {
    try {
      final currentUser = await getCurrentUser();
      if (currentUser == null) {
        throw Exception('Nenhum usuário logado');
      }

      await updateCurrentUserProfile(profileImagePath: null);
    } catch (e) {
      throw Exception('Erro ao remover foto de perfil: $e');
    }
  }
}
