import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import '../../data/models/post_model.dart';
import '../../providers/feed_provider.dart';
import '../detail/comments_sheet.dart';

class DetailScreen extends ConsumerStatefulWidget {
  final Post post;
  const DetailScreen({super.key, required this.post});

  @override
  ConsumerState<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends ConsumerState<DetailScreen> {
  bool _downloading = false;
  double _progress = 0;

  Future<void> _download() async {
    setState(() {
      _downloading = true;
      _progress = 0;
    });
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/${widget.post.id}_raw.jpg');
      await Dio().download(
        widget.post.mediaRawUrl,
        file.path,
        onReceiveProgress: (received, total) {
          if (total > 0 && mounted) setState(() => _progress = received / total);
        },
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Saved to ${file.path}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final feedAsync = ref.watch(feedProvider);
    final livePost = feedAsync.valueOrNull?.posts
            .where((p) => p.id == widget.post.id)
            .firstOrNull ??
        widget.post;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Detail', style: TextStyle(color: Colors.white)),
        actions: [
          if (_downloading)
            Padding(
              padding: const EdgeInsets.all(14),
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  value: _progress > 0 ? _progress : null,
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.download, color: Colors.white),
              tooltip: 'Download full-res',
              onPressed: _download,
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Theme.of(context).colorScheme.surface,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (_) => CommentsSheet(postId: widget.post.id),
        ),
        icon: const Icon(Icons.comment_outlined),
        label: Text('${livePost.commentCount}'),
      ),
      body: Hero(
        tag: 'post-${widget.post.id}',
        child: CachedNetworkImage(
          imageUrl: widget.post.mediaMobileUrl,
          memCacheWidth: 1080,
          fit: BoxFit.contain,
          width: double.infinity,
          height: double.infinity,
          placeholder: (_, __) => CachedNetworkImage(
            imageUrl: widget.post.mediaThumbUrl,
            fit: BoxFit.contain,
            width: double.infinity,
            height: double.infinity,
          ),
          errorWidget: (_, __, ___) =>
              const Center(child: Icon(Icons.broken_image, color: Colors.white, size: 48)),
        ),
      ),
    );
  }
}
