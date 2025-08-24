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
// - userWheelMetaProvider(String uid) -> Future<Map<String, dynamic>>

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
              height: 560,
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

  // (Opcional) estado UI para anuncios recompensados
  bool _loadingAd = false; // <-- usado en bloque comentado de ads

  // Ángulo del puntero superior (top). En Canvas, "arriba" ≈ -pi/2.
  static const double _pointerAngle = -pi / 2;

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

  // ------------------ Helpers ------------------

  // Selección ponderada por peso (para el ganador real)
  T _pickWeighted<T>(List<T> items, int Function(T) weightOf, Random rnd) {
    if (items.isEmpty) {
      throw StateError('No hay items para elegir');
    }
    int total = 0;
    for (final it in items) {
      final w = weightOf(it);
      total += (w < 1 ? 1 : w);
    }
    int r = rnd.nextInt(total > 0 ? total : 1);
    for (final it in items) {
      final w = weightOf(it);
      final ww = (w < 1 ? 1 : w);
      if (r < ww) return it;
      r -= ww;
    }
    return items.last; // fallback
  }

  // Construye segmentos VISUALMENTE iguales (todas las porciones del mismo tamaño).
  // La probabilidad real se resuelve aparte con _pickWeighted().
  List<_Slice> _buildSlicesEqual(List<CatalogItemModel> pool) {
    if (pool.isEmpty) return const [];
    final n = pool.length;
    final step = (2 * pi) / n;

    final List<_Slice> out = [];
    double cursor = 0.0;
    for (final it in pool) {
      out.add(
        _Slice(
          id: it.id,
          name: it.nombre,
          icon: it.icono,
          weight: (it.wheelWeight as num).toInt(),
          start: cursor,
          end: cursor + step,
        ),
      );
      cursor += step;
    }
    return out;
  }

  int _spinsRemainingToSpecial(int totalSpins) {
    // “Especial” cuando (totalSpins + 1) % 100 == 0  => next spin es especial si totalSpins % 100 == 99
    final rem = 99 - (totalSpins % 100);
    return rem; // 0 => el próximo giro es el especial
  }

  // ------------------ Acciones ------------------

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
      // --- 0) Leer meta para saber si el SIGUIENTE giro es "raro garantizado" ---
      final db = FirebaseFirestore.instance;
      final metaRef = db
          .collection('users')
          .doc(widget.uid)
          .collection('wheel')
          .doc('meta');

      final metaSnap = await metaRef.get();
      final meta = metaSnap.data() ?? {};
      final totalSpins = (meta['totalSpins'] as num?)?.toInt() ?? 0;
      final isGuaranteedRare = ((totalSpins + 1) % 100 == 0);

      // --- 1) Consumir spin (diario o extra) ---
      await ref.read(consumeOneSpinProvider(widget.uid).future);
      ref.invalidate(availableSpinsFromMetaProvider(widget.uid));
      ref.invalidate(userWheelMetaProvider(widget.uid)); // opcional

      // --- 2) Pool lógico para PROBABILIDAD real ---
      final pool =
          (ref.read(wheelPrizePoolProvider).value ?? <CatalogItemModel>[]);
      List<CatalogItemModel> logicalPool;
      if (isGuaranteedRare) {
        final rare =
            pool.where((it) => (it.wheelWeight as num).toInt() < 50).toList();
        logicalPool = rare.isNotEmpty ? rare : pool; // fallback si no hay raros
      } else {
        logicalPool = pool;
      }
      if (logicalPool.isEmpty) {
        throw StateError('No hay premios disponibles.');
      }

      // --- 3) Elegir ganador ponderado ---
      final rnd = Random();
      final winner = _pickWeighted<CatalogItemModel>(
        logicalPool,
        (it) => (it.wheelWeight as num).toInt(),
        rnd,
      );

      // localizar el slice VISUAL del ganador
      final visualIndex = slices.indexWhere((s) => s.id == winner.id);
      final _Slice selected =
          visualIndex >= 0 ? slices[visualIndex] : slices.first;

      // --- 4) Animación: ir al centro del slice ganador bajo el puntero superior ---
      // Nota: 0 rad está a las 3 en punto; el puntero está ARRIBA (-pi/2).
      // Para que el centro del segmento (targetAngle) quede bajo el puntero:
      // rotación objetivo = vueltas + (puntero - targetAngle).
      final targetAngle = (selected.start + selected.end) / 2;
      final spins = 4 + Random().nextInt(3); // 4 a 6 vueltas
      final targetRotation =
          (spins * 2 * pi) + (_pointerAngle - targetAngle); // ✅ clave

      final tween = Tween<double>(begin: _currentAngle, end: targetRotation);
      _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
      _ctrl
        ..reset()
        ..addListener(() {
          setState(() {
            _currentAngle = tween.transform(_anim.value);
          });
        });

      await _ctrl.forward();

      // --- 5) Otorgar premio ---
      await ref.read(
        grantCatalogPrizeProvider((uid: widget.uid, itemId: winner.id)).future,
      );

      // --- 6) Incrementar contador totalSpins ---
      await db.runTransaction((tx) async {
        final snap = await tx.get(metaRef);
        final curr = (snap.data()?['totalSpins'] as num?)?.toInt() ?? 0;
        tx.set(metaRef, {'totalSpins': curr + 1}, SetOptions(merge: true));
      });
      ref.invalidate(userWheelMetaProvider(widget.uid)); // refrescar meta

      setState(() => _lastPrizeName = winner.nombre);
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
    final metaAsync = ref.watch(userWheelMetaProvider(widget.uid));

    final int spins = spinsAsync.valueOrNull ?? 0;
    final List<CatalogItemModel> pool =
        poolAsync.valueOrNull ?? <CatalogItemModel>[];

    // Slices visuales iguales
    final slices = _buildSlicesEqual(pool);

    // Meta (totales y contador hacia el especial)
    final int totalSpins = metaAsync.maybeWhen(
      data: (m) => (m['totalSpins'] as num?)?.toInt() ?? 0,
      orElse: () => 0,
    );
    final bool nextIsGuaranteedRare = ((totalSpins + 1) % 100 == 0);
    final int remaining = _spinsRemainingToSpecial(totalSpins);

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

                  // Badge "Raro garantizado" + progreso
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color:
                          nextIsGuaranteedRare
                              ? Colors.amber.shade300
                              : Theme.of(context).colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          nextIsGuaranteedRare
                              ? Icons.star
                              : Icons.star_border_rounded,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          nextIsGuaranteedRare
                              ? '¡Próximo giro ESPECIAL!'
                              : 'Faltan $remaining',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

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

                  // -------------------- ANUNCIOS RECOMPENSADOS (comentado) --------------------
                  // const SizedBox(width: 8),
                  // TextButton.icon(
                  //   onPressed: _loadingAd ? null : _showRewardedAdAndGrant,
                  //   icon: _loadingAd
                  //       ? const SizedBox(
                  //           height: 16,
                  //           width: 16,
                  //           child: CircularProgressIndicator(strokeWidth: 2),
                  //         )
                  //       : const Icon(Icons.ondemand_video),
                  //   label: const Text('+1 spin por anuncio'),
                  // ),
                  // ---------------------------------------------------------------------------
                ],
              ),

              // Línea con totales
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(top: 6.0, bottom: 2),
                  child: Text(
                    'Spins totales: $totalSpins · Próximo especial en $remaining',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ),
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
                        // Rueda (visual igualitaria)
                        Transform.rotate(
                          // Nota: ya corregimos el objetivo en _spin con _pointerAngle,
                          // aquí solo aplicamos la rotación acumulada.
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
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
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
            ],
          ),
        ),
      ],
    );
  }

  // -------------------- BLOQUE DE ANUNCIOS RECOMPENSADOS (comentado) --------------------
  // Para activarlo:
  // 1) Añade google_mobile_ads al pubspec.
  // 2) Inicializa MobileAds.instance.initialize() en main().
  // 3) Sustituye RewardedAd.testAdUnitId por tu ID real en release.
  //
  // Future<void> _showRewardedAdAndGrant() async {
  //   setState(() => _loadingAd = true);
  //   try {
  //     RewardedAd.load(
  //       adUnitId: RewardedAd.testAdUnitId,
  //       request: const AdRequest(),
  //       rewardedAdLoadCallback: RewardedAdLoadCallback(
  //         onAdLoaded: (ad) async {
  //           setState(() => _loadingAd = false);
  //           await ad.show(onUserEarnedReward: (ad, reward) async {
  //             await _addExtraSpin(); // +1 spin al terminar el anuncio
  //           });
  //           ad.dispose();
  //         },
  //         onAdFailedToLoad: (error) {
  //           setState(() => _loadingAd = false);
  //           ScaffoldMessenger.of(context).showSnackBar(
  //             SnackBar(content: Text('No se pudo cargar el anuncio: $error')),
  //           );
  //         },
  //       ),
  //     );
  //   } catch (e) {
  //     setState(() => _loadingAd = false);
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Error anuncio: $e')),
  //     );
  //   }
  // }
  // ----------------------------------------------------------------------
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
