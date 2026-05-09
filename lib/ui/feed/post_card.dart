import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/post_model.dart';
import '../../providers/like_provider.dart';
import '../detail/detail_screen.dart';

class PostCard extends ConsumerWidget {
  final Post post;
  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLiked = ref.watch(likeProvider(post.id));

    return RepaintBoundary(
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => DetailScreen(post: post)),
              ),
              child: Hero(
                tag: 'post-${post.id}',
                child: CachedNetworkImage(
                  imageUrl: post.mediaThumbUrl,
                  memCacheWidth: 600,
                  height: 280,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(height: 280, color: Colors.grey[200]),
                  errorWidget: (_, __, ___) => const SizedBox(
                    height: 280,
                    child: Icon(Icons.broken_image),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Row(
                children: [
                  AnimatedScale(
                    scale: isLiked ? 1.2 : 1.0,
                    duration: const Duration(milliseconds: 150),
                    child: IconButton(
                      icon: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: isLiked ? Colors.red : null,
                      ),
                      onPressed: () => ref.read(likeProvider(post.id).notifier).toggle(),
                    ),
                  ),
                  Text(
                    '${post.likeCount}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: const Icon(Icons.comment_outlined),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => DetailScreen(post: post)),
                    ),
                  ),
                  Text(
                    '${post.commentCount}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
