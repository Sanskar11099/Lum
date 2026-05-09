import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'theme.dart';
import 'widgets.dart';
import 'story_viewer.dart';
import 'post_sheet.dart';
import 'search_page.dart';
import 'profile_page.dart';
import '../data/repositories/feed_repository.dart';
import '../data/repositories/upload_repository.dart';

// ─── ROOT APP ──────────────────────────────────────────
class LumApp extends StatelessWidget {
  const LumApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'lüm',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Lum.bg,
      textTheme: GoogleFonts.syneTextTheme(ThemeData.dark().textTheme),
      colorScheme: const ColorScheme.dark(
        primary: Lum.violet,
        secondary: Lum.aqua,
        surface: Lum.surface,
      ),
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
    ),
    home: const LumFeedPage(),
  );
}

// ─── LUM FEED PAGE (Tab Controller) ───────────────────
class LumFeedPage extends StatefulWidget {
  const LumFeedPage({super.key});
  @override State<LumFeedPage> createState() => _LumFeedPageState();
}

class _LumFeedPageState extends State<LumFeedPage> {
  int _tab = 0;
  final _feedKey = GlobalKey<_FeedPageState>();

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Lum.bg,
    extendBody: true,
    body: AuroraBg(child: _page()),
    bottomNavigationBar: _BottomNav(
      current: _tab,
      onChange: (i) => setState(() => _tab = i),
      onCreateTap: () => _showUploadSheet(context),
    ),
  );

  Widget _page() => switch (_tab) {
    0 => FeedPage(key: _feedKey),
    1 => const SearchPage(),
    3 => const SavedPage(),
    4 => const ProfilePage(),
    _ => FeedPage(key: _feedKey),
  };

  void _showUploadSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _UploadSourceSheet(
        onPicked: (file) => _handleUpload(file),
      ),
    );
  }

  Future<void> _handleUpload(File file) async {
    // Show uploading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: Card(
          color: Lum.surface,
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Lum.violet),
                SizedBox(height: 16),
                Text('Uploading...', style: TextStyle(color: Colors.white, fontSize: 13)),
              ],
            ),
          ),
        ),
      ),
    );

    final repo = UploadRepository();
    final id = await repo.uploadImage(file);

    if (!mounted) return;
    Navigator.of(context).pop(); // dismiss loading dialog

    if (id != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Post uploaded successfully! ✨'),
          backgroundColor: Color(0xFF2D2D4E),
          behavior: SnackBarBehavior.floating,
        ),
      );
      // Refresh the feed
      _feedKey.currentState?.refreshFeed();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Upload failed. Please try again.'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

// ─── UPLOAD SOURCE SHEET ───────────────────────────────
class _UploadSourceSheet extends StatelessWidget {
  final ValueChanged<File> onPicked;
  const _UploadSourceSheet({required this.onPicked});

  Future<void> _pick(BuildContext context, ImageSource source) async {
    Navigator.pop(context); // close the sheet
    final picker = ImagePicker();
    final xFile = await picker.pickImage(source: source, imageQuality: 85, maxWidth: 1080);
    if (xFile != null) {
      onPicked(File(xFile.path));
    }
  }

  void _openStockGallery(BuildContext context) {
    Navigator.pop(context); // close the sheet
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _StockGalleryPage(onPicked: onPicked),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 16),
    decoration: const BoxDecoration(
      color: Lum.surface,
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      border: Border(top: BorderSide(color: Lum.glassBorder)),
    ),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 36, height: 4, margin: const EdgeInsets.only(top: 10, bottom: 16),
        decoration: BoxDecoration(color: Lum.glassBorder, borderRadius: BorderRadius.circular(2)),
      ),
      const Text('Create Post', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
      const SizedBox(height: 20),
      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        _SourceOption(
          icon: Icons.camera_alt_rounded,
          label: 'Camera',
          gradient: Lum.gradVioletRose,
          onTap: () => _pick(context, ImageSource.camera),
        ),
        _SourceOption(
          icon: Icons.photo_library_rounded,
          label: 'Gallery',
          gradient: Lum.gradVioletAqua,
          onTap: () => _pick(context, ImageSource.gallery),
        ),
        _SourceOption(
          icon: Icons.collections_rounded,
          label: 'Stock',
          gradient: Lum.gradRoseAmber,
          onTap: () => _openStockGallery(context),
        ),
      ]),
      const SizedBox(height: 8),
    ]),
  );
}

class _SourceOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final List<Color> gradient;
  final VoidCallback onTap;
  const _SourceOption({required this.icon, required this.label, required this.gradient, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Column(children: [
      Container(
        width: 60, height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(colors: gradient),
        ),
        child: Icon(icon, color: Colors.white, size: 28),
      ),
      const SizedBox(height: 8),
      Text(label, style: const TextStyle(fontSize: 12, color: Lum.muted)),
    ]),
  );
}

// ─── STOCK GALLERY PAGE (input_images) ─────────────────
class _StockGalleryPage extends StatefulWidget {
  final ValueChanged<File> onPicked;
  const _StockGalleryPage({required this.onPicked});
  @override State<_StockGalleryPage> createState() => _StockGalleryPageState();
}

class _StockGalleryPageState extends State<_StockGalleryPage> {
  static const _stockImages = [
    '02e74545e43e9ff055b27f485fcf8e97.jpg',
    '0962b8afd65bb3b5fb9b8fd119260c63.jpg',
    'cbf9a67349673a220c78f5eed97b7bc4.jpg',
    'cfffe84e00295169068b850ae6b4e3e1.jpg',
    'fd474d7975bd7adc7cfe5bba472e4360.jpg',
    'photo-1575936123452-b67c3203c357.jpeg',
  ];

  bool _saving = false;

  Future<void> _selectImage(String assetName) async {
    setState(() => _saving = true);
    try {
      // Load asset bytes and write to a temp file for upload
      final byteData = await DefaultAssetBundle.of(context).load('assets/input_images/$assetName');
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/stock_$assetName');
      await file.writeAsBytes(byteData.buffer.asUint8List());

      if (!mounted) return;
      Navigator.pop(context); // close gallery
      widget.onPicked(file);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Lum.bg,
    appBar: AppBar(
      backgroundColor: Lum.surface,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text('Stock Images',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
      centerTitle: true,
      elevation: 0,
    ),
    body: _saving
      ? const Center(child: CircularProgressIndicator(color: Lum.violet))
      : GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 0.85,
          ),
          itemCount: _stockImages.length,
          itemBuilder: (_, i) => _StockImageCard(
            assetName: _stockImages[i],
            onTap: () => _selectImage(_stockImages[i]),
          ),
        ),
  );
}

class _StockImageCard extends StatelessWidget {
  final String assetName;
  final VoidCallback onTap;
  const _StockImageCard({required this.assetName, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Lum.glassBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(fit: StackFit.expand, children: [
        Image.asset(
          'assets/input_images/$assetName',
          fit: BoxFit.cover,
        ),
        // Bottom gradient overlay
        Positioned(
          bottom: 0, left: 0, right: 0,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter, end: Alignment.topCenter,
                colors: [Color(0xCC000000), Colors.transparent],
              ),
            ),
            child: Row(children: [
              const Icon(Icons.add_circle_outline_rounded, color: Colors.white, size: 16),
              const SizedBox(width: 6),
              const Text('Use', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)),
            ]),
          ),
        ),
      ]),
    ),
  );
}

// ─── BOTTOM NAV ────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final int current;
  final ValueChanged<int> onChange;
  final VoidCallback onCreateTap;
  const _BottomNav({required this.current, required this.onChange, required this.onCreateTap});

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(40, 0, 40, 12),
      child: GlassBox(
        radius: 44,
        sigma: 30,
        color: const Color(0xD5080812),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _NavItem(icon: Icons.home_outlined,          label: 'Home',    index: 0, current: current, onChange: onChange),
            _NavItem(icon: Icons.search_rounded,         label: 'Explore', index: 1, current: current, onChange: onChange),
            _CreateBtn(onTap: onCreateTap),
            _NavItem(icon: Icons.bookmark_outline,       label: 'Saved',   index: 3, current: current, onChange: onChange),
            _NavItem(icon: Icons.person_outline_rounded, label: 'You',     index: 4, current: current, onChange: onChange),
          ],
        ),
      ),
    ),
  );
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index, current;
  final ValueChanged<int> onChange;
  const _NavItem({required this.icon, required this.label, required this.index, required this.current, required this.onChange});

  @override
  Widget build(BuildContext context) {
    final active = current == index;
    return GestureDetector(
      onTap: () => onChange(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: 46, height: 46,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: active ? Lum.violet.withValues(alpha: 0.16) : Colors.transparent,
        ),
        child: Stack(alignment: Alignment.center, children: [
          Icon(icon, color: active ? Lum.violet : Lum.dim, size: 21),
          if (active)
            Positioned(
              bottom: 7,
              child: Container(
                width: 4, height: 4,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: Lum.gradVioletAqua),
                ),
              ),
            ),
        ]),
      ),
    );
  }
}

class _CreateBtn extends StatefulWidget {
  final VoidCallback onTap;
  const _CreateBtn({required this.onTap});
  @override State<_CreateBtn> createState() => _CreateBtnState();
}

class _CreateBtnState extends State<_CreateBtn> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 240));
  }

  @override
  void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTapDown: (_) => _c.forward(),
    onTapUp:   (_) { _c.reverse(); widget.onTap(); },
    onTapCancel: () => _c.reverse(),
    child: AnimatedBuilder(
      animation: _c,
      builder: (_, child) => Transform.rotate(angle: _c.value * pi / 2, child: child),
      child: Container(
        width: 46, height: 46,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: Lum.gradVioletRose,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [BoxShadow(color: Lum.violet.withValues(alpha: 0.45), blurRadius: 16)],
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
      ),
    ),
  );
}

// ─── FEED PAGE ─────────────────────────────────────────
class FeedPage extends StatefulWidget {
  const FeedPage({super.key});
  @override State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  final _posts      = <PostData>[];
  bool  _loading    = false;
  int   _page       = 0;
  bool  _hasMore    = true;
  String _activeTag = 'All';
  String?  _heartPost;
  final _scroll = ScrollController();
  final _repo   = FeedRepository();

  @override
  void initState() {
    super.initState();
    _loadMore();
    _scroll.addListener(() {
      if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 300) _loadMore();
    });
  }

  @override
  void dispose() { _scroll.dispose(); super.dispose(); }

  /// Called by parent after a new post is uploaded
  void refreshFeed() {
    setState(() {
      _posts.clear();
      _page = 0;
      _hasMore = true;
      _loading = false;
    });
    _loadMore();
  }

  Future<void> _loadMore() async {
    if (_loading || !_hasMore) return;
    setState(() => _loading = true);
    try {
      final posts = await _repo.fetchPage(_page);
      if (!mounted) return;
      setState(() {
        for (final p in posts) {
          _posts.add(PostData(
            id:         p.id,
            imageUrl:   p.mediaMobileUrl,
            thumbUrl:   p.mediaThumbUrl,
            cardHeight: _cardHeights[_posts.length % _cardHeights.length],
            user:       lumUsers[_posts.length % lumUsers.length],
            likes:      p.likeCount,
            saves:      0,
            comments:   p.commentCount,
            tag:        lumTags[1 + (_posts.length % (lumTags.length - 1))],
            liked:      p.isLiked,
          ));
        }
        _page++;
        _hasMore = posts.isNotEmpty;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      debugPrint('LumFeed: Error loading posts: $e');
    }
  }

  static const _cardHeights = [215.0, 275.0, 238.0, 305.0, 258.0, 198.0, 282.0, 318.0, 248.0, 228.0];

  void _like(String id) {
    setState(() {
      final p = _posts.firstWhere((e) => e.id == id);
      p.liked = !p.liked;
    });
    _repo.toggleLike(id);
  }

  void _save(String id) => setState(() {
    final p = _posts.firstWhere((e) => e.id == id);
    p.saved = !p.saved;
  });

  void _doubleLike(String id) {
    setState(() {
      _posts.firstWhere((e) => e.id == id).liked = true;
      _heartPost = id;
    });
    _repo.toggleLike(id);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _heartPost = null);
    });
  }

  List<PostData> get _filtered =>
      _activeTag == 'All' ? _posts : _posts.where((p) => p.tag == _activeTag).toList();

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final col1 = [for (int i = 0; i < filtered.length; i += 2) filtered[i]];
    final col2 = [for (int i = 1; i < filtered.length; i += 2) filtered[i]];

    return CustomScrollView(
      controller: _scroll,
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(child: _FeedHeader(onSearchTap: () {})),
        SliverToBoxAdapter(child: _Stories(onTap: _openStory)),
        SliverToBoxAdapter(child: _Divider()),
        SliverToBoxAdapter(child: _CategoryTabs(active: _activeTag, onSelect: (t) => setState(() => _activeTag = t))),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 20),
          sliver: SliverToBoxAdapter(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _MasonryColumn(posts: col1, heartPost: _heartPost, onLike: _like, onSave: _save, onDouble: _doubleLike, onTap: _openPost)),
                const SizedBox(width: 9),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 22),
                    child: _MasonryColumn(posts: col2, heartPost: _heartPost, onLike: _like, onSave: _save, onDouble: _doubleLike, onTap: _openPost),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: _loading
              ? const Padding(padding: EdgeInsets.symmetric(vertical: 24), child: LumLoadingDots())
              : const SizedBox(height: 110),
        ),
      ],
    );
  }

  void _openStory(StoryData s) => Navigator.push(
    context,
    PageRouteBuilder(
      opaque: false,
      pageBuilder: (_, __, ___) => StoryViewer(story: s),
      transitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (_, anim, __, child) =>
          FadeTransition(opacity: anim, child: ScaleTransition(scale: Tween(begin: 0.94, end: 1.0).animate(anim), child: child)),
    ),
  );

  void _openPost(PostData post) => showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.6),
    builder: (_) => PostSheet(post: post, onLike: () => _like(post.id), onSave: () => _save(post.id)),
  );
}

// ─── FEED HEADER ───────────────────────────────────────
class _FeedHeader extends StatelessWidget {
  final VoidCallback onSearchTap;
  const _FeedHeader({required this.onSearchTap});

  @override
  Widget build(BuildContext context) => ClipRect(
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
      child: Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 12,
          bottom: 14, left: 16, right: 16,
        ),
        decoration: const BoxDecoration(
          color: Color(0x10FFFFFF),
          border: Border(bottom: BorderSide(color: Lum.glassBorder, width: 0.5)),
        ),
        child: Row(children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            ShaderMask(
              shaderCallback: (b) => const LinearGradient(
                colors: [Colors.white, Lum.violet, Lum.aqua],
              ).createShader(b),
              child: Text(
                'lüm',
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 32, fontWeight: FontWeight.w700,
                  fontStyle: FontStyle.italic, color: Colors.white,
                  letterSpacing: -1, height: 1,
                ),
              ),
            ),
            const Text('DISCOVER THE LIGHT',
              style: TextStyle(fontSize: 8, color: Lum.dim, letterSpacing: 2.2)),
          ]),
          const Spacer(),
          _GlassBtn(icon: Icons.search_rounded, onTap: onSearchTap),
          const SizedBox(width: 8),
          Stack(children: [
            _GlassBtn(icon: Icons.notifications_outlined, onTap: () {}),
            Positioned(
              top: 8, right: 8,
              child: Container(
                width: 7, height: 7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(colors: [Lum.rose, Lum.violet]),
                  border: Border.all(color: Lum.bg, width: 1.5),
                ),
              ),
            ),
          ]),
        ]),
      ),
    ),
  );
}

class _GlassBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _GlassBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle, color: Lum.glass,
            border: Border.all(color: Lum.glassBorder),
          ),
          child: Icon(icon, color: Lum.muted, size: 18),
        ),
      ),
    ),
  );
}

// ─── STORIES ROW ───────────────────────────────────────
class _Stories extends StatelessWidget {
  final ValueChanged<StoryData> onTap;
  const _Stories({required this.onTap});

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 96,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: lumStories.length,
      separatorBuilder: (_, __) => const SizedBox(width: 12),
      itemBuilder: (_, i) => _StoryBubble(story: lumStories[i], onTap: () => onTap(lumStories[i])),
    ),
  );
}

class _StoryBubble extends StatefulWidget {
  final StoryData story;
  final VoidCallback onTap;
  const _StoryBubble({required this.story, required this.onTap});
  @override State<_StoryBubble> createState() => _StoryBubbleState();
}

class _StoryBubbleState extends State<_StoryBubble> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 2500))..repeat(reverse: true);
    _opacity = Tween<double>(begin: 1.0, end: 0.55).animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: widget.onTap,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _opacity,
          builder: (_, child) => Opacity(opacity: _opacity.value, child: child),
          child: Container(
            width: 60, height: 60, padding: const EdgeInsets.all(2.5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: widget.story.gradient,
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
            ),
            child: Container(
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Lum.bg),
              padding: const EdgeInsets.all(2),
              clipBehavior: Clip.antiAlias,
              child: widget.story.isMe
                  ? Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(colors: [Lum.violet.withValues(alpha: 0.2), Lum.aqua.withValues(alpha: 0.2)]),
                      ),
                      child: const Icon(Icons.add_rounded, color: Lum.violet, size: 22),
                    )
                  : ClipOval(child: NetImg(imgUrl(widget.story.avatarId!, w: 120, face: true))),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          widget.story.name,
          style: const TextStyle(fontSize: 9, color: Lum.muted),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ),
  );
}

// ─── CATEGORY TABS ─────────────────────────────────────
class _CategoryTabs extends StatelessWidget {
  final String active;
  final ValueChanged<String> onSelect;
  const _CategoryTabs({required this.active, required this.onSelect});

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 46,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      itemCount: lumTags.length,
      separatorBuilder: (_, __) => const SizedBox(width: 7),
      itemBuilder: (_, i) {
        final tag = lumTags[i];
        final on  = active == tag;
        return GestureDetector(
          onTap: () => onSelect(tag),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
            decoration: BoxDecoration(
              gradient: on ? const LinearGradient(colors: Lum.gradVioletAqua) : null,
              color:    on ? null : Lum.glass,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: on ? Colors.transparent : Lum.glassBorder),
              boxShadow: on ? [BoxShadow(color: Lum.violet.withValues(alpha: 0.32), blurRadius: 14)] : null,
            ),
            child: Text(tag,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: on ? Colors.white : Lum.muted)),
          ),
        );
      },
    ),
  );
}

// ─── MASONRY COLUMN ────────────────────────────────────
class _MasonryColumn extends StatelessWidget {
  final List<PostData> posts;
  final String? heartPost;
  final ValueChanged<String> onLike, onSave, onDouble;
  final ValueChanged<PostData> onTap;
  const _MasonryColumn({required this.posts, this.heartPost, required this.onLike,
    required this.onSave, required this.onDouble, required this.onTap});

  @override
  Widget build(BuildContext context) => Column(
    children: posts.map((p) => RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 9),
        child: PhotoCard(
          post: p, showHeart: heartPost == p.id,
          onLike: () => onLike(p.id), onSave: () => onSave(p.id),
          onDouble: () => onDouble(p.id), onTap: () => onTap(p),
        ),
      ),
    )).toList(),
  );
}

// ─── PHOTO CARD ────────────────────────────────────────
class PhotoCard extends StatefulWidget {
  final PostData post;
  final bool showHeart;
  final VoidCallback onLike, onSave, onDouble, onTap;
  const PhotoCard({
    super.key, required this.post, required this.showHeart,
    required this.onLike, required this.onSave, required this.onDouble, required this.onTap,
  });
  @override State<PhotoCard> createState() => _PhotoCardState();
}

class _PhotoCardState extends State<PhotoCard> with SingleTickerProviderStateMixin {
  bool _pressed = false;
  late final AnimationController _hc;
  late final Animation<double> _hs;

  @override
  void initState() {
    super.initState();
    _hc = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _hs = TweenSequence([
      TweenSequenceItem(tween: Tween<double>(begin: 0, end: 1.6), weight: 45),
      TweenSequenceItem(tween: Tween<double>(begin: 1.6, end: 2.4), weight: 55),
    ]).animate(CurvedAnimation(parent: _hc, curve: Curves.easeOut));
  }

  @override
  void dispose() { _hc.dispose(); super.dispose(); }

  @override
  void didUpdateWidget(PhotoCard old) {
    super.didUpdateWidget(old);
    if (widget.showHeart && !old.showHeart) _hc.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: widget.onTap,
    onDoubleTap: widget.onDouble,
    onTapDown: (_) => setState(() => _pressed = true),
    onTapUp:   (_) => setState(() => _pressed = false),
    onTapCancel: () => setState(() => _pressed = false),
    child: AnimatedScale(
      scale: _pressed ? 0.96 : 1.0,
      duration: const Duration(milliseconds: 140),
      child: Stack(children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Lum.glassBorder),
          ),
          clipBehavior: Clip.antiAlias,
          child: SizedBox(
            height: widget.post.cardHeight,
            child: Stack(fit: StackFit.expand, children: [
              NetImg(postImageUrl(widget.post)),
              // Top overlay
              Positioned(
                top: 0, left: 0, right: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 26),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter, end: Alignment.bottomCenter,
                      colors: [Color(0x88000000), Colors.transparent],
                    ),
                  ),
                  child: Row(children: [
                    _Pill(widget.post.tag),
                    const Spacer(),
                    _CircleAction(
                      icon: widget.post.saved ? Icons.bookmark : Icons.bookmark_outline,
                      active: widget.post.saved,
                      activeColor: Lum.violet,
                      onTap: widget.onSave,
                    ),
                  ]),
                ),
              ),
              // Bottom overlay
              Positioned(
                bottom: 0, left: 0, right: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(10, 26, 10, 10),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter, end: Alignment.topCenter,
                      colors: [Color(0xCC000000), Color(0x77000000), Colors.transparent],
                    ),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      ClipOval(
                        child: NetImg(imgUrl(widget.post.user.avatarId, w: 80, face: true), width: 22, height: 22),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(widget.post.user.handle,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
                          overflow: TextOverflow.ellipsis),
                      ),
                    ]),
                    const SizedBox(height: 6),
                    Row(children: [
                      Icon(widget.post.liked ? Icons.favorite : Icons.favorite_outline,
                          size: 11, color: Lum.muted),
                      const SizedBox(width: 3),
                      Text(fmtN(widget.post.likes + (widget.post.liked ? 1 : 0)),
                          style: const TextStyle(fontSize: 10, color: Lum.muted)),
                      const SizedBox(width: 8),
                      const Icon(Icons.chat_bubble_outline, size: 11, color: Lum.muted),
                      const SizedBox(width: 3),
                      Text(fmtN(widget.post.comments),
                          style: const TextStyle(fontSize: 10, color: Lum.muted)),
                      const Spacer(),
                      _CircleAction(
                        icon: widget.post.liked ? Icons.favorite : Icons.favorite_outline,
                        active: widget.post.liked,
                        activeColor: Lum.rose,
                        onTap: widget.onLike,
                      ),
                    ]),
                  ]),
                ),
              ),
            ]),
          ),
        ),
        // Heart burst
        if (widget.showHeart)
          Positioned.fill(
            child: Center(
              child: AnimatedBuilder(
                animation: _hc,
                builder: (_, __) => Opacity(
                  opacity: (1.0 - (_hc.value > 0.5 ? (_hc.value - 0.5) * 2 : 0)).clamp(0.0, 1.0),
                  child: Transform.scale(
                    scale: _hs.value,
                    child: const Text('❤️', style: TextStyle(fontSize: 54)),
                  ),
                ),
              ),
            ),
          ),
      ]),
    ),
  );
}

// ─── SMALL SHARED WIDGETS ──────────────────────────────
class _Pill extends StatelessWidget {
  final String label;
  const _Pill(this.label);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: const Color(0x44000000),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
    ),
    child: Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Lum.muted)),
  );
}

class _CircleAction extends StatelessWidget {
  final IconData icon;
  final bool active;
  final Color activeColor;
  final VoidCallback onTap;
  const _CircleAction({required this.icon, required this.active, required this.activeColor, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 30, height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? activeColor.withValues(alpha: 0.35) : const Color(0x44000000),
        border: Border.all(
          color: active ? activeColor.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.15),
        ),
      ),
      child: Icon(icon, size: 14, color: active ? activeColor : Colors.white),
    ),
  );
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    height: 0.5,
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    decoration: const BoxDecoration(
      gradient: LinearGradient(colors: [Colors.transparent, Lum.glassBorder, Colors.transparent]),
    ),
  );
}

// ─── SAVED PAGE ────────────────────────────────────────
class SavedPage extends StatelessWidget {
  const SavedPage({super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(
        width: 72, height: 72,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(colors: Lum.gradVioletAqua),
        ),
        child: const Icon(Icons.bookmark_outline_rounded, color: Colors.white, size: 32),
      ),
      const SizedBox(height: 16),
      const Text('Nothing saved yet', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Lum.muted)),
      const SizedBox(height: 6),
      const Text('Tap 🏷 on any photo to save it', style: TextStyle(fontSize: 12, color: Lum.dim)),
    ]),
  );
}
