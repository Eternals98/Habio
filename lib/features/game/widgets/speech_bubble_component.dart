import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// Globo de texto con fondo blanco, borde redondeado y “colita”.
/// Añádelo como hijo del pet para que siga su posición.
/// Usa anchor = bottomCenter y colócalo con y negativa para que quede encima.
class SpeechBubbleComponent extends PositionComponent with HasGameRef {
  final String text;
  final double maxWidth;
  final double padding;
  final double radius;
  final double tailSize;
  final double elevation;
  final double lifetime; // segundos visibles
  final double fadeSec; // segundos de animación (in/out)

  late TextPainter _painter;
  late double _bubbleW;
  late double _bubbleH;
  double _age = 0; // tiempo transcurrido
  double _opacity = 0;

  SpeechBubbleComponent({
    required this.text,
    this.maxWidth = 220,
    this.padding = 10,
    this.radius = 14,
    this.tailSize = 10,
    this.elevation = 4,
    this.lifetime = 2.5,
    this.fadeSec = 0.18,
  }) : super(anchor: Anchor.bottomCenter);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Prepara TextPainter (usa estilo negro sobre blanco)
    _painter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 13,
          height: 1.25,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 5,
      ellipsis: '…',
    );

    // Limitar ancho del texto
    _painter.layout(maxWidth: maxWidth - padding * 2);

    _bubbleW = min(maxWidth, _painter.width + padding * 2);
    _bubbleH = _painter.height + padding * 2;

    // El componente ocupará el tamaño del rectángulo del globo
    size = Vector2(_bubbleW, _bubbleH + tailSize);

    // Anchor bottomCenter => coloca y negativa para quedar encima del pet
    // (El padre se encargará de la X/Y global)
  }

  @override
  void update(double dt) {
    super.update(dt);
    _age += dt;

    // Fade-in
    if (_age < fadeSec) {
      _opacity = (_age / fadeSec).clamp(0, 1);
    } else if (_age > lifetime - fadeSec) {
      // Fade-out
      final t = (lifetime - _age) / fadeSec;
      _opacity = t.clamp(0, 1);
    } else {
      _opacity = 1;
    }

    if (_age >= lifetime) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Opacidad
    final paint = Paint()..color = Colors.white.withOpacity(_opacity);
    final borderPaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..color = Colors.black12.withOpacity(_opacity);

    // Sombra sutil
    final shadowPaint =
        Paint()
          ..color = Colors.black.withOpacity(0.08 * _opacity)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    // Rect principal (sin colita)
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, _bubbleW, _bubbleH),
      Radius.circular(radius),
    );

    // “Colita” hacia abajo, centrada
    final tailPath =
        Path()
          ..moveTo(_bubbleW / 2 - tailSize, _bubbleH)
          ..lineTo(_bubbleW / 2, _bubbleH + tailSize)
          ..lineTo(_bubbleW / 2 + tailSize, _bubbleH)
          ..close();

    // Sombra detrás
    canvas.save();
    canvas.translate(0, elevation); // desplazar la sombra hacia abajo
    canvas.drawRRect(rrect, shadowPaint);
    canvas.drawPath(tailPath, shadowPaint);
    canvas.restore();

    // Fondo
    canvas.drawRRect(rrect, paint);
    canvas.drawPath(tailPath, paint);

    // Borde
    canvas.drawRRect(rrect, borderPaint);
    canvas.drawPath(tailPath, borderPaint);

    // Texto
    _painter.paint(
      canvas,
      Offset((_bubbleW - _painter.width) / 2, (_bubbleH - _painter.height) / 2),
    );
  }
}
