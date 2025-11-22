import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  final supabase = Supabase.instance.client;

  /// Uploads an image and returns the public URL
  Future<String> uploadImage(File file, String username) async {
    final fileName = "${username}_${DateTime.now().millisecondsSinceEpoch}.jpg";

    try {
      // Upload the file to 'recipe_images' bucket
      await supabase.storage.from('recipe_images').upload(
        fileName,
        file,
        fileOptions: const FileOptions(
          cacheControl: '3600',
          upsert: false,
        ),
      );

      // Get public URL
      final publicUrl = supabase.storage.from('recipe_images').getPublicUrl(fileName);
      return publicUrl;
    } catch (e) {
      throw Exception("Image upload failed: $e");
    }
  }
}
