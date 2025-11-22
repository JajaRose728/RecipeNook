import 'dart:io';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart'; // for kIsWeb

class StorageService {
  final supabase = Supabase.instance.client;

  // Mobile upload
  Future<String> uploadImage(File file, String username) async {
    final fileName = "${username}_${DateTime.now().millisecondsSinceEpoch}.jpg";
    final response = await supabase.storage.from('recipe_images').upload(fileName, file);

    // Supabase storage upload now returns a String, so check differently
    if (response is String && response.contains('error')) {
      throw Exception(response);
    }

    final publicUrl = supabase.storage.from('recipe_images').getPublicUrl(fileName);
    return publicUrl;
  }

  // Web upload
  Future<String> uploadBytes(Uint8List bytes, String username) async {
    final fileName = "${username}_${DateTime.now().millisecondsSinceEpoch}.jpg";
    await supabase.storage.from('recipe_images').uploadBinary(fileName, bytes);
    final publicUrl = supabase.storage.from('recipe_images').getPublicUrl(fileName);
    return publicUrl;
  }
}
