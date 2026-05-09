import '../models/comment_model.dart';
import '../../core/constants.dart';
import '../../core/supabase_client.dart';

class CommentsRepository {
  Future<List<Comment>> fetchComments(String postId) async {
    final data = await supabase
        .from('comments')
        .select()
        .eq('post_id', postId)
        .order('created_at') as List<dynamic>;

    return data
        .map((e) => Comment(
              id: e['id'] as String,
              postId: e['post_id'] as String,
              userId: e['user_id'] as String,
              content: e['content'] as String,
              createdAt: DateTime.parse(e['created_at'] as String),
            ))
        .toList();
  }

  Future<Comment> addComment(String postId, String content) async {
    final res = await supabase
        .from('comments')
        .insert({
          'post_id': postId,
          'user_id': testUserId,
          'content': content,
        })
        .select()
        .single();

    return Comment(
      id: res['id'] as String,
      postId: res['post_id'] as String,
      userId: res['user_id'] as String,
      content: res['content'] as String,
      createdAt: DateTime.parse(res['created_at'] as String),
    );
  }
}
