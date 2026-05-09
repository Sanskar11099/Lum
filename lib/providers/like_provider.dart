import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'feed_provider.dart';

final likeErrorProvider = StateProvider<String?>((ref) => null);

class LikeNotifier extends StateNotifier<bool> {
  final String postId;
  final Ref _ref;
  Timer? _debounce;
  bool _pendingValue;

  LikeNotifier(this.postId, this._ref, bool initialLiked)
      : _pendingValue = initialLiked,
        super(initialLiked);

  void toggle() {
    _pendingValue = !_pendingValue;
    state = _pendingValue;
    _optimisticUpdate(_pendingValue);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), _flush);
  }

  void _optimisticUpdate(bool liked) {
    final feed = _ref.read(feedProvider).valueOrNull;
    if (feed == null) return;
    final post = feed.posts.where((p) => p.id == postId).firstOrNull;
    if (post == null) return;
    final delta = liked ? 1 : -1;
    _ref.read(feedProvider.notifier).updatePost(
          post.copyWith(isLiked: liked, likeCount: post.likeCount + delta),
        );
  }

  Future<void> _flush() async {
    final result = await Connectivity().checkConnectivity();
    final offline = result.isEmpty || result.every((r) => r == ConnectivityResult.none);
    if (offline) {
      _revert();
      _ref.read(likeErrorProvider.notifier).state = 'No internet — like reverted';
      return;
    }
    try {
      await _ref.read(feedRepositoryProvider).toggleLike(postId);
    } catch (_) {
      _revert();
      _ref.read(likeErrorProvider.notifier).state = 'Like failed — please retry';
    }
  }

  void _revert() {
    _pendingValue = !_pendingValue;
    state = _pendingValue;
    _optimisticUpdate(_pendingValue);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}

// Keyed by postId (String) so the notifier survives feed list updates.
final likeProvider = StateNotifierProvider.family<LikeNotifier, bool, String>(
  (ref, postId) {
    final feed = ref.read(feedProvider).valueOrNull;
    final post = feed?.posts.where((p) => p.id == postId).firstOrNull;
    return LikeNotifier(postId, ref, post?.isLiked ?? false);
  },
);
