import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/supabase_client.dart';
import '../data/models/comment_model.dart';
import '../data/repositories/comments_repository.dart';
import 'feed_provider.dart';

final commentsRepositoryProvider = Provider((_) => CommentsRepository());

class CommentsState {
  final List<Comment> comments;
  final bool isLoading;
  final bool isSending;
  final String? error;

  const CommentsState({
    this.comments = const [],
    this.isLoading = false,
    this.isSending = false,
    this.error,
  });

  CommentsState copyWith({
    List<Comment>? comments,
    bool? isLoading,
    bool? isSending,
    String? error,
  }) =>
      CommentsState(
        comments: comments ?? this.comments,
        isLoading: isLoading ?? this.isLoading,
        isSending: isSending ?? this.isSending,
        error: error,
      );
}

class CommentsNotifier
    extends AutoDisposeFamilyAsyncNotifier<CommentsState, String> {
  RealtimeChannel? _channel;

  @override
  Future<CommentsState> build(String postId) async {
    final comments =
        await ref.read(commentsRepositoryProvider).fetchComments(postId);
    _subscribeRealtime(postId);
    ref.onDispose(() => _channel?.unsubscribe());
    return CommentsState(comments: comments);
  }

  void _subscribeRealtime(String postId) {
    _channel = supabase
        .channel('comments:$postId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'comments',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'post_id',
            value: postId,
          ),
          callback: (payload) {
            final r = payload.newRecord;
            final incoming = Comment(
              id: r['id'] as String,
              postId: r['post_id'] as String,
              userId: r['user_id'] as String,
              content: r['content'] as String,
              createdAt: DateTime.parse(r['created_at'] as String),
            );
            final current = state.valueOrNull;
            if (current != null &&
                !current.comments.any((c) => c.id == incoming.id)) {
              state = AsyncData(current.copyWith(
                comments: [...current.comments, incoming],
              ));
            }
          },
        )
        .subscribe();
  }

  Future<void> addComment(String content) async {
    final current = state.valueOrNull;
    if (current == null || content.trim().isEmpty) return;
    state = AsyncData(current.copyWith(isSending: true));
    try {
      final comment = await ref
          .read(commentsRepositoryProvider)
          .addComment(arg, content.trim());
      state = AsyncData(current.copyWith(
        comments: [...current.comments, comment],
        isSending: false,
      ));
      // Optimistically increment comment count in feed
      final feed = ref.read(feedProvider).valueOrNull;
      if (feed != null) {
        final post = feed.posts.where((p) => p.id == arg).firstOrNull;
        if (post != null) {
          ref.read(feedProvider.notifier).updatePost(
                post.copyWith(commentCount: post.commentCount + 1),
              );
        }
      }
    } catch (e) {
      state =
          AsyncData(current.copyWith(isSending: false, error: e.toString()));
    }
  }
}

final commentsProvider = AsyncNotifierProvider.autoDispose
    .family<CommentsNotifier, CommentsState, String>(CommentsNotifier.new);
