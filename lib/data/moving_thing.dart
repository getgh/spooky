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
