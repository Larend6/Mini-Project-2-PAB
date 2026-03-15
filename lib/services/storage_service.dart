import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {

  final supabase = Supabase.instance.client;

  Future<String> uploadImage(File imageFile) async {

    try {

      final user = supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User belum login');
      }
      final userId = user.id;

      final fileExt = imageFile.path.split('.').last;
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}.$fileExt';

      final path = "$userId/$fileName";

      await supabase.storage.from('card-images').upload(
            path,
            imageFile,
            fileOptions: const FileOptions(upsert: false),
          );

      final imageUrl = supabase.storage
          .from('card-images')
          .getPublicUrl(path);

      if (imageUrl.isEmpty) {
        throw Exception('Gagal mendapatkan URL gambar');
      }

      return imageUrl;

    } catch (e) {
      // log to console for debug; remove in production if needed
      // ignore: avoid_print
      print("Upload error: $e");
      rethrow;
    }
  }
}
