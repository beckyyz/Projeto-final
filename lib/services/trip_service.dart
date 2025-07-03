import '../models/trip.dart';
import 'storage_service.dart';

class TripService {
  static const String _tripsKey = 'trips';

  // Obter todas as viagens
  static Future<List<Trip>> getAllTrips() async {
    try {
      final List<Map<String, dynamic>> tripsData = await StorageService.getList(
        _tripsKey,
      );

      return tripsData.map((data) => Trip.fromMap(data)).toList();
    } catch (e) {
      // Se não houver viagens salvas, retorna a lista com viagens de exemplo
      return _getDefaultTrips();
    }
  }

  // Adicionar nova viagem
  static Future<void> addTrip(Trip trip) async {
    try {
      final trips = await getAllTrips();
      trips.add(trip);
      await _saveTrips(trips);
    } catch (e) {
      throw Exception('Erro ao adicionar viagem: $e');
    }
  }

  // Atualizar viagem existente
  static Future<void> updateTrip(Trip updatedTrip) async {
    try {
      final trips = await getAllTrips();
      final index = trips.indexWhere((trip) => trip.id == updatedTrip.id);

      if (index != -1) {
        trips[index] = updatedTrip;
        await _saveTrips(trips);
      } else {
        throw Exception('Viagem não encontrada');
      }
    } catch (e) {
      throw Exception('Erro ao atualizar viagem: $e');
    }
  }

  // Deletar viagem
  static Future<void> deleteTrip(String tripId) async {
    try {
      final trips = await getAllTrips();
      trips.removeWhere((trip) => trip.id == tripId);
      await _saveTrips(trips);
    } catch (e) {
      throw Exception('Erro ao deletar viagem: $e');
    }
  }

  // Obter viagem por ID
  static Future<Trip?> getTripById(String tripId) async {
    try {
      final trips = await getAllTrips();
      return trips.firstWhere(
        (trip) => trip.id == tripId,
        orElse: () => throw Exception('Viagem não encontrada'),
      );
    } catch (e) {
      return null;
    }
  }

  // Buscar viagens por destino
  static Future<List<Trip>> searchTripsByDestination(String destination) async {
    try {
      final trips = await getAllTrips();
      return trips
          .where(
            (trip) => trip.destination.toLowerCase().contains(
              destination.toLowerCase(),
            ),
          )
          .toList();
    } catch (e) {
      throw Exception('Erro na busca: $e');
    }
  }

  // Adicionar foto à viagem
  static Future<void> addPhotoToTrip(String tripId, String photoPath) async {
    try {
      final trip = await getTripById(tripId);
      if (trip != null) {
        final updatedPhotos = List<String>.from(trip.photos)..add(photoPath);
        final updatedTrip = trip.copyWith(photos: updatedPhotos);
        await updateTrip(updatedTrip);
      }
    } catch (e) {
      throw Exception('Erro ao adicionar foto à viagem: $e');
    }
  }

  // Salvar lista de viagens
  static Future<void> _saveTrips(List<Trip> trips) async {
    final tripsData = trips.map((trip) => trip.toMap()).toList();
    await StorageService.saveList(_tripsKey, tripsData);
  }

  // Viagens padrão (exemplo)
  static List<Trip> _getDefaultTrips() {
    return [
      Trip(
        id: '1',
        title: 'Férias de Verão',
        destination: 'Fernando de Noronha',
        date: DateTime(2023, 7, 15),
        description: 'Primeira visita às praias paradisíacas',
        imagePath: 'assets/images/noronha.jpeg',
        photos: [],
      ),
      Trip(
        id: '2',
        title: 'Aventura na Montanha',
        destination: 'Everest',
        date: DateTime(2023, 5, 22),
        description: 'Trilhas incríveis e paisagens deslumbrantes',
        imagePath: 'assets/images/everest.jpeg',
        photos: [],
      ),
    ];
  }

  // Criar nova viagem com dados validados
  static Trip createTrip({
    required String title,
    required String destination,
    required String description,
    DateTime? date,
    String? imagePath,
    List<String>? photos,
  }) {
    return Trip(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title.trim(),
      destination: destination.trim(),
      description: description.trim(),
      date: date ?? DateTime.now(),
      imagePath: imagePath ?? 'assets/images/aviao.webp',
      photos: photos ?? [],
    );
  }

  // READ - Obter viagens ordenadas por data
  static Future<List<Trip>> getTripsSortedByDate({
    bool ascending = false,
  }) async {
    try {
      final trips = await getAllTrips();
      trips.sort(
        (a, b) =>
            ascending ? a.date.compareTo(b.date) : b.date.compareTo(a.date),
      );
      return trips;
    } catch (e) {
      throw Exception('Erro ao ordenar viagens: $e');
    }
  }

  // READ - Obter viagens por período
  static Future<List<Trip>> getTripsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    try {
      final trips = await getAllTrips();
      return trips
          .where(
            (trip) =>
                trip.date.isAfter(start.subtract(const Duration(days: 1))) &&
                trip.date.isBefore(end.add(const Duration(days: 1))),
          )
          .toList();
    } catch (e) {
      throw Exception('Erro ao obter viagens por período: $e');
    }
  }

  // READ - Obter viagens recentes
  static Future<List<Trip>> getRecentTrips({int limit = 5}) async {
    try {
      final trips = await getTripsSortedByDate();
      return trips.take(limit).toList();
    } catch (e) {
      throw Exception('Erro ao obter viagens recentes: $e');
    }
  }

  // READ - Buscar viagens por texto (título, destino, descrição)
  static Future<List<Trip>> searchTrips(String query) async {
    try {
      final trips = await getAllTrips();
      final lowercaseQuery = query.toLowerCase();

      return trips
          .where(
            (trip) =>
                trip.title.toLowerCase().contains(lowercaseQuery) ||
                trip.destination.toLowerCase().contains(lowercaseQuery) ||
                trip.description.toLowerCase().contains(lowercaseQuery),
          )
          .toList();
    } catch (e) {
      throw Exception('Erro na busca: $e');
    }
  }

  // UPDATE - Atualizar dados específicos da viagem
  static Future<void> updateTripData({
    required String tripId,
    String? title,
    String? destination,
    String? description,
    DateTime? date,
    String? imagePath,
  }) async {
    try {
      final trip = await getTripById(tripId);
      if (trip == null) {
        throw Exception('Viagem não encontrada');
      }

      final updatedTrip = trip.copyWith(
        title: title,
        destination: destination,
        description: description,
        date: date,
        imagePath: imagePath,
      );

      await updateTrip(updatedTrip);
    } catch (e) {
      throw Exception('Erro ao atualizar dados da viagem: $e');
    }
  }

  // UPDATE - Adicionar múltiplas fotos à viagem
  static Future<void> addPhotosToTrip(
    String tripId,
    List<String> photoPaths,
  ) async {
    try {
      final trip = await getTripById(tripId);
      if (trip != null) {
        final updatedPhotos = List<String>.from(trip.photos)
          ..addAll(photoPaths);
        final updatedTrip = trip.copyWith(photos: updatedPhotos);
        await updateTrip(updatedTrip);
      }
    } catch (e) {
      throw Exception('Erro ao adicionar fotos à viagem: $e');
    }
  }

  // DELETE - Remover foto específica da viagem
  static Future<void> removePhotoFromTrip(
    String tripId,
    String photoPath,
  ) async {
    try {
      final trip = await getTripById(tripId);
      if (trip != null) {
        final updatedPhotos = List<String>.from(trip.photos)..remove(photoPath);
        final updatedTrip = trip.copyWith(photos: updatedPhotos);
        await updateTrip(updatedTrip);
      }
    } catch (e) {
      throw Exception('Erro ao remover foto da viagem: $e');
    }
  }

  // DELETE - Limpar todas as fotos da viagem
  static Future<void> clearTripPhotos(String tripId) async {
    try {
      final trip = await getTripById(tripId);
      if (trip != null) {
        final updatedTrip = trip.copyWith(photos: []);
        await updateTrip(updatedTrip);
      }
    } catch (e) {
      throw Exception('Erro ao limpar fotos da viagem: $e');
    }
  }

  // ESTATÍSTICAS - Obter estatísticas das viagens
  static Future<Map<String, dynamic>> getTripsStats() async {
    try {
      final trips = await getAllTrips();
      final destinations = <String>{};
      int totalPhotos = 0;

      for (final trip in trips) {
        destinations.add(trip.destination);
        totalPhotos += trip.photos.length;
      }

      final now = DateTime.now();
      final thisYear = trips.where((trip) => trip.date.year == now.year).length;
      final thisMonth = trips
          .where(
            (trip) =>
                trip.date.year == now.year && trip.date.month == now.month,
          )
          .length;

      return {
        'totalTrips': trips.length,
        'uniqueDestinations': destinations.length,
        'totalPhotos': totalPhotos,
        'tripsThisYear': thisYear,
        'tripsThisMonth': thisMonth,
        'averagePhotosPerTrip': trips.isNotEmpty
            ? totalPhotos / trips.length
            : 0,
        'destinations': destinations.toList(),
      };
    } catch (e) {
      throw Exception('Erro ao obter estatísticas: $e');
    }
  }

  // UTILITÁRIO - Duplicar viagem
  static Future<String> duplicateTrip(String tripId) async {
    try {
      final trip = await getTripById(tripId);
      if (trip == null) {
        throw Exception('Viagem não encontrada');
      }

      final duplicatedTrip = Trip(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: '${trip.title} (Cópia)',
        destination: trip.destination,
        date: DateTime.now(),
        description: trip.description,
        imagePath: trip.imagePath,
        photos: [], // Nova viagem começa sem fotos
      );

      await addTrip(duplicatedTrip);
      return duplicatedTrip.id;
    } catch (e) {
      throw Exception('Erro ao duplicar viagem: $e');
    }
  }

  // UTILITÁRIO - Obter destinos únicos
  static Future<List<String>> getUniqueDestinations() async {
    try {
      final trips = await getAllTrips();
      final destinations = trips
          .map((trip) => trip.destination)
          .toSet()
          .toList();
      destinations.sort();
      return destinations;
    } catch (e) {
      throw Exception('Erro ao obter destinos: $e');
    }
  }

  // UTILITÁRIO - Verificar se existe viagem com título
  static Future<bool> tripTitleExists(String title, {String? excludeId}) async {
    try {
      final trips = await getAllTrips();
      return trips.any(
        (trip) =>
            trip.title.toLowerCase() == title.toLowerCase() &&
            trip.id != excludeId,
      );
    } catch (e) {
      return false;
    }
  }

  // UTILITÁRIO - Obter viagens por ano
  static Future<Map<int, List<Trip>>> getTripsByYear() async {
    try {
      final trips = await getAllTrips();
      final tripsByYear = <int, List<Trip>>{};

      for (final trip in trips) {
        final year = trip.date.year;
        if (!tripsByYear.containsKey(year)) {
          tripsByYear[year] = [];
        }
        tripsByYear[year]!.add(trip);
      }

      return tripsByYear;
    } catch (e) {
      throw Exception('Erro ao agrupar viagens por ano: $e');
    }
  }
}
