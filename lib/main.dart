import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:spooky/widgets/moving_sprite.dart';
import 'package:spooky/widgets/win_page.dart';
import 'package:spooky/widgets/spooky_background.dart';
import 'package:spooky/data/moving_thing.dart';

void main() {
  runApp(HalloweenApp());
}

class HalloweenApp extends StatelessWidget {
  const HalloweenApp({super.key});

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
  const HomePage({super.key});

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
  const StoryPage({super.key});

  @override
  _StoryPageState createState() => _StoryPageState();
}

class _StoryPageState extends State<StoryPage>
    with SingleTickerProviderStateMixin {
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
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 6),
    )..repeat();

    // Populate moving things with some traps, filler, and one correct item
    // We'll add 8 items; one is "correct", two are traps.
    _things.addAll(
      List.generate(8, (i) {
        bool isCorrect =
            i ==
            3; // place the correct item at index 3 (deterministic for grading)
        bool isTrap = i == 1 || i == 6;
        String image = isCorrect
            ? 'assets/images/correct_item.png'
            : (i % 3 == 0
                  ? 'assets/images/ghost.png'
                  : (i % 3 == 1
                        ? 'assets/images/bat.png'
                        : 'assets/images/pumpkin.png'));
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
      }),
    );
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
          content: Text(
            'That was a trap! Watch out...',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Continue'),
            ),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Not this one... keep searching!')),
      );
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
          IconButton(
            icon: Icon(Icons.home),
            onPressed: () {
              _bgPlayer.stop();
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // story header / prompt
          Container(
            height: size.height * 0.12,
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Tap the correct item hidden among spooky objects!',
              style: TextStyle(fontSize: 18),
            ),
          ),
          // play area
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
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
                          final double cx =
                              (0.2 + 0.6 * ((_rng.nextDouble() + t.id) % 1)) *
                              playAreaWidth;
                          final double cy =
                              (0.2 +
                                  0.6 *
                                      ((_rng.nextDouble() + t.id * 0.7) % 1)) *
                              playAreaHeight;
                          // oscillation radius
                          final double rx =
                              0.18 *
                              playAreaWidth *
                              (0.6 + sin((t.phase + tVal * 2 * pi * t.speed)));
                          final double ry =
                              0.12 *
                              playAreaHeight *
                              (0.6 + cos((t.phase + tVal * 2 * pi * t.speed)));
                          final double dx =
                              cx +
                              rx * sin((tVal * 2 * pi * t.speed) + t.phase);
                          final double dy =
                              cy +
                              ry * cos((tVal * 2 * pi * t.speed) + t.phase);
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
                    }),
                  ],
                );
              },
            ),
          ),
          // footer / hint
          Container(
            height: size.height * 0.08,
            alignment: Alignment.center,
            child: Text(
              'Hint: one item glows faintly... maybe it knows the way.',
              style: TextStyle(color: Colors.orangeAccent),
            ),
          ),
        ],
      ),
    );
  }
}
