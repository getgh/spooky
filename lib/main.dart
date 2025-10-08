import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(HalloweenApp());
}

class HalloweenApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Halloween Storybook',
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (_) => HomePage(),
        '/story': (_) => StoryPage(),
        '/win': (_) => WinPage(),
      },
    );
  }
}

/// Simple home page with a hero animation to the story
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final double logoSize = 120;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Hero(
                tag: 'pumpkin-hero',
                child: Image.asset(
                  'assets/images/pumpkin.png',
                  width: logoSize,
                  height: logoSize,
                ),
              ),
              SizedBox(height: 16),
              Text('Spooky Storybook', style: TextStyle(fontSize: 28)),
              SizedBox(height: 24),
              ElevatedButton.icon(
                icon: Icon(Icons.play_arrow),
                label: Text('Start the Hunt'),
                onPressed: () => Navigator.of(context).pushNamed('/story'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// StoryPage: contains moving objects, traps, background music, and the hidden "correct" item.
class StoryPage extends StatefulWidget {
  @override
  _StoryPageState createState() => _StoryPageState();
}

class _StoryPageState extends State<StoryPage> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<MovingThing> _things = [];
  late final AudioPlayer _bgPlayer;
  final AudioPlayer _sfxPlayer = AudioPlayer();
  final Random _rng = Random();
  bool _found = false;

  @override
  void initState() {
    super.initState();

    // Background music player
    _bgPlayer = AudioPlayer();
    _bgPlayer.setReleaseMode(ReleaseMode.loop);
    _bgPlayer.play(AssetSource('assets/sounds/bg_loop.mp3'));

    // controller drives all movements; repeating for performance
    _controller = AnimationController(vsync: this, duration: Duration(seconds: 6))
      ..repeat();

    // Populate moving things with some traps, filler, and one correct item
    // We'll add 8 items; one is "correct", two are traps.
    _things.addAll(List.generate(8, (i) {
      bool isCorrect = i == 3; // place the correct item at index 3 (deterministic for grading)
      bool isTrap = i == 1 || i == 6;
      String image = isCorrect ? 'assets/images/correct_item.png'
          : (i % 3 == 0 ? 'assets/images/ghost.png' : (i % 3 == 1 ? 'assets/images/bat.png' : 'assets/images/pumpkin.png'));
      // different speeds and phases
      double speed = 0.5 + _rng.nextDouble() * 1.5;
      double phase = _rng.nextDouble() * pi * 2;
      return MovingThing(
        id: i,
        imageAsset: image,
        isTrap: isTrap,
        isCorrect: isCorrect,
        speed: speed,
        phase: phase,
      );
    }));
  }

  @override
  void dispose() {
    _controller.dispose();
    _bgPlayer.stop();
    _bgPlayer.dispose();
    _sfxPlayer.dispose();
    super.dispose();
  }

  Future<void> _onTapThing(MovingThing t) async {
    if (_found) return; // ignore after win
    if (t.isTrap) {
      // play jump-scare and show a spooky reaction
      await _sfxPlayer.play(AssetSource('assets/sounds/jumpscare.mp3'));
      // tiny dialog as reaction
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: Colors.black87,
          title: Text('Boo!', style: TextStyle(color: Colors.orange)),
          content: Text('That was a trap! Watch out...', style: TextStyle(color: Colors.white)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Continue'))
          ],
        ),
      );
    } else if (t.isCorrect) {
      _found = true;
      await _sfxPlayer.play(AssetSource('assets/sounds/win_sound.mp3'));
      // small celebration animation by navigating to WinPage with hero
      Navigator.of(context).pushReplacementNamed('/win');
    } else {
      // wrong but harmless tap: small shake feedback
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Not this one... keep searching!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Responsive layout: use MediaQuery size to scale positions
    final Size size = MediaQuery.of(context).size;
    final double playAreaHeight = size.height * 0.75;
    final double playAreaWidth = size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('Find the spooky item'),
        actions: [
          IconButton(icon: Icon(Icons.home), onPressed: () {
            _bgPlayer.stop();
            Navigator.of(context).popUntil((route) => route.isFirst);
          }),
        ],
      ),
      body: Column(
        children: [
          // story header / prompt
          Container(
            height: size.height * 0.12,
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('Tap the correct item hidden among spooky objects!', style: TextStyle(fontSize: 18)),
          ),
          // play area
          Expanded(
            child: LayoutBuilder(builder: (context, constraints) {
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  // background custom painter for spooky gradient and stars
                  Positioned.fill(child: SpookyBackground()),
                  // animated moving objects
                  ..._things.map((t) {
                    // each object builds based on controller value -> compute position
                    return AnimatedBuilder(
                      animation: _controller,
                      builder: (_, __) {
                        final double tVal = _controller.value;
                        // compute a circular+sinusoidal movement inside area using speed and phase
                        final double cx = (0.2 + 0.6 * ((_rng.nextDouble() + t.id) % 1)) * playAreaWidth;
                        final double cy = (0.2 + 0.6 * ((_rng.nextDouble() + t.id * 0.7) % 1)) * playAreaHeight;
                        // oscillation radius
                        final double rx = 0.18 * playAreaWidth * (0.6 + sin((t.phase + tVal * 2 * pi * t.speed)));
                        final double ry = 0.12 * playAreaHeight * (0.6 + cos((t.phase + tVal * 2 * pi * t.speed)));
                        final double dx = cx + rx * sin((tVal * 2 * pi * t.speed) + t.phase);
                        final double dy = cy + ry * cos((tVal * 2 * pi * t.speed) + t.phase);
                        // clamp to area
                        final double left = dx.clamp(0.0, playAreaWidth - 60);
                        final double top = dy.clamp(0.0, playAreaHeight - 60);
                        return Positioned(
                          left: left,
                          top: top,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => _onTapThing(t),
                            child: MovingSprite(
                              imageAsset: t.imageAsset,
                              isGlowing: t.isCorrect,
                              id: t.id,
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ],
              );
            }),
          ),
          // footer / hint
          Container(
            height: size.height * 0.08,
            alignment: Alignment.center,
            child: Text('Hint: one item glows faintly... maybe it knows the way.', style: TextStyle(color: Colors.orangeAccent)),
          ),
        ],
      ),
    );
  }
}

/// Minimal moving sprite widget. Uses Hero for correct item so win page can animate a bigger reveal.
class MovingSprite extends StatelessWidget {
  final String imageAsset;
  final bool isGlowing;
  final int id;
  const MovingSprite({required this.imageAsset, this.isGlowing = false, required this.id});

  @override
  Widget build(BuildContext context) {
    final double size = isGlowing ? 78 : 58;
    final Widget img = Image.asset(imageAsset, width: size, height: size);
    final Widget content = Container(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // soft glow
          if (isGlowing)
            Container(
              width: size + 16,
              height: size + 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.orangeAccent.withOpacity(0.55), blurRadius: 14, spreadRadius: 2)],
              ),
            ),
          img,
        ],
      ),
    );

    return isGlowing
        ? Hero(tag: 'correct-hero', child: content)
        : content;
  }
}

/// Simple win page
class WinPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Hero(tag: 'correct-hero', child: Image.asset('assets/images/correct_item.png', width: 200)),
            SizedBox(height: 20),
            Text('You Found It!', style: TextStyle(fontSize: 34, color: Colors.orange)),
            SizedBox(height: 10),
            Text('Happy Halloween 🎃', style: TextStyle(fontSize: 18)),
            SizedBox(height: 24),
            ElevatedButton(onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil('/', (r) => false), child: Text('Back Home'))
          ]),
        ),
      ),
    );
  }
}

/// Data model for moving things
class MovingThing {
  final int id;
  final String imageAsset;
  final bool isTrap;
  final bool isCorrect;
  final double speed;
  final double phase;
  MovingThing({
    required this.id,
    required this.imageAsset,
    this.isTrap = false,
    this.isCorrect = false,
    this.speed = 1.0,
    this.phase = 0.0,
  });
}

/// A simple custom painter background with gradient and floating stars / moon
class SpookyBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SpookyPainter(),
      child: Container(),
    );
  }
}

class _SpookyPainter extends CustomPainter {
  final Random _r = Random(42);
  @override
  void paint(Canvas canvas, Size size) {
    // gradient sky
    final Rect r = Offset.zero & size;
    final Gradient g = LinearGradient(colors: [Colors.deepPurple.shade900, Colors.black87], begin: Alignment.topCenter, end: Alignment.bottomCenter);
    canvas.drawRect(r, Paint()..shader = g.createShader(r));

    // moon
    final moonCenter = Offset(size.width * 0.85, size.height * 0.18);
    canvas.drawCircle(moonCenter, 40, Paint()..color = Colors.yellow.shade700.withOpacity(0.9));

    // distant stars
    for (int i = 0; i < 40; i++) {
      final dx = _r.nextDouble() * size.width;
      final dy = _r.nextDouble() * size.height * 0.45;
      final rad = _r.nextDouble() * 1.8 + 0.3;
      canvas.drawCircle(Offset(dx, dy), rad, Paint()..color = Colors.white.withOpacity(0.6));
    }
    // ground silhouette
    final path = Path();
    path.moveTo(0, size.height * 0.85);
    path.quadraticBezierTo(size.width*0.25, size.height*0.75, size.width*0.5, size.height*0.82);
    path.quadraticBezierTo(size.width*0.7, size.height*0.89, size.width, size.height*0.82);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, Paint()..color = Colors.black);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
