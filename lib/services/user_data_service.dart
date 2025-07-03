import '../models/trip.dart';
import '../models/note.dart';
import '../models/photo.dart';
import 'user_service.dart';
import 'trip_service.dart';
import 'note_service.dart';
import 'photo_service.dart';
import 'storage_service.dart';

/// Serviço especializado para operações CRUD relacionadas a dados do usuário
/// Gerencia as relações entre usuários e suas viagens, anotações e fotos
class UserDataService {
  static const String _userTripsKey = 'user_trips_mapping';
  static const String _userNotesKey = 'user_notes_mapping';
  static const String _userPhotosKey = 'user_photos_mapping';

  // ==================== VIAGENS DO USUÁRIO ====================

  /// Criar nova viagem para o usuário atual
  static Future<String> createTripForCurrentUser({
    required String title,
    required String destination,
    required String description,
    DateTime? date,
    String? imagePath,
    List<String>? photos,
  }) async {
    try {
      final currentUser = await UserService.getCurrentUser();
      if (currentUser == null) {
        throw Exception('Usuário não está logado');
      }

      // Criar a viagem
      final trip = TripService.createTrip(
        title: title,
        destination: destination,
        description: description,
        date: date,
        imagePath: imagePath,
        photos: photos,
      );

      // Adicionar ao serviço de viagens
      await TripService.addTrip(trip);

      // Criar mapeamento usuário -> viagem
      await _addTripToUser(currentUser.id, trip.id);

      return trip.id;
    } catch (e) {
      throw Exception('Erro ao criar viagem para usuário: $e');
    }
  }

  /// Obter todas as viagens do usuário atual
  static Future<List<Trip>> getCurrentUserTrips() async {
    try {
      final currentUser = await UserService.getCurrentUser();
      if (currentUser == null) {
        throw Exception('Usuário não está logado');
      }

      return await getUserTrips(currentUser.id);
    } catch (e) {
      throw Exception('Erro ao obter viagens do usuário: $e');
    }
  }

  /// Obter viagens de um usuário específico
  static Future<List<Trip>> getUserTrips(String userId) async {
    try {
      final userTripIds = await _getUserTripIds(userId);
      final allTrips = await TripService.getAllTrips();

      return allTrips.where((trip) => userTripIds.contains(trip.id)).toList()
        ..sort((a, b) => b.date.compareTo(a.date));
    } catch (e) {
      throw Exception('Erro ao obter viagens do usuário: $e');
    }
  }

  /// Obter estatísticas de viagens do usuário atual
  static Future<Map<String, dynamic>> getCurrentUserTripStats() async {
    try {
      final trips = await getCurrentUserTrips();
      final now = DateTime.now();

      return {
        'totalTrips': trips.length,
        'tripsThisYear': trips
            .where((trip) => trip.date.year == now.year)
            .length,
        'favoriteDestinations': _getMostVisitedDestinations(trips),
        'totalPhotos': trips.fold(0, (sum, trip) => sum + trip.photos.length),
        'recentTrips': trips.take(5).map((t) => t.title).toList(),
        'nextTrip': trips.where((trip) => trip.date.isAfter(now)).isNotEmpty
            ? trips.where((trip) => trip.date.isAfter(now)).first.title
            : null,
      };
    } catch (e) {
      throw Exception('Erro ao obter estatísticas de viagens: $e');
    }
  }

  /// Atualizar viagem do usuário atual
  static Future<void> updateCurrentUserTrip(Trip updatedTrip) async {
    try {
      final currentUser = await UserService.getCurrentUser();
      if (currentUser == null) {
        throw Exception('Usuário não está logado');
      }

      // Verificar se a viagem pertence ao usuário
      final userTripIds = await _getUserTripIds(currentUser.id);
      if (!userTripIds.contains(updatedTrip.id)) {
        throw Exception('Viagem não pertence ao usuário');
      }

      // Atualizar viagem
      await TripService.updateTrip(updatedTrip);
    } catch (e) {
      throw Exception('Erro ao atualizar viagem do usuário: $e');
    }
  }

  /// Deletar viagem do usuário atual
  static Future<void> deleteCurrentUserTrip(String tripId) async {
    try {
      final currentUser = await UserService.getCurrentUser();
      if (currentUser == null) {
        throw Exception('Usuário não está logado');
      }

      // Verificar se a viagem pertence ao usuário
      final userTripIds = await _getUserTripIds(currentUser.id);
      if (!userTripIds.contains(tripId)) {
        throw Exception('Viagem não pertence ao usuário');
      }

      // Deletar anotações e fotos da viagem
      await deleteCurrentUserTripNotes(tripId);
      await deleteCurrentUserTripPhotos(tripId);

      // Deletar viagem
      await TripService.deleteTrip(tripId);

      // Remover mapeamento
      await _removeTripFromUser(currentUser.id, tripId);
    } catch (e) {
      throw Exception('Erro ao deletar viagem do usuário: $e');
    }
  }

  // ==================== ANOTAÇÕES DO USUÁRIO ====================

  /// Criar nova anotação para uma viagem do usuário atual
  static Future<String> createNoteForCurrentUser({
    required String tripId,
    required String title,
    required String content,
    List<String>? tags,
    String? imagePath,
  }) async {
    try {
      final currentUser = await UserService.getCurrentUser();
      if (currentUser == null) {
        throw Exception('Usuário não está logado');
      }

      // Verificar se a viagem pertence ao usuário
      final userTripIds = await _getUserTripIds(currentUser.id);
      if (!userTripIds.contains(tripId)) {
        throw Exception('Viagem não pertence ao usuário');
      }

      // Criar anotação
      final noteId = await NoteService.createNote(
        tripId: tripId,
        title: title,
        content: content,
        tags: tags,
        imagePath: imagePath,
      );

      // Criar mapeamento usuário -> anotação
      await _addNoteToUser(currentUser.id, noteId);

      return noteId;
    } catch (e) {
      throw Exception('Erro ao criar anotação para usuário: $e');
    }
  }

  /// Obter todas as anotações do usuário atual
  static Future<List<Note>> getCurrentUserNotes() async {
    try {
      final currentUser = await UserService.getCurrentUser();
      if (currentUser == null) {
        throw Exception('Usuário não está logado');
      }

      return await getUserNotes(currentUser.id);
    } catch (e) {
      throw Exception('Erro ao obter anotações do usuário: $e');
    }
  }

  /// Obter anotações de um usuário específico
  static Future<List<Note>> getUserNotes(String userId) async {
    try {
      final userNoteIds = await _getUserNoteIds(userId);
      final allNotes = await NoteService.getAllNotes();

      return allNotes.where((note) => userNoteIds.contains(note.id)).toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    } catch (e) {
      throw Exception('Erro ao obter anotações do usuário: $e');
    }
  }

  /// Obter anotações de uma viagem do usuário atual
  static Future<List<Note>> getCurrentUserTripNotes(String tripId) async {
    try {
      final currentUser = await UserService.getCurrentUser();
      if (currentUser == null) {
        throw Exception('Usuário não está logado');
      }

      // Verificar se a viagem pertence ao usuário
      final userTripIds = await _getUserTripIds(currentUser.id);
      if (!userTripIds.contains(tripId)) {
        throw Exception('Viagem não pertence ao usuário');
      }

      return await NoteService.getNotesByTripId(tripId);
    } catch (e) {
      throw Exception('Erro ao obter anotações da viagem: $e');
    }
  }

  /// Deletar anotação do usuário atual
  static Future<void> deleteCurrentUserNote(String noteId) async {
    try {
      final currentUser = await UserService.getCurrentUser();
      if (currentUser == null) {
        throw Exception('Usuário não está logado');
      }

      // Verificar se a anotação pertence ao usuário
      final userNoteIds = await _getUserNoteIds(currentUser.id);
      if (!userNoteIds.contains(noteId)) {
        throw Exception('Anotação não pertence ao usuário');
      }

      // Deletar anotação
      await NoteService.deleteNote(noteId);

      // Remover mapeamento
      await _removeNoteFromUser(currentUser.id, noteId);
    } catch (e) {
      throw Exception('Erro ao deletar anotação do usuário: $e');
    }
  }

  /// Deletar todas as anotações de uma viagem do usuário atual
  static Future<void> deleteCurrentUserTripNotes(String tripId) async {
    try {
      final notes = await getCurrentUserTripNotes(tripId);
      for (final note in notes) {
        await deleteCurrentUserNote(note.id);
      }
    } catch (e) {
      throw Exception('Erro ao deletar anotações da viagem: $e');
    }
  }

  // ==================== FOTOS DO USUÁRIO ====================

  /// Criar nova foto para uma viagem do usuário atual
  static Future<String> createPhotoForCurrentUser({
    required String tripId,
    required String path,
    String? caption,
    DateTime? takenAt,
    double? latitude,
    double? longitude,
    String? locationName,
    int? fileSize,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final currentUser = await UserService.getCurrentUser();
      if (currentUser == null) {
        throw Exception('Usuário não está logado');
      }

      // Verificar se a viagem pertence ao usuário
      final userTripIds = await _getUserTripIds(currentUser.id);
      if (!userTripIds.contains(tripId)) {
        throw Exception('Viagem não pertence ao usuário');
      }

      // Criar foto
      final photo = PhotoService.createPhoto(
        tripId: tripId,
        path: path,
        caption: caption,
        takenAt: takenAt,
        latitude: latitude,
        longitude: longitude,
        locationName: locationName,
        fileSize: fileSize,
        metadata: metadata,
      );

      // Adicionar ao serviço de fotos
      await PhotoService.addPhoto(photo);

      // Criar mapeamento usuário -> foto
      await _addPhotoToUser(currentUser.id, photo.id);

      return photo.id;
    } catch (e) {
      throw Exception('Erro ao criar foto para usuário: $e');
    }
  }

  /// Obter todas as fotos do usuário atual
  static Future<List<Photo>> getCurrentUserPhotos() async {
    try {
      final currentUser = await UserService.getCurrentUser();
      if (currentUser == null) {
        throw Exception('Usuário não está logado');
      }

      return await getUserPhotos(currentUser.id);
    } catch (e) {
      throw Exception('Erro ao obter fotos do usuário: $e');
    }
  }

  /// Obter fotos de um usuário específico
  static Future<List<Photo>> getUserPhotos(String userId) async {
    try {
      final userPhotoIds = await _getUserPhotoIds(userId);
      final allPhotos = await PhotoService.getAllPhotos();

      return allPhotos
          .where((photo) => userPhotoIds.contains(photo.id))
          .toList()
        ..sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt));
    } catch (e) {
      throw Exception('Erro ao obter fotos do usuário: $e');
    }
  }

  /// Obter fotos de uma viagem do usuário atual
  static Future<List<Photo>> getCurrentUserTripPhotos(String tripId) async {
    try {
      final currentUser = await UserService.getCurrentUser();
      if (currentUser == null) {
        throw Exception('Usuário não está logado');
      }

      // Verificar se a viagem pertence ao usuário
      final userTripIds = await _getUserTripIds(currentUser.id);
      if (!userTripIds.contains(tripId)) {
        throw Exception('Viagem não pertence ao usuário');
      }

      return await PhotoService.getPhotosByTripId(tripId);
    } catch (e) {
      throw Exception('Erro ao obter fotos da viagem: $e');
    }
  }

  /// Deletar foto do usuário atual
  static Future<void> deleteCurrentUserPhoto(String photoId) async {
    try {
      final currentUser = await UserService.getCurrentUser();
      if (currentUser == null) {
        throw Exception('Usuário não está logado');
      }

      // Verificar se a foto pertence ao usuário
      final userPhotoIds = await _getUserPhotoIds(currentUser.id);
      if (!userPhotoIds.contains(photoId)) {
        throw Exception('Foto não pertence ao usuário');
      }

      // Deletar foto
      await PhotoService.deletePhoto(photoId);

      // Remover mapeamento
      await _removePhotoFromUser(currentUser.id, photoId);
    } catch (e) {
      throw Exception('Erro ao deletar foto do usuário: $e');
    }
  }

  /// Deletar todas as fotos de uma viagem do usuário atual
  static Future<void> deleteCurrentUserTripPhotos(String tripId) async {
    try {
      final photos = await getCurrentUserTripPhotos(tripId);
      for (final photo in photos) {
        await deleteCurrentUserPhoto(photo.id);
      }
    } catch (e) {
      throw Exception('Erro ao deletar fotos da viagem: $e');
    }
  }

  // ==================== ESTATÍSTICAS GERAIS ====================

  /// Obter estatísticas completas do usuário atual
  static Future<Map<String, dynamic>> getCurrentUserCompleteStats() async {
    try {
      final trips = await getCurrentUserTrips();
      final notes = await getCurrentUserNotes();
      final photos = await getCurrentUserPhotos();

      final now = DateTime.now();
      final thisMonth = DateTime(now.year, now.month);

      return {
        'user': await UserService.getCurrentUser(),
        'trips': {
          'total': trips.length,
          'thisYear': trips.where((t) => t.date.year == now.year).length,
          'thisMonth': trips
              .where(
                (t) => t.date.year == now.year && t.date.month == now.month,
              )
              .length,
          'recent': trips.take(3).map((t) => t.title).toList(),
        },
        'notes': {
          'total': notes.length,
          'thisMonth': notes
              .where((n) => n.createdAt.isAfter(thisMonth))
              .length,
          'tags': _getUserUniqueTags(notes),
        },
        'photos': {
          'total': photos.length,
          'thisMonth': photos
              .where((p) => p.uploadedAt.isAfter(thisMonth))
              .length,
          'withLocation': photos.where((p) => p.hasLocation).length,
          'totalSize': photos.fold<int>(0, (sum, p) => sum + (p.fileSize ?? 0)),
        },
        'activity': {
          'lastTripDate': trips.isNotEmpty ? trips.first.date : null,
          'lastNoteDate': notes.isNotEmpty ? notes.first.updatedAt : null,
          'lastPhotoDate': photos.isNotEmpty ? photos.first.uploadedAt : null,
        },
      };
    } catch (e) {
      throw Exception('Erro ao obter estatísticas completas: $e');
    }
  }

  // ==================== MÉTODOS PRIVADOS ====================

  /// Adicionar viagem ao mapeamento do usuário
  static Future<void> _addTripToUser(String userId, String tripId) async {
    final mapping = await _getUserTripMapping();
    if (!mapping.containsKey(userId)) {
      mapping[userId] = [];
    }
    if (!mapping[userId]!.contains(tripId)) {
      mapping[userId]!.add(tripId);
      await StorageService.saveMap(_userTripsKey, mapping);
    }
  }

  /// Remover viagem do mapeamento do usuário
  static Future<void> _removeTripFromUser(String userId, String tripId) async {
    final mapping = await _getUserTripMapping();
    if (mapping.containsKey(userId)) {
      mapping[userId]!.remove(tripId);
      await StorageService.saveMap(_userTripsKey, mapping);
    }
  }

  /// Obter IDs das viagens do usuário
  static Future<List<String>> _getUserTripIds(String userId) async {
    final mapping = await _getUserTripMapping();
    return List<String>.from(mapping[userId] ?? []);
  }

  /// Obter mapeamento usuário -> viagens
  static Future<Map<String, List<String>>> _getUserTripMapping() async {
    try {
      final data = await StorageService.getMap(_userTripsKey) ?? {};
      return data.map((key, value) => MapEntry(key, List<String>.from(value)));
    } catch (e) {
      return {};
    }
  }

  /// Adicionar anotação ao mapeamento do usuário
  static Future<void> _addNoteToUser(String userId, String noteId) async {
    final mapping = await _getUserNoteMapping();
    if (!mapping.containsKey(userId)) {
      mapping[userId] = [];
    }
    if (!mapping[userId]!.contains(noteId)) {
      mapping[userId]!.add(noteId);
      await StorageService.saveMap(_userNotesKey, mapping);
    }
  }

  /// Remover anotação do mapeamento do usuário
  static Future<void> _removeNoteFromUser(String userId, String noteId) async {
    final mapping = await _getUserNoteMapping();
    if (mapping.containsKey(userId)) {
      mapping[userId]!.remove(noteId);
      await StorageService.saveMap(_userNotesKey, mapping);
    }
  }

  /// Obter IDs das anotações do usuário
  static Future<List<String>> _getUserNoteIds(String userId) async {
    final mapping = await _getUserNoteMapping();
    return List<String>.from(mapping[userId] ?? []);
  }

  /// Obter mapeamento usuário -> anotações
  static Future<Map<String, List<String>>> _getUserNoteMapping() async {
    try {
      final data = await StorageService.getMap(_userNotesKey) ?? {};
      return data.map((key, value) => MapEntry(key, List<String>.from(value)));
    } catch (e) {
      return {};
    }
  }

  /// Adicionar foto ao mapeamento do usuário
  static Future<void> _addPhotoToUser(String userId, String photoId) async {
    final mapping = await _getUserPhotoMapping();
    if (!mapping.containsKey(userId)) {
      mapping[userId] = [];
    }
    if (!mapping[userId]!.contains(photoId)) {
      mapping[userId]!.add(photoId);
      await StorageService.saveMap(_userPhotosKey, mapping);
    }
  }

  /// Remover foto do mapeamento do usuário
  static Future<void> _removePhotoFromUser(
    String userId,
    String photoId,
  ) async {
    final mapping = await _getUserPhotoMapping();
    if (mapping.containsKey(userId)) {
      mapping[userId]!.remove(photoId);
      await StorageService.saveMap(_userPhotosKey, mapping);
    }
  }

  /// Obter IDs das fotos do usuário
  static Future<List<String>> _getUserPhotoIds(String userId) async {
    final mapping = await _getUserPhotoMapping();
    return List<String>.from(mapping[userId] ?? []);
  }

  /// Obter mapeamento usuário -> fotos
  static Future<Map<String, List<String>>> _getUserPhotoMapping() async {
    try {
      final data = await StorageService.getMap(_userPhotosKey) ?? {};
      return data.map((key, value) => MapEntry(key, List<String>.from(value)));
    } catch (e) {
      return {};
    }
  }

  /// Obter destinos mais visitados
  static List<Map<String, dynamic>> _getMostVisitedDestinations(
    List<Trip> trips,
  ) {
    final destinationCount = <String, int>{};

    for (final trip in trips) {
      destinationCount[trip.destination] =
          (destinationCount[trip.destination] ?? 0) + 1;
    }

    final sortedDestinations = destinationCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedDestinations
        .take(5)
        .map((entry) => {'destination': entry.key, 'count': entry.value})
        .toList();
  }

  /// Obter tags únicas do usuário
  static List<String> _getUserUniqueTags(List<Note> notes) {
    final tags = <String>{};
    for (final note in notes) {
      tags.addAll(note.tags);
    }
    return tags.toList()..sort();
  }

  /// Atualizar anotação do usuário atual
  static Future<void> updateCurrentUserNote(Note updatedNote) async {
    try {
      final currentUser = await UserService.getCurrentUser();
      if (currentUser == null) {
        throw Exception('Usuário não está logado');
      }

      // Verificar se a anotação pertence ao usuário
      final userNoteIds = await _getUserNoteIds(currentUser.id);
      if (!userNoteIds.contains(updatedNote.id)) {
        throw Exception('Anotação não pertence ao usuário');
      }

      // Atualizar anotação
      await NoteService.updateNote(updatedNote);
    } catch (e) {
      throw Exception('Erro ao atualizar anotação do usuário: $e');
    }
  }

  /// Atualizar foto do usuário atual
  static Future<void> updateCurrentUserPhoto(Photo updatedPhoto) async {
    try {
      final currentUser = await UserService.getCurrentUser();
      if (currentUser == null) {
        throw Exception('Usuário não está logado');
      }

      // Verificar se a foto pertence ao usuário
      final userPhotoIds = await _getUserPhotoIds(currentUser.id);
      if (!userPhotoIds.contains(updatedPhoto.id)) {
        throw Exception('Foto não pertence ao usuário');
      }

      // Atualizar foto
      await PhotoService.updatePhoto(updatedPhoto);
    } catch (e) {
      throw Exception('Erro ao atualizar foto do usuário: $e');
    }
  }
}
