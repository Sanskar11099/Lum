import 'dart:ui';

import 'package:flutter/material.dart';

import 'theme.dart';
import 'widgets.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});
  @override State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _ctrl     = TextEditingController();
  final _trending = ['golden hour', 'minimalist', 'urban', 'botanical', 'editorial', 'neon nights', 'coastal', 'surreal'];
  final _gridPhs  = lumPhotoIds.sublist(0, 9);
  final _gh       = [155.0, 190.0, 170.0, 210.0, 185.0, 150.0, 200.0, 175.0, 165.0];

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => CustomScrollView(
    physics: const BouncingScrollPhysics(),
    slivers: [
      SliverToBoxAdapter(
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 12,
                bottom: 14, left: 14, right: 14,
              ),
              decoration: const BoxDecoration(
                color: Color(0x0FFFFFFF),
                border: Border(bottom: BorderSide(color: Lum.glassBorder, width: 0.5)),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Explore', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: -0.4)),
                const SizedBox(height: 12),
                GlassBox(
                  radius: 30,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  child: Row(children: [
                    const Icon(Icons.search, color: Lum.dim, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _ctrl,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        decoration: const InputDecoration(
                          hintText: 'Search photos, people, places…',
                          hintStyle: TextStyle(color: Lum.muted, fontSize: 13),
                          border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero,
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  ]),
                ),
              ]),
            ),
          ),
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.all(14),
        sliver: SliverToBoxAdapter(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (_ctrl.text.isEmpty) ...[
              const Text('TRENDING', style: TextStyle(fontSize: 10, color: Lum.dim, fontWeight: FontWeight.w600, letterSpacing: 0.8)),
              const SizedBox(height: 10),
              Wrap(spacing: 8, runSpacing: 8, children: _trending.map((t) => GestureDetector(
                onTap: () => setState(() => _ctrl.text = t),
                child: GlassBox(
                  radius: 20,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  child: Text('✦ $t', style: const TextStyle(fontSize: 11, color: Lum.muted)),
                ),
              )).toList()),
              const SizedBox(height: 20),
              const Text('DISCOVER', style: TextStyle(fontSize: 10, color: Lum.dim, fontWeight: FontWeight.w600, letterSpacing: 0.8)),
              const SizedBox(height: 10),
            ],
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [0, 1, 2].map((col) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: col > 0 ? 5 : 0),
                  child: Column(children: [col * 3, col * 3 + 1, col * 3 + 2].map((i) => Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: NetImg(imgUrl(_gridPhs[i], w: 200), height: _gh[i], radius: 10),
                  )).toList()),
                ),
              )).toList(),
            ),
          ]),
        ),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: 100)),
    ],
  );
}
