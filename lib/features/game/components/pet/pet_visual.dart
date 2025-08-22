import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/cache.dart';
import 'package:per_habit/features/game/components/pet/pet_anim.dart';

class PetVisual {
  const PetVisual._();

  /// Crea el componente a partir de un **path** directo (convención: pets/<id>_full.png)
  static Future<SpriteAnimationGroupComponent<PetAnim>> createFromPath({
    required Images images,
    required String imagePath,
    required double petSize,
    required int cols,
    required int rows,
    required double idleStep,
    required double walkStep,
    required double carryStep,
    required double landStep,
    required double hurtStep,
    required double dizzyStep,
    required double celebrateStep,
    required double deadStep,
  }) async {
    final image = await images.load(imagePath);

    final frameW = (image.width / cols).floor();
    final frameH = (image.height / rows).floor();

    SpriteAnimation _row({
      required int row,
      required int start,
      required int amount,
      required double step,
      bool loop = true,
    }) {
      final sprites = List.generate(amount, (i) {
        final col = start + i;
        return Sprite(
          image,
          srcPosition: Vector2(
            col * frameW.toDouble(),
            row * frameH.toDouble(),
          ),
          srcSize: Vector2(frameW.toDouble(), frameH.toDouble()),
        );
      });
      return SpriteAnimation.spriteList(sprites, stepTime: step, loop: loop);
    }

    // Animaciones (mismas filas/segmentos que usabas)
    final idle = _row(row: 0, start: 0, amount: cols - 5, step: idleStep);
    final idleBlink = _row(
      row: 1,
      start: 0,
      amount: cols - 5,
      step: idleStep,
      loop: false,
    );
    final walk = _row(row: 2, start: 0, amount: cols - 5, step: walkStep);
    final carryAir = _row(row: 3, start: 0, amount: 5, step: carryStep);
    final carryLand = _row(
      row: 3,
      start: 8,
      amount: max(0, cols - 11),
      step: landStep,
      loop: false,
    );
    final hurt = _row(row: 4, start: 0, amount: min(6, cols), step: hurtStep);
    final dizzy = _row(
      row: 4,
      start: 6,
      amount: max(0, cols - 6),
      step: dizzyStep,
    );
    final dead = _row(
      row: 5,
      start: 0,
      amount: cols,
      step: deadStep,
      loop: false,
    );
    final celebrate = _row(
      row: 6,
      start: 0,
      amount: cols - 8,
      step: celebrateStep,
      loop: false,
    );

    return SpriteAnimationGroupComponent<PetAnim>(
      animations: {
        PetAnim.idle: idle,
        PetAnim.idleBlink: idleBlink,
        PetAnim.walk: walk,
        PetAnim.carryAir: carryAir,
        PetAnim.carryLand: carryLand,
        PetAnim.hurt: hurt,
        PetAnim.dizzy: dizzy,
        PetAnim.celebrate: celebrate,
        PetAnim.dead: dead,
      },
      current: PetAnim.idle,
      size: Vector2.all(petSize),
      anchor: Anchor.center,
    );
  }
}
