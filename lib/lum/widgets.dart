import 'dart:math';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'theme.dart';

// ─── DATA MODELS ───────────────────────────────────────
class UserData {
  final String name, handle, avatarId;
  const UserData(this.name, this.handle, this.avatarId);
}

class PostData {
  final String id;
  final String photoId;
  final String? imageUrl;   // real Supabase Storage URL (mobile tier)
  final String? thumbUrl;   // real Supabase Storage URL (thumb tier)
  final double cardHeight;
  final UserData user;
  final int likes, saves, comments;
  final String tag;
  bool liked, saved;

  PostData({
    required this.id,
    this.photoId = '',
    this.imageUrl,
    this.thumbUrl,
    required this.cardHeight,
    required this.user,
    required this.likes,
    required this.saves,
    required this.comments,
    required this.tag,
    this.liked = false,
    this.saved = false,
  });
}

class StoryData {
  final int id;
  final String name;
  final String? avatarId;
  final bool isMe;
  final List<Color> gradient;
  const StoryData({
    required this.id,
    required this.name,
    this.avatarId,
    this.isMe = false,
    required this.gradient,
  });
}

// ─── SAMPLE DATA ───────────────────────────────────────
const lumPhotoIds = [
  'photo-1469474968028-56623f02e42e', 'photo-1501854140801-50d01698950b',
  'photo-1441974231531-c6227db76b6e', 'photo-1506905925346-21bda4d32df4',
  'photo-1518173946687-a4c8892bbd9f', 'photo-1479030160180-b1860951d696',
  'photo-1558618666-fcd25c85cd64',   'photo-1529139574466-a303027c1d8b',
  'photo-1495474472287-4d71bcdd2085', 'photo-1565299624946-b28f40a0ae38',
  'photo-1476224203421-9ac39bcb3327', 'photo-1555041469-a586c61ea9bc',
  'photo-1486325212027-8081e485255e', 'photo-1477959858617-67f85cf4f1df',
  'photo-1480714378408-67cf0d13bc1b', 'photo-1557672172-298e090bd0f1',
  'photo-1508739773434-c26b3d09e071', 'photo-1534528741775-53994a69daeb',
  'photo-1531746020798-e6953c6e8e04', 'photo-1524504388940-b1c1722653e1',
];

const lumUsers = [
  UserData('Aurora Lenz', 'aurora.lenz', 'photo-1494790108377-be9c29b29330'),
  UserData('Marco Vidal', 'marcovidal',  'photo-1507003211169-0a1dd7228f2d'),
  UserData('Sofia Ray',   'sofiaray',    'photo-1438761681033-6461ffad8d80'),
  UserData('James Lowe',  'jameslowe',   'photo-1472099645785-5658abf4ff4e'),
  UserData('Yuki Storm',  'yukistorm',   'photo-1534528741775-53994a69daeb'),
  UserData('Nadia Voss',  'nadiavoss',   'photo-1531746020798-e6953c6e8e04'),
];

const lumStories = [
  StoryData(id: 0, name: 'You',    isMe: true, gradient: Lum.gradVioletRose),
  StoryData(id: 1, name: 'aurora', avatarId: 'photo-1494790108377-be9c29b29330', gradient: [Lum.amber, Lum.rose]),
  StoryData(id: 2, name: 'marco',  avatarId: 'photo-1507003211169-0a1dd7228f2d', gradient: Lum.gradVioletAqua),
  StoryData(id: 3, name: 'sofia',  avatarId: 'photo-1438761681033-6461ffad8d80', gradient: [Lum.violet, Color(0xFF60A5FA)]),
  StoryData(id: 4, name: 'james',  avatarId: 'photo-1472099645785-5658abf4ff4e', gradient: [Lum.rose, Lum.amber]),
  StoryData(id: 5, name: 'yuki',   avatarId: 'photo-1534528741775-53994a69daeb', gradient: Lum.gradAquaBlue),
  StoryData(id: 6, name: 'nadia',  avatarId: 'photo-1531746020798-e6953c6e8e04', gradient: [Lum.amber, Color(0xFFF87171)]),
  StoryData(id: 7, name: 'kai',    avatarId: 'photo-1524504388940-b1c1722653e1', gradient: Lum.gradAquaBlue),
];

const lumTags = ['All', 'Nature', 'Fashion', 'Architecture', 'Travel', 'Food', 'Abstract', 'Portrait'];
const _cardHeights = [215.0, 275.0, 238.0, 305.0, 258.0, 198.0, 282.0, 318.0, 248.0, 228.0];
final _rng = Random();

List<PostData> generatePosts(int offset, int count) => List.generate(count, (i) {
  final idx = (offset + i) % lumPhotoIds.length;
  return PostData(
    id:         '${offset + i}',
    photoId:    lumPhotoIds[idx],
    cardHeight: _cardHeights[(offset + i) % _cardHeights.length],
    user:       lumUsers[(offset + i) % lumUsers.length],
    likes:      _rng.nextInt(18000) + 300,
    saves:      _rng.nextInt(6000)  + 80,
    comments:   _rng.nextInt(800)   + 20,
    tag:        lumTags[1 + ((offset + i) % (lumTags.length - 1))],
  );
});

// ─── HELPERS ───────────────────────────────────────────
String imgUrl(String id, {int w = 400, int h = 0, bool face = false}) {
  final crop  = face ? '&crop=face&fit=crop' : '&fit=crop';
  final hPart = h > 0 ? '&h=$h' : '';
  return 'https://images.unsplash.com/$id?w=$w$hPart&q=80$crop';
}

String fmtN(int n) => n >= 1000 ? '${(n / 1000).toStringAsFixed(1)}k' : '$n';

/// Returns the best available image URL for a post.
/// Prefers the real Supabase URL; falls back to Unsplash.
String postImageUrl(PostData p, {bool thumb = false}) {
  if (thumb && p.thumbUrl != null) return p.thumbUrl!;
  if (p.imageUrl != null) return p.imageUrl!;
  return imgUrl(p.photoId, w: thumb ? 200 : 400);
}

// ─── GLASS BOX ─────────────────────────────────────────
class GlassBox extends StatelessWidget {
  final Widget child;
  final double radius;
  final double sigma;
  final Color color;
  final Color border;
  final EdgeInsetsGeometry? padding;
  final BoxDecoration? extraDecoration;
  final bool enableBlur;

  const GlassBox({
    super.key,
    required this.child,
    this.radius = 20,
    this.sigma  = 20,
    this.color  = Lum.glass,
    this.border = Lum.glassBorder,
    this.padding,
    this.extraDecoration,
    this.enableBlur = true,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: padding,
      decoration: (extraDecoration ?? const BoxDecoration()).copyWith(
        color: extraDecoration?.color ?? color,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: border),
      ),
      child: child,
    );
    if (!enableBlur) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: content,
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
        child: content,
      ),
    );
  }
}

// ─── AURORA BACKGROUND ─────────────────────────────────
class AuroraBg extends StatefulWidget {
  final Widget child;
  const AuroraBg({super.key, required this.child});
  @override State<AuroraBg> createState() => _AuroraBgState();
}

class _AuroraBgState extends State<AuroraBg> with TickerProviderStateMixin {
  late final AnimationController _c1, _c2, _c3;

  @override
  void initState() {
    super.initState();
    _c1 = AnimationController(vsync: this, duration: const Duration(seconds: 18))..repeat(reverse: true);
    _c2 = AnimationController(vsync: this, duration: const Duration(seconds: 22))..repeat(reverse: true);
    _c3 = AnimationController(vsync: this, duration: const Duration(seconds: 16))..repeat(reverse: true);
  }

  @override
  void dispose() { _c1.dispose(); _c2.dispose(); _c3.dispose(); super.dispose(); }

  Widget _blob(AnimationController ctrl, Color color, double opacity,
      {double top = 0, double left = 0, double bottom = 0, double right = 0,
       double dx = 30, double dy = 30, double size = 380}) {
    return AnimatedBuilder(
      animation: ctrl,
      builder: (_, __) => Positioned(
        top:    top    != 0 ? top    + ctrl.value * dy : null,
        left:   left   != 0 ? left   + ctrl.value * dx : null,
        bottom: bottom != 0 ? bottom - ctrl.value * dy : null,
        right:  right  != 0 ? right  + ctrl.value * dx : null,
        child: RepaintBoundary(
          child: Container(
            width: size, height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [color.withValues(alpha: opacity + ctrl.value * 0.04), Colors.transparent],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Container(
    color: Lum.bg,
    child: Stack(children: [
      _blob(_c1, Lum.violet, 0.16, top: -80,   left: -80,  dx: 25, dy: 35),
      _blob(_c2, Lum.aqua,   0.12, bottom: -60, right: -80, dx: 28, dy: 22),
      _blob(_c3, Lum.rose,   0.09, top: 280,   right: -60, dx: 18, dy: 30, size: 300),
      widget.child,
    ]),
  );
}

// ─── NET IMAGE ─────────────────────────────────────────
class NetImg extends StatelessWidget {
  final String url;
  final double? width, height;
  final BoxFit fit;
  final double radius;

  const NetImg(this.url, {
    super.key, this.width, this.height,
    this.fit = BoxFit.cover, this.radius = 0,
  });

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: CachedNetworkImage(
        imageUrl: url,
        width: width, height: height,
        fit: fit,
        fadeInDuration: const Duration(milliseconds: 200),
        // Use stale cache when offline — don't re-download if cached
        useOldImageOnUrlChange: true,
        cacheKey: url,
        placeholder: (_, __) => Container(
          width: width, height: height,
          color: const Color(0xFF1A1A2E),
        ),
        errorWidget: (_, __, ___) => Container(
          width: width, height: height,
          color: const Color(0xFF1A1A2E),
          child: const Icon(Icons.image_not_supported_outlined, color: Lum.dim),
        ),
      ),
    ),
  );
}

// ─── LOADING DOTS ──────────────────────────────────────
class LumLoadingDots extends StatefulWidget {
  const LumLoadingDots({super.key});
  @override State<LumLoadingDots> createState() => _LumLoadingDotsState();
}

class _LumLoadingDotsState extends State<LumLoadingDots> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  @override void initState() { super.initState(); _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat(); }
  @override void dispose()   { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: List.generate(3, (i) {
      final delay = i * 0.22;
      return AnimatedBuilder(
        animation: _c,
        builder: (_, __) {
          final t = ((_c.value - delay) % 1.0).clamp(0.0, 1.0);
          final s = 0.4 + 0.6 * (1 - (t * 2 - 1).abs().clamp(0.0, 1.0));
          return Container(
            width: 7, height: 7,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(shape: BoxShape.circle, color: Lum.violet.withValues(alpha: s)),
            transform: Matrix4.diagonal3Values(s, s, 1),
            transformAlignment: Alignment.center,
          );
        },
      );
    }),
  );
}
