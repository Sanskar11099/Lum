import 'dart:ui';

import 'package:flutter/material.dart';

import 'theme.dart';
import 'widgets.dart';

class PostSheet extends StatefulWidget {
  final PostData post;
  final VoidCallback onLike, onSave;
  const PostSheet({super.key, required this.post, required this.onLike, required this.onSave});
  @override State<PostSheet> createState() => _PostSheetState();
}

class _PostSheetState extends State<PostSheet> {
  final _ctrl = TextEditingController();
  static const _comments = [
    ('aurora.lenz',  'photo-1494790108377-be9c29b29330', 'Absolutely breathtaking ✨'),
    ('marcovidal',   'photo-1507003211169-0a1dd7228f2d', 'This is pure art 🖤'),
    ('sofiaray',     'photo-1438761681033-6461ffad8d80', 'Where was this taken?! 😍'),
    ('jameslowe',    'photo-1472099645785-5658abf4ff4e', 'The light here is unreal'),
  ];

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Container(
    height: MediaQuery.of(context).size.height * 0.93,
    decoration: BoxDecoration(
      color: Lum.bg,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      border: Border.all(color: Lum.glassBorder),
    ),
    clipBehavior: Clip.antiAlias,
    child: Column(children: [
      // Handle
      Container(
        width: 36, height: 4, margin: const EdgeInsets.only(top: 10, bottom: 8),
        decoration: BoxDecoration(color: Lum.glassBorder, borderRadius: BorderRadius.circular(2)),
      ),
      Expanded(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // User row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Row(children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Lum.violet.withValues(alpha: 0.35), width: 2),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: NetImg(imgUrl(widget.post.user.avatarId, w: 80, face: true)),
                ),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(widget.post.user.handle, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
                  Text(widget.post.user.name,   style: const TextStyle(fontSize: 10, color: Lum.muted)),
                ])),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: Lum.violet.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Lum.violet.withValues(alpha: 0.3)),
                    ),
                    child: const Text('Follow',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Lum.violet)),
                  ),
                ),
              ]),
            ),
            // Photo
            NetImg(postImageUrl(widget.post), width: double.infinity, height: 360),
            // Actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(children: [
                GestureDetector(
                  onTap: () { widget.onLike(); setState(() {}); },
                  child: Row(children: [
                    Icon(widget.post.liked ? Icons.favorite : Icons.favorite_outline,
                        color: widget.post.liked ? Lum.rose : Lum.muted, size: 24),
                    const SizedBox(width: 5),
                    Text(fmtN(widget.post.likes + (widget.post.liked ? 1 : 0)),
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Lum.muted)),
                  ]),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.chat_bubble_outline, color: Lum.muted, size: 24),
                const SizedBox(width: 5),
                Text(fmtN(widget.post.comments), style: const TextStyle(fontSize: 12, color: Lum.muted)),
                const SizedBox(width: 14),
                const Icon(Icons.ios_share, color: Lum.muted, size: 24),
                const Spacer(),
                GestureDetector(
                  onTap: () { widget.onSave(); setState(() {}); },
                  child: Icon(widget.post.saved ? Icons.bookmark : Icons.bookmark_outline,
                      color: widget.post.saved ? Lum.violet : Lum.muted, size: 24),
                ),
              ]),
            ),
            Divider(color: Lum.glassBorder.withValues(alpha: 0.5), height: 1),
            // Caption
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text(
                  '✦ Golden hour finds its way through every crack in the universe.',
                  style: TextStyle(fontSize: 12, color: Lum.muted, height: 1.65),
                ),
                const SizedBox(height: 8),
                Wrap(spacing: 8,
                  children: ['#lumapp', '#photography', '#${widget.post.tag.toLowerCase()}', '#light']
                      .map((t) => Text(t, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Lum.violet)))
                      .toList(),
                ),
              ]),
            ),
            Divider(color: Lum.glassBorder.withValues(alpha: 0.5), height: 1),
            // Comments
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('COMMENTS',
                  style: TextStyle(fontSize: 10, color: Lum.dim, fontWeight: FontWeight.w600, letterSpacing: 0.8)),
                const SizedBox(height: 12),
                ..._comments.map((c) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(
                      width: 30, height: 30, margin: const EdgeInsets.only(right: 9),
                      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Lum.glassBorder)),
                      clipBehavior: Clip.antiAlias,
                      child: NetImg(imgUrl(c.$2, w: 60, face: true)),
                    ),
                    Expanded(
                      child: GlassBox(
                        radius: 14,
                        padding: const EdgeInsets.all(10),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(c.$1, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Lum.violet)),
                          const SizedBox(height: 2),
                          Text(c.$3, style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.75), height: 1.4)),
                        ]),
                      ),
                    ),
                  ]),
                )),
              ]),
            ),
          ]),
        ),
      ),
      // Comment input
      ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: EdgeInsets.only(
              left: 14, right: 14, top: 10,
              bottom: MediaQuery.of(context).viewInsets.bottom + 14,
            ),
            decoration: const BoxDecoration(
              color: Color(0x12FFFFFF),
              border: Border(top: BorderSide(color: Lum.glassBorder, width: 0.5)),
            ),
            child: Row(children: [
              Container(
                width: 30, height: 30,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: Lum.gradVioletRose),
                ),
                child: const Center(child: Text('✦', style: TextStyle(color: Colors.white, fontSize: 12))),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  decoration: const InputDecoration(
                    hintText: 'Add a comment…',
                    hintStyle: TextStyle(color: Lum.muted, fontSize: 12),
                    border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              if (_ctrl.text.isNotEmpty)
                GestureDetector(
                  onTap: () => setState(() => _ctrl.clear()),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: Lum.gradVioletRose),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('Post',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)),
                  ),
                ),
            ]),
          ),
        ),
      ),
    ]),
  );
}
