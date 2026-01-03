import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:tests/model/save_location_model.dart';

/// This service helps save and read files in different locations
/// Think of it as a helper that knows where to put files on your device
class StorageService {
  /// Get the folder path based on where the user wants to save
  /// Returns the folder (directory) where we can save files
  static Future<Directory?> getDirectory(SaveLocation location) async {
    try {
      switch (location) {
        // App Documents: Safe place that always works (no permissions needed)
        case SaveLocation.appDocuments:
          return await getApplicationDocumentsDirectory();

        // Downloads: User's Downloads folder
        case SaveLocation.downloads:
          return await _getDownloadsFolder();

        // Documents: User's Documents folder
        case SaveLocation.documents:
          return await _getDocumentsFolder();
      }
    } catch (e) {
      // If something goes wrong, return null
      return null;
    }
  }

  /// Get the Downloads folder path
  /// Different devices use different paths, so we check what works
  static Future<Directory?> _getDownloadsFolder() async {
    if (Platform.isAndroid) {
      // On Android, try to find the Downloads folder
      try {
        final externalDir = await getExternalStorageDirectory();
        if (externalDir != null) {
          // Go up from app folder to find the main storage
          final storageRoot = externalDir.path.split('/Android')[0];
          final downloadsPath = '$storageRoot/Download';
          return Directory(downloadsPath);
        }
      } catch (e) {
        // If we can't access Downloads, use app's own folder instead
        final appDir = await getExternalStorageDirectory();
        if (appDir != null) {
          return Directory('${appDir.path}/Download');
        }
      }
    } 
    return null;
  }

  /// Get the Documents folder path
  static Future<Directory?> _getDocumentsFolder() async {
    if (Platform.isAndroid) {
      try {
        final externalDir = await getExternalStorageDirectory();
        if (externalDir != null) {
          final storageRoot = externalDir.path.split('/Android')[0];
          return Directory('$storageRoot/Documents');
        }
      } catch (e) {
        // Fallback to app folder
        return await getApplicationDocumentsDirectory();
      }
    } 
    return null;
  }


  /// Create a File object that points to where we want to save
  /// This also creates the folder if it doesn't exist
  static Future<File> getFile(SaveLocation location, String fileName) async {
    // Get the folder where we want to save
    final folder = await getDirectory(location);

    // If we can't get the folder, throw an error
    if (folder == null) {
      throw Exception('Cannot access the selected folder');
    }

    // Create the folder if it doesn't exist
    if (!await folder.exists()) {
      await folder.create(recursive: true);
    }

    // Use the provided filename, or default to 'note.txt' if empty
    final finalFileName = fileName.trim().isEmpty
        ? 'note.txt'
        : fileName.trim();

    // Return the full file path
    return File('${folder.path}/$finalFileName');
  }

  /// Check if an error is about permissions (access denied)
  static bool isPermissionError(dynamic error) {
    final errorMessage = error.toString().toLowerCase();
    return errorMessage.contains('permission denied') ||
        errorMessage.contains('access denied');
  }
}