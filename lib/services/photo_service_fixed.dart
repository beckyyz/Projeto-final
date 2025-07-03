import 'dart:io';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../models/photo.dart';
import 'storage_service.dart';

/// Serviço para gerenciar operações CRUD de fotos
class PhotoService {
  static const String _photosKey = 'photos';

  // ==================== CRUD BÁSICO ====================

  /// Criar nova foto
  static Photo createPhoto({
    required String path,
    required String tripId,
    String? caption,
    String? locationName,
    double? latitude,
    double? longitude,
    DateTime? takenAt,
    int? fileSize,
  }) {
    return Photo(
      id: generatePhotoId(),
      path: path,
      tripId: tripId,
      caption: caption,
      locationName: locationName,
      latitude: latitude,
      longitude: longitude,
      takenAt: takenAt ?? DateTime.now(),
      uploadedAt: DateTime.now(),
      fileSize: fileSize,
    );
  }

  /// Adicionar nova foto à lista
  static Future<void> addPhoto(Photo photo) async {
    try {
      final photos = await getAllPhotos();
      photos.add(photo);
      await _savePhotos(photos);
    } catch (e) {
      throw Exception('Erro ao adicionar foto: $e');
    }
  }

  /// Obter todas as fotos
  static Future<List<Photo>> getAllPhotos() async {
    try {
      final photosData = await StorageService.getList(_photosKey);
      return photosData.map((data) => Photo.fromMap(data)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Obter foto por ID
  static Future<Photo?> getPhotoById(String id) async {
    try {
      final photos = await getAllPhotos();
      return photos.where((photo) => photo.id == id).firstOrNull;
    } catch (e) {
      return null;
    }
  }

  /// Atualizar foto existente
  static Future<void> updatePhoto(Photo updatedPhoto) async {
    try {
      final photos = await getAllPhotos();
      final index = photos.indexWhere((photo) => photo.id == updatedPhoto.id);

      if (index != -1) {
        photos[index] = updatedPhoto;
        await _savePhotos(photos);
      } else {
        throw Exception('Foto não encontrada');
      }
    } catch (e) {
      throw Exception('Erro ao atualizar foto: $e');
    }
  }

  /// Deletar foto por ID
  static Future<void> deletePhoto(String id) async {
    try {
      final photos = await getAllPhotos();
      final photoToDelete = photos.where((photo) => photo.id == id).firstOrNull;

      if (photoToDelete != null) {
        // Deletar arquivo físico
        await deletePhotoFile(photoToDelete.path);

        // Remover da lista
        photos.removeWhere((photo) => photo.id == id);
        await _savePhotos(photos);
      } else {
        throw Exception('Foto não encontrada');
      }
    } catch (e) {
      throw Exception('Erro ao deletar foto: $e');
    }
  }

  // ==================== OPERAÇÕES ESPECÍFICAS ====================

  /// Obter fotos por critério de busca
  static Future<List<Photo>> searchPhotos({
    String? caption,
    String? locationName,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      final photos = await getAllPhotos();

      return photos.where((photo) {
        bool matches = true;

        if (caption != null && photo.caption != null) {
          matches =
              matches &&
              photo.caption!.toLowerCase().contains(caption.toLowerCase());
        }

        if (locationName != null && photo.locationName != null) {
          matches =
              matches &&
              photo.locationName!.toLowerCase().contains(
                locationName.toLowerCase(),
              );
        }

        if (fromDate != null) {
          matches = matches && photo.takenAt.isAfter(fromDate);
        }

        if (toDate != null) {
          matches = matches && photo.takenAt.isBefore(toDate);
        }

        return matches;
      }).toList();
    } catch (e) {
      throw Exception('Erro na busca: $e');
    }
  }

  /// Obter fotos com localização
  static Future<List<Photo>> getPhotosWithLocation() async {
    try {
      final photos = await getAllPhotos();
      return photos.where((photo) => photo.hasLocation).toList();
    } catch (e) {
      throw Exception('Erro ao obter fotos com localização: $e');
    }
  }

  /// Obter fotos por período
  static Future<List<Photo>> getPhotosByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    try {
      final photos = await getAllPhotos();
      return photos.where((photo) {
        return photo.takenAt.isAfter(start) && photo.takenAt.isBefore(end);
      }).toList();
    } catch (e) {
      throw Exception('Erro ao obter fotos por período: $e');
    }
  }

  /// Obter fotos recentes (últimos 30 dias)
  static Future<List<Photo>> getRecentPhotos() async {
    try {
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      return await getPhotosByDateRange(thirtyDaysAgo, DateTime.now());
    } catch (e) {
      throw Exception('Erro ao obter fotos recentes: $e');
    }
  }

  // ==================== UTILITÁRIOS DE ARQUIVO ====================

  /// Salvar lista de fotos no dispositivo
  static Future<List<String>> savePhotosToDevice(
    List<XFile> photos, {
    String? tripId,
  }) async {
    List<String> savedPaths = [];

    try {
      final directory = await getApplicationDocumentsDirectory();
      final photosDir = Directory('${directory.path}/photos');

      if (!await photosDir.exists()) {
        await photosDir.create(recursive: true);
      }

      for (int i = 0; i < photos.length; i++) {
        final XFile photo = photos[i];
        final String timestamp = DateTime.now().millisecondsSinceEpoch
            .toString();
        final String fileName = '${tripId ?? timestamp}_$i.jpg';
        final String savedPath = '${photosDir.path}/$fileName';

        final File file = File(savedPath);
        final Uint8List photoBytes = await photo.readAsBytes();
        await file.writeAsBytes(photoBytes);

        savedPaths.add(savedPath);
      }
    } catch (e) {
      throw Exception('Erro ao salvar fotos: $e');
    }

    return savedPaths;
  }

  /// Salvar uma única foto
  static Future<String?> saveSinglePhoto(XFile photo, {String? prefix}) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final photosDir = Directory('${directory.path}/photos');

      if (!await photosDir.exists()) {
        await photosDir.create(recursive: true);
      }

      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String fileName = '${prefix ?? 'photo'}_$timestamp.jpg';
      final String savedPath = '${photosDir.path}/$fileName';

      final File file = File(savedPath);
      final Uint8List photoBytes = await photo.readAsBytes();
      await file.writeAsBytes(photoBytes);

      return savedPath;
    } catch (e) {
      throw Exception('Erro ao salvar foto: $e');
    }
  }

  /// Deletar arquivo de foto do sistema
  static Future<bool> deletePhotoFile(String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Verificar se a foto existe no sistema
  static Future<bool> photoFileExists(String imagePath) async {
    try {
      final file = File(imagePath);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  /// Obter tamanho da foto em bytes
  static Future<int> getPhotoFileSize(String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        return await file.length();
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  // ==================== ESTATÍSTICAS ====================

  /// Obter estatísticas das fotos
  static Future<Map<String, dynamic>> getPhotoStatistics() async {
    try {
      final photos = await getAllPhotos();

      if (photos.isEmpty) {
        return {
          'totalPhotos': 0,
          'totalSize': 0,
          'photosWithLocation': 0,
          'photosThisMonth': 0,
          'averageFileSize': 0,
        };
      }

      int totalSize = 0;
      for (final photo in photos) {
        totalSize += await getPhotoFileSize(photo.path);
      }

      return {
        'totalPhotos': photos.length,
        'totalSize': totalSize,
        'photosWithLocation': photos.where((p) => p.hasLocation).length,
        'photosThisMonth': photos.where((photo) {
          final now = DateTime.now();
          return photo.uploadedAt.year == now.year &&
              photo.uploadedAt.month == now.month;
        }).length,
        'averageFileSize': photos.isNotEmpty ? totalSize / photos.length : 0,
      };
    } catch (e) {
      throw Exception('Erro ao obter estatísticas: $e');
    }
  }

  // ==================== MÉTODOS PRIVADOS ====================

  /// Salvar lista de fotos
  static Future<void> _savePhotos(List<Photo> photos) async {
    final photosData = photos.map((photo) => photo.toMap()).toList();
    await StorageService.saveList(_photosKey, photosData);
  }

  // ==================== UTILITÁRIOS ====================

  /// Gerar ID único para foto
  static String generatePhotoId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}
