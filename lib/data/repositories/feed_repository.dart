import '../models/post_model.dart';
import '../../core/constants.dart';
import '../../core/supabase_client.dart';

class FeedRepository {
  Future<List<Post>> fetchPage(int page) async {
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

  Future<void> toggleLike(String postId) async {
    await supabase.rpc('toggle_like', params: {
      'p_post_id': postId,
      'p_user_id': testUserId,
    });
  }
}
