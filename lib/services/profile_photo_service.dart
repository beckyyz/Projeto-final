import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/user_service.dart';

/// ProfilePhotoService handles all operations related to user profile photos
///
/// This service provides methods for:
/// - Selecting profile photos from camera or gallery
/// - Processing and saving profile photos
/// - Removing profile photos
///
/// It ensures proper error handling and cleanup of resources

/// Service to handle profile photo operations
class ProfilePhotoService {
  /// Shows a bottom sheet with options to change profile photo
  static void showPhotoOptions(
    BuildContext context, {
    Function()? onSuccess,
    Function(String)? onError,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Tirar uma foto'),
            onTap: () async {
              Navigator.of(ctx).pop();
              try {
                final ImagePicker picker = ImagePicker();
                final XFile? photo = await picker.pickImage(
                  source: ImageSource.camera,
                  maxWidth: 800,
                  maxHeight: 800,
                  imageQuality: 85,
                );
                if (photo != null) {
                  await processProfilePhoto(
                    photo.path,
                    onSuccess: onSuccess,
                    onError: onError,
                  );
                }
              } catch (e) {
                if (onError != null) onError('Erro ao capturar foto: $e');
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Escolher da galeria'),
            onTap: () async {
              Navigator.of(ctx).pop();
              try {
                final ImagePicker picker = ImagePicker();
                final XFile? photo = await picker.pickImage(
                  source: ImageSource.gallery,
                  maxWidth: 800,
                  maxHeight: 800,
                  imageQuality: 85,
                );
                if (photo != null) {
                  await processProfilePhoto(
                    photo.path,
                    onSuccess: onSuccess,
                    onError: onError,
                  );
                }
              } catch (e) {
                if (onError != null) onError('Erro ao selecionar foto: $e');
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text(
              'Remover foto',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () async {
              Navigator.of(ctx).pop();
              await removeProfilePhoto(onSuccess: onSuccess, onError: onError);
            },
          ),
        ],
      ),
    );
  }

  /// Process a new profile photo - save it and update user profile
  static Future<void> processProfilePhoto(
    String photoPath, {
    Function()? onSuccess,
    Function(String)? onError,
  }) async {
    String? savedPath;
    try {
      final directory = await getApplicationDocumentsDirectory();
      final profileDir = Directory('${directory.path}/profile_photos');
      if (!await profileDir.exists()) {
        await profileDir.create(recursive: true);
      }

      final fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
      savedPath = '${profileDir.path}/$fileName';

      // Copy image file
      final File originalFile = File(photoPath);
      await originalFile.copy(savedPath);

      // Update user profile
      await UserService.updateProfilePhoto(savedPath);

      if (onSuccess != null) onSuccess();
    } catch (e) {
      // Clean up the copied file if there was an error updating the profile
      if (savedPath != null) {
        try {
          final copiedFile = File(savedPath);
          if (await copiedFile.exists()) {
            await copiedFile.delete();
          }
        } catch (cleanupError) {
          // Silently handle cleanup errors
        }
      }

      if (onError != null) onError('Erro ao processar foto: $e');
    }
  }

  /// Remove the current profile photo
  static Future<void> removeProfilePhoto({
    Function()? onSuccess,
    Function(String)? onError,
  }) async {
    try {
      await UserService.removeProfilePhoto(); // Use the specific method for removing photos
      if (onSuccess != null) onSuccess();
    } catch (e) {
      if (onError != null) onError('Erro ao remover foto: $e');
    }
  }
}
