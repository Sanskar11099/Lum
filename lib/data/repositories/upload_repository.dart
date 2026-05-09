import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/supabase_client.dart';

/// Handles uploading images to Supabase Storage and inserting post records.
/// Mirrors the 3-tier pipeline from feed_seeder/seed.py but simplified:
///   - Uploads the original image as the "mobile" tier
///   - Uses the same image as "thumb" (no resize on-device for simplicity)
///   - Inserts a row into the `posts` table
class UploadRepository {
  static const _bucket = 'media';

  /// Picks a file, uploads to storage, inserts DB row.
  /// Returns the new post ID on success, null on failure.
  Future<String?> uploadImage(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final ext = imageFile.path.split('.').last.toLowerCase();
      final baseName = 'app_upload_$timestamp';

      // Upload mobile tier
      final mobilePath = '${baseName}_mobile.$ext';
      final contentType = ext == 'png' ? 'image/png' : 'image/jpeg';
      await supabase.storage.from(_bucket).uploadBinary(
        mobilePath,
        bytes,
        fileOptions: FileOptions(contentType: contentType, upsert: true),
      );

      // Upload thumb tier (same file for now — could resize on-device)
      final thumbPath = '${baseName}_thumb.$ext';
      await supabase.storage.from(_bucket).uploadBinary(
        thumbPath,
        bytes,
        fileOptions: FileOptions(contentType: contentType, upsert: true),
      );

      // Upload raw archive
      final rawPath = '${baseName}_raw.$ext';
      await supabase.storage.from(_bucket).uploadBinary(
        rawPath,
        bytes,
        fileOptions: FileOptions(contentType: contentType, upsert: true),
      );

      // Get public URLs
      final mobileUrl = supabase.storage.from(_bucket).getPublicUrl(mobilePath);
      final thumbUrl  = supabase.storage.from(_bucket).getPublicUrl(thumbPath);
      final rawUrl    = supabase.storage.from(_bucket).getPublicUrl(rawPath);

      // Insert DB row
      final res = await supabase.from('posts').insert({
        'media_thumb_url':  thumbUrl,
        'media_mobile_url': mobileUrl,
        'media_raw_url':    rawUrl,
      }).select().single();

      final id = res['id'] as String;
      debugPrint('UploadRepository: Post created — ID: $id');
      return id;
    } catch (e) {
      debugPrint('UploadRepository: Upload failed — $e');
      return null;
    }
  }
}
