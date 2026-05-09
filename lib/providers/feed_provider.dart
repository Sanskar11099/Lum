import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants.dart';
import '../core/supabase_client.dart';
import '../data/models/post_model.dart';
import '../data/repositories/feed_repository.dart';

final feedRepositoryProvider = Provider((_) => FeedRepository());

class FeedState {
  final List<Post> posts;
  final bool isLoading;
  final bool hasMore;
  final String? error;

  const FeedState({
    this.posts = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.error,
  });

  FeedState copyWith({
    List<Post>? posts,
    bool? isLoading,
    bool? hasMore,
    String? error,
  }) =>
      FeedState(
        posts: posts ?? this.posts,
        isLoading: isLoading ?? this.isLoading,
        hasMore: hasMore ?? this.hasMore,
        error: error,
      );
}

class FeedNotifier extends AsyncNotifier<FeedState> {
  int _page = 0;
  RealtimeChannel? _channel;

  @override
  Future<FeedState> build() async {
    _page = 0;
    final posts = await ref.read(feedRepositoryProvider).fetchPage(0);
    _subscribeRealtime();
    ref.onDispose(() => _channel?.unsubscribe());
    return FeedState(posts: posts, hasMore: posts.length == feedPageSize);
  }

  void _subscribeRealtime() {
    _channel = supabase
        .channel('public:posts')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'posts',
          callback: (payload) {
            final r = payload.newRecord;
            final postId = r['id'] as String?;
            if (postId == null) return;
            final current = state.valueOrNull;
            if (current == null) return;
            final post = current.posts.where((p) => p.id == postId).firstOrNull;
            if (post == null) return;
            updatePost(post.copyWith(
              likeCount: (r['like_count'] as int?) ?? post.likeCount,
              commentCount: (r['comment_count'] as int?) ?? post.commentCount,
            ));
          },
        )
        .subscribe();
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || current.isLoading || !current.hasMore) return;
    state = AsyncData(current.copyWith(isLoading: true));
    try {
      _page++;
      final next = await ref.read(feedRepositoryProvider).fetchPage(_page);
      state = AsyncData(current.copyWith(
        posts: [...current.posts, ...next],
        isLoading: false,
        hasMore: next.length == feedPageSize,
      ));
    } catch (e) {
      _page--;
      state = AsyncData(current.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    _page = 0;
    final posts = await ref.read(feedRepositoryProvider).fetchPage(0);
    state = AsyncData(FeedState(posts: posts, hasMore: posts.length == feedPageSize));
  }

  void updatePost(Post updated) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.copyWith(
      posts: current.posts.map((p) => p.id == updated.id ? updated : p).toList(),
    ));
  }
}

final feedProvider = AsyncNotifierProvider<FeedNotifier, FeedState>(FeedNotifier.new);
