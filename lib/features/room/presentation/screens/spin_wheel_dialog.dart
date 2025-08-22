// lib/features/room/presentation/screens/spin_wheel_dialog.dart
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:per_habit/core/config/providers/config_provider.dart';
import 'package:per_habit/features/store/data/models/catalogo_item_model.dart';

// Providers asumidos existentes según tu contexto:
// - availableSpinsFromMetaProvider(String uid) -> Future<int>
// - consumeOneSpinProvider(String uid) -> Future<void>
// - wheelPrizePoolProvider -> Stream<List<CatalogItemModel>>
// - grantCatalogPrizeProvider(({String uid, String itemId})) -> Future<void>

class SpinWheelDialog extends ConsumerStatefulWidget {
  final String uid;
  const SpinWheelDialog({super.key, required this.uid});

  static Future<void> show(BuildContext context, WidgetRef _, String uid) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder:
          (_) => Dialog(
            insetPadding: const EdgeInsets.all(16),
            child: SizedBox(
              width: 380,
              height: 520,
              child: SpinWheelDialog(uid: uid),
            ),
          ),
    );
  }

  @override
  ConsumerState<SpinWheelDialog> createState() => _SpinWheelDialogState();
}

class _SpinWheelDialogState extends ConsumerState<SpinWheelDialog>
    with SingleTickerProviderStateMixin {
  // Animación de la rueda
  late final AnimationController _ctrl;
  late Animation<double> _anim;
  double _currentAngle = 0;
  bool _spinning = false;
  String? _lastPrizeName;

  // Para el botón de “añadir spin de prueba”
  bool _addingTestSpin = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _addExtraSpin() async {
    setState(() => _addingTestSpin = true);
    try {
      final db = FirebaseFirestore.instance;
      ref.invalidate(availableSpinsFromMetaProvider(widget.uid));
      ref.invalidate(userWheelMetaProvider(widget.uid)); // opcional
      final metaDoc = db
          .collection('users')
          .doc(widget.uid)
          .collection('wheel')
          .doc('meta');

      await db.runTransaction((tx) async {
        final snap = await tx.get(metaDoc);
        final curr = (snap.data()?['extraSpins'] as num?)?.toInt() ?? 0;
        tx.set(metaDoc, {'extraSpins': curr + 1}, SetOptions(merge: true));
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Añadido 1 spin de prueba')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _addingTestSpin = false);
    }
  }

  Future<void> _spin(List<_Slice> slices) async {
    if (_spinning || slices.isEmpty) return;
    setState(() => _spinning = true);

    try {
      // 1) Consumir spin
      await ref.read(consumeOneSpinProvider(widget.uid).future);
      ref.invalidate(availableSpinsFromMetaProvider(widget.uid));
      ref.invalidate(userWheelMetaProvider(widget.uid)); // opcional

      // 2) Elegir segmento ponderado (pesos enteros)
      final int totalW = slices.fold<int>(0, (a, s) => a + s.weight);
      final rnd = Random().nextInt(totalW > 0 ? totalW : 1);
      int acc = 0;
      late _Slice selected;
      for (final s in slices) {
        acc += s.weight;
        if (rnd < acc) {
          selected = s;
          break;
        }
      }

      // Ángulo objetivo (centro del segmento)
      final targetAngle = (selected.start + selected.end) / 2;

      // Vueltas completas + destino
      final spins = 4 + Random().nextInt(3); // 4 a 6 vueltas
      final target = (spins * 2 * pi) + targetAngle;

      final tween = Tween<double>(begin: _currentAngle, end: target);
      _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
      _ctrl
        ..reset()
        ..addListener(() {
          setState(() {
            _currentAngle = tween.transform(_anim.value);
          });
        });

      await _ctrl.forward();

      // 3) Otorgar premio
      await ref.read(
        grantCatalogPrizeProvider((
          uid: widget.uid,
          itemId: selected.id,
        )).future,
      );

      setState(() => _lastPrizeName = selected.name);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al girar: $e')));
      }
    } finally {
      if (mounted) setState(() => _spinning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final spinsAsync = ref.watch(availableSpinsFromMetaProvider(widget.uid));
    final poolAsync = ref.watch(wheelPrizePoolProvider);

    final int spins = spinsAsync.valueOrNull ?? 0;
    // Fuerza tipado fuerte del pool
    final List<CatalogItemModel> pool =
        poolAsync.valueOrNull ?? <CatalogItemModel>[];

    final slices = _buildSlices(pool);

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Column(
            children: [
              // Header
              Row(
                children: [
                  Text('Ruleta', style: Theme.of(context).textTheme.titleLarge),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: _addingTestSpin ? null : _addExtraSpin,
                    icon:
                        _addingTestSpin
                            ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : const Icon(Icons.add),
                    label: const Text('Spin test'),
                  ),
                ],
              ),
              if (_lastPrizeName != null) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Último premio: $_lastPrizeName',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ),
                const SizedBox(height: 4),
              ],
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Rueda
                        Transform.rotate(
                          angle: _currentAngle % (2 * pi),
                          child: CustomPaint(
                            painter: _WheelPainter(slices: slices),
                            child: const SizedBox.expand(),
                          ),
                        ),
                        // Indicador superior
                        Positioned(
                          top: 6,
                          child: Icon(
                            Icons.arrow_drop_down,
                            size: 36,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        // Botón SPIN
                        IgnorePointer(
                          ignoring: _spinning || spins <= 0 || pool.isEmpty,
                          child: ElevatedButton(
                            onPressed:
                                (_spinning || spins <= 0 || pool.isEmpty)
                                    ? null
                                    : () => _spin(slices),
                            child:
                                _spinning
                                    ? const SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                    : const Text('SPIN'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Premios posibles (horizontal)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Posibles premios (${pool.length})',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                height: 90,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: pool.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final it = pool[i];
                    return Container(
                      width: 140,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).dividerColor,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(it.icono, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Text(
                            it.nombre,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'peso: ${it.wheelWeight}',
                            style: const TextStyle(fontSize: 11),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cerrar'),
                ),
              ),
            ],
          ),
        ),
        // Overlay de spins disponibles
        Positioned(
          right: 8,
          top: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: spinsAsync.when(
              data: (n) => Text('Spins: $n'),
              loading: () => const Text('Spins: …'),
              error: (_, __) => const Text('Spins: ?'),
            ),
          ),
        ),
      ],
    );
  }

  // Construye segmentos según pesos (tipado fuerte)
  List<_Slice> _buildSlices(List<CatalogItemModel> pool) {
    if (pool.isEmpty) return const [];
    final int total = pool.fold<int>(
      0,
      (a, it) => a + ((it.wheelWeight) as num).toInt(),
    );
    if (total <= 0) return const [];

    double cursor = 0.0;
    final List<_Slice> out = [];
    for (final it in pool) {
      int w = ((it.wheelWeight) as num).toInt();
      if (w < 1) w = 1;

      final frac = w / total;
      final size = 2 * pi * frac;
      out.add(
        _Slice(
          id: it.id,
          name: it.nombre,
          icon: it.icono,
          weight: w,
          start: cursor,
          end: cursor + size,
        ),
      );
      cursor += size;
    }
    return out;
  }
}

class _Slice {
  final String id;
  final String name;
  final String icon;
  final int weight;
  final double start;
  final double end;
  const _Slice({
    required this.id,
    required this.name,
    required this.icon,
    required this.weight,
    required this.start,
    required this.end,
  });
}

class _WheelPainter extends CustomPainter {
  final List<_Slice> slices;
  const _WheelPainter({required this.slices});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = min(size.width, size.height) / 2 - 8;

    final fill = Paint()..style = PaintingStyle.fill;
    final stroke =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = Colors.black.withOpacity(0.18);

    final tp = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    for (var i = 0; i < slices.length; i++) {
      final s = slices[i];
      final rect = Rect.fromCircle(center: center, radius: radius);
      final sweep = s.end - s.start;

      // Color alternado simple
      fill.color = Colors.primaries[i % Colors.primaries.length].shade300;

      canvas.drawArc(rect, s.start, sweep, true, fill);
      canvas.drawArc(rect, s.start, sweep, true, stroke);

      // Etiqueta (icono o nombre) al centro del segmento
      final mid = s.start + sweep / 2;
      final rText = radius * 0.62;
      final pos = center + Offset(cos(mid) * rText, sin(mid) * rText);

      final label = (s.icon.isNotEmpty ? s.icon : s.name);
      tp.text = TextSpan(
        text: label,
        style: const TextStyle(fontSize: 12, color: Colors.black87),
      );
      tp.layout(maxWidth: radius * 0.9);

      canvas.save();
      canvas.translate(pos.dx - tp.width / 2, pos.dy - tp.height / 2);
      tp.paint(canvas, Offset.zero);
      canvas.restore();
    }

    // Borde exterior
    canvas.drawCircle(center, radius, stroke);
  }

  @override
  bool shouldRepaint(covariant _WheelPainter oldDelegate) {
    return oldDelegate.slices != slices;
  }
}
