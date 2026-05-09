import 'package:flutter/material.dart';

import 'widgets.dart';

class StoryViewer extends StatefulWidget {
  final StoryData story;
  const StoryViewer({super.key, required this.story});
  @override State<StoryViewer> createState() => _StoryViewerState();
}

class _StoryViewerState extends State<StoryViewer> with SingleTickerProviderStateMixin {
  int _seg = 0;
  final _phs = [lumPhotoIds[0], lumPhotoIds[7], lumPhotoIds[14]];
  late final AnimationController _prog;

  @override
  void initState() {
    super.initState();
    _prog = AnimationController(vsync: this, duration: const Duration(seconds: 4))
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed) {
          if (_seg < _phs.length - 1) { setState(() { _seg++; _prog.forward(from: 0); }); }
          else { Navigator.of(context).pop(); }
        }
      })
      ..forward();
  }

  @override
  void dispose() { _prog.dispose(); super.dispose(); }

  void _prev() {
    if (_seg > 0) { setState(() { _seg--; _prog.forward(from: 0); }); }
  }
  void _next() {
    if (_seg < _phs.length - 1) { setState(() { _seg++; _prog.forward(from: 0); }); }
    else { Navigator.of(context).pop(); }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.black,
    body: GestureDetector(
      onTapUp: (d) => d.globalPosition.dx < MediaQuery.of(context).size.width / 2 ? _prev() : _next(),
      child: Stack(fit: StackFit.expand, children: [
        NetImg(imgUrl(_phs[_seg], w: 500, h: 900)),
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter, end: Alignment.bottomCenter,
              colors: [Color(0x99000000), Colors.transparent, Colors.transparent, Color(0xBB000000)],
              stops: [0, 0.25, 0.65, 1],
            ),
          ),
        ),
        // Progress bars
        Positioned(
          top: MediaQuery.of(context).padding.top + 14,
          left: 12, right: 12,
          child: Row(
            children: List.generate(_phs.length, (i) => Expanded(
              child: Container(
                height: 2.5,
                margin: const EdgeInsets.symmetric(horizontal: 2.5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(2),
                ),
                clipBehavior: Clip.antiAlias,
                child: i < _seg
                    ? Container(color: Colors.white)
                    : i == _seg
                        ? AnimatedBuilder(
                            animation: _prog,
                            builder: (_, __) => FractionallySizedBox(
                              widthFactor: _prog.value,
                              alignment: Alignment.centerLeft,
                              child: Container(color: Colors.white),
                            ),
                          )
                        : const SizedBox(),
              ),
            )),
          ),
        ),
        // User row
        Positioned(
          top: MediaQuery.of(context).padding.top + 28,
          left: 12, right: 12,
          child: Row(children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 1.5),
              ),
              clipBehavior: Clip.antiAlias,
              child: widget.story.avatarId != null
                  ? NetImg(imgUrl(widget.story.avatarId!, w: 80, face: true))
                  : Container(
                      decoration: BoxDecoration(gradient: LinearGradient(colors: widget.story.gradient)),
                      child: const Center(child: Text('✦', style: TextStyle(color: Colors.white, fontSize: 14))),
                    ),
            ),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(widget.story.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
              Text('2 hrs ago', style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.55))),
            ])),
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.1),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ),
          ]),
        ),
        // Caption
        Positioned(
          bottom: 44, left: 16, right: 16,
          child: Text('✦ Chasing light across silent horizons',
            style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.88), height: 1.6)),
        ),
      ]),
    ),
  );
}
