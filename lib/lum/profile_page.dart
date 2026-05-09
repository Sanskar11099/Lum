import 'package:flutter/material.dart';

import 'theme.dart';
import 'widgets.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _tab  = 'posts';
  final _posts = generatePosts(0, 9);

  @override
  Widget build(BuildContext context) => CustomScrollView(
    physics: const BouncingScrollPhysics(),
    slivers: [
      SliverToBoxAdapter(child: Stack(clipBehavior: Clip.none, children: [
        SizedBox(
          height: 190,
          child: NetImg(imgUrl(lumPhotoIds[3], w: 500, h: 300), width: double.infinity, height: 190),
        ),
        Container(
          height: 190,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter, end: Alignment.bottomCenter,
              colors: [Colors.black.withValues(alpha: 0.4), Lum.bg],
              stops: const [0.4, 1.0],
            ),
          ),
        ),
      ])),
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverToBoxAdapter(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Avatar
            Container(
              width: 76, height: 76,
              margin: const EdgeInsets.only(top: -38, bottom: 12),
              padding: const EdgeInsets.all(2.5),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: Lum.gradVioletRose),
              ),
              child: Container(
                decoration: const BoxDecoration(shape: BoxShape.circle, color: Lum.bg),
                padding: const EdgeInsets.all(2),
                clipBehavior: Clip.antiAlias,
                child: ClipOval(
                  child: NetImg('https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?w=160&q=80&fit=crop&crop=face'),
                ),
              ),
            ),
            const Text('Your Name', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
            const SizedBox(height: 2),
            const Text('@yourhandle', style: TextStyle(fontSize: 11, color: Lum.violet)),
            const SizedBox(height: 6),
            const Text('Visual storyteller · Chasing golden hours ✦',
              style: TextStyle(fontSize: 12, color: Lum.muted, height: 1.6)),
            const SizedBox(height: 14),
            // Stats
            IntrinsicHeight(
              child: Row(children: [
                _Stat(value: '248',   label: 'Posts'),
                VerticalDivider(color: Lum.glassBorder.withValues(alpha: 0.5), width: 1),
                _Stat(value: '18.4k', label: 'Followers'),
                VerticalDivider(color: Lum.glassBorder.withValues(alpha: 0.5), width: 1),
                _Stat(value: '312',   label: 'Following'),
              ]),
            ),
            const SizedBox(height: 14),
            // Buttons
            Row(children: [
              Expanded(
                child: GlassBox(
                  radius: 20, padding: const EdgeInsets.symmetric(vertical: 9),
                  child: const Center(child: Text('Edit Profile',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white))),
                ),
              ),
              const SizedBox(width: 8),
              GlassBox(
                radius: 20, padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                child: const Icon(Icons.ios_share, color: Lum.muted, size: 18),
              ),
            ]),
            const SizedBox(height: 14),
            // Tab bar
            Row(
              children: ['posts', 'saved'].map((t) => Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _tab = t),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: _tab == t ? Lum.violet : Lum.glassBorder.withValues(alpha: 0.5),
                          width: _tab == t ? 2 : 0.5,
                        ),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      t[0].toUpperCase() + t.substring(1),
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _tab == t ? Colors.white : Lum.muted),
                    ),
                  ),
                ),
              )).toList(),
            ),
            const SizedBox(height: 10),
            // Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, crossAxisSpacing: 5, mainAxisSpacing: 5,
              ),
              itemCount: _posts.length,
              itemBuilder: (_, i) => NetImg(postImageUrl(_posts[i], thumb: true), radius: 10),
            ),
            const SizedBox(height: 110),
          ]),
        ),
      ),
    ],
  );
}

class _Stat extends StatelessWidget {
  final String value, label;
  const _Stat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(children: [
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
        const SizedBox(height: 2),
        Text(label.toUpperCase(), style: const TextStyle(fontSize: 9, color: Lum.muted, letterSpacing: 0.5)),
      ]),
    ),
  );
}
