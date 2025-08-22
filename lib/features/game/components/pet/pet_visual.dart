// lib/features/game/pet/pet_visual.dart
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/cache.dart';
import 'package:per_habit/features/game/components/pet/pet_anim.dart';
import 'package:per_habit/features/habit/domain/entities/pet_type.dart';

class PetVisual {
  const PetVisual._();

  static Future<SpriteAnimationGroupComponent<PetAnim>> create({
    required Images images,
    required PetType petType,
    required double petSize,

    // Constantes (se pasan desde el componente para no cambiar el comportamiento)
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
    final image = await images.load(petType.imagePath);

    final frameW = (image.width / cols).floor();
    final frameH = (image.height / rows).floor();

    SpriteAnimation _rowAnim({
      required int row,
      required int start,
      required int amount,
      required double step,
      bool loop = true,
    }) {
      final sprites = <Sprite>[];
      for (var i = 0; i < amount; i++) {
        final col = start + i;
        sprites.add(
          Sprite(
            image,
            srcPosition: Vector2(
              col * frameW.toDouble(),
              row * frameH.toDouble(),
            ),
            srcSize: Vector2(frameW.toDouble(), frameH.toDouble()),
          ),
        );
      }
      return SpriteAnimation.spriteList(sprites, stepTime: step, loop: loop);
    }

    // filas (0-based):
    // 0 idle1, 1 idle2, 2 walk, 3 carry(air+land), 4 hurt/dizzy, 5 dead, 6 celebrate
    final idle = _rowAnim(row: 0, start: 0, amount: cols - 5, step: idleStep);
    final idleBlink = _rowAnim(
      row: 1,
      start: 0,
      amount: cols - 5,
      step: idleStep,
      loop: false,
    );
    final walk = _rowAnim(row: 2, start: 0, amount: cols - 5, step: walkStep);
    final carryAir = _rowAnim(row: 3, start: 0, amount: 5, step: carryStep);
    final carryLand = _rowAnim(
      row: 3,
      start: 8,
      amount: max(0, cols - 11),
      step: landStep,
      loop: false,
    );
    final hurt = _rowAnim(
      row: 4,
      start: 0,
      amount: min(6, cols),
      step: hurtStep,
    );
    final dizzy = _rowAnim(
      row: 4,
      start: 6,
      amount: max(0, cols - 6),
      step: dizzyStep,
    );
    final dead = _rowAnim(
      row: 5,
      start: 0,
      amount: cols,
      step: deadStep,
      loop: false,
    );
    final celebrate = _rowAnim(
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
