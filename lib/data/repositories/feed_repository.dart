import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../models/post_model.dart';
import '../../core/constants.dart';
import '../../core/supabase_client.dart';

class FeedRepository {
  static const _cacheFileName = 'feed_cache.json';

  /// Fetches a page of posts. Tries the network first; on failure,
  /// falls back to the local disk cache (offline mode).
  Future<List<Post>> fetchPage(int page) async {
    try {
      final posts = await _fetchFromNetwork(page);
      // Cache the results for offline use
      _saveToCacheInBackground(page, posts);
      return posts;
    } catch (e) {
      debugPrint('FeedRepository: Network error — $e');
      debugPrint('FeedRepository: Falling back to local cache...');
      return _loadFromCache(page);
    }
  }

  /// Network fetch — talks to Supabase.
  Future<List<Post>> _fetchFromNetwork(int page) async {
    final from = page * feedPageSize;
    final to = from + feedPageSize - 1;

    final data = await supabase
        .from('posts')
        .select()
        .order('created_at', ascending: false)
        .range(from, to) as List<dynamic>;

    final ids = data.map((e) => e['id'] as String).toList();
    final likes = ids.isEmpty
        ? <dynamic>[]
        : await supabase
            .from('user_likes')
            .select('post_id')
            .eq('user_id', testUserId)
            .inFilter('post_id', ids) as List<dynamic>;

    final likedIds = {for (final l in likes) l['post_id'] as String};

    return data
        .map((e) => Post(
              id: e['id'] as String,
              mediaThumbUrl: e['media_thumb_url'] as String,
              mediaMobileUrl: e['media_mobile_url'] as String,
              mediaRawUrl: e['media_raw_url'] as String,
              likeCount: (e['like_count'] as int?) ?? 0,
              commentCount: (e['comment_count'] as int?) ?? 0,
              isLiked: likedIds.contains(e['id'] as String),
            ))
        .toList();
  }

  // ─── Local cache ───────────────────────────────────────

  Future<File> get _cacheFile async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_cacheFileName');
  }

  /// Saves fetched posts to disk (per page).
  void _saveToCacheInBackground(int page, List<Post> posts) {
    () async {
      try {
        final file = await _cacheFile;
        Map<String, dynamic> cache = {};

        if (await file.exists()) {
          final content = await file.readAsString();
          if (content.isNotEmpty) {
            cache = jsonDecode(content) as Map<String, dynamic>;
          }
        }

        // Store page data as list of JSON maps
        cache['page_$page'] = posts.map((p) => p.toJson()).toList();
        await file.writeAsString(jsonEncode(cache));
        debugPrint('FeedRepository: Cached page $page (${posts.length} posts)');
      } catch (e) {
        debugPrint('FeedRepository: Cache write error — $e');
      }
    }();
  }

  /// Loads posts from the local cache file.
  Future<List<Post>> _loadFromCache(int page) async {
    try {
      final file = await _cacheFile;
      if (!await file.exists()) {
        debugPrint('FeedRepository: No cache file found');
        return [];
      }

      final content = await file.readAsString();
      if (content.isEmpty) return [];

      final cache = jsonDecode(content) as Map<String, dynamic>;
      final key = 'page_$page';

      if (!cache.containsKey(key)) {
        debugPrint('FeedRepository: No cached data for page $page');
        return [];
      }

      final list = (cache[key] as List<dynamic>)
          .map((e) => Post.fromJson(e as Map<String, dynamic>))
          .toList();

      debugPrint('FeedRepository: Loaded ${list.length} cached posts for page $page');
      return list;
    } catch (e) {
      debugPrint('FeedRepository: Cache read error — $e');
      return [];
    }
  }

  Future<void> toggleLike(String postId) async {
    await supabase.rpc('toggle_like', params: {
      'p_post_id': postId,
      'p_user_id': testUserId,
    });
  }
}
