import 'package:flutter/material.dart';

// Minimal moving sprite widget. Uses Hero for correct item so win page can animate a bigger reveal.

class MovingSprite extends StatelessWidget {
  final String imageAsset;
  final bool isGlowing;
  final int id;
  const MovingSprite({
    super.key,
    required this.imageAsset,
    this.isGlowing = false,
    required this.id,
  });

  @override
  Widget build(BuildContext context) {
    final double size = isGlowing ? 78 : 58;
    final Widget img = Image.asset(imageAsset, width: size, height: size);
    final Widget content = SizedBox(
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
                boxShadow: [
                  BoxShadow(
                    color: Colors.orangeAccent.withOpacity(0.55),
                    blurRadius: 14,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          img,
        ],
      ),
    );

    return isGlowing ? Hero(tag: 'correct-hero', child: content) : content;
  }
}
