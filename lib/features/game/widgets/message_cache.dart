import 'package:cloud_firestore/cloud_firestore.dart';

class PersonalityMessagesCache {
  PersonalityMessagesCache._();
  static final Map<String, Map<String, List<String>>> _cache = {};

  static Map<String, List<String>> _parseMsgs(Map<String, dynamic>? data) {
    final msgs = (data?['messages'] as Map?) ?? {};
    List<String> _ls(dynamic v) =>
        (v is List) ? v.map((e) => e.toString()).toList() : const <String>[];
    return {
      'onEnter': _ls(msgs['onEnter']),
      'onLoad': _ls(msgs['onLoad']),
      'onComplete': _ls(msgs['onComplete']),
      'onMissed': _ls(msgs['onMissed']),
    };
  }

  /// Obtiene sin I/O (null si aún no está).
  static Map<String, List<String>>? getSync(String id) => _cache[id];

  /// Precarga en lotes de hasta 10 ids (límite de whereIn).
  static Future<void> preload(Set<String> ids) async {
    if (ids.isEmpty) return;
    final db = FirebaseFirestore.instance.collection('personalities');

    final missing = ids.where((id) => !_cache.containsKey(id)).toList();
    if (missing.isEmpty) return;

    const batchSize = 10;
    for (var i = 0; i < missing.length; i += batchSize) {
      final slice = missing.sublist(
        i,
        (i + batchSize > missing.length) ? missing.length : i + batchSize,
      );
      final qs = await db.where(FieldPath.documentId, whereIn: slice).get();
      for (final d in qs.docs) {
        _cache[d.id] = _parseMsgs(d.data());
      }
      // Si algún id no vino (doc inexistente), guárdalo vacío para evitar segundo fetch
      for (final id in slice) {
        _cache[id] =
            _cache[id] ??
            {
              'onEnter': const [],
              'onLoad': const [],
              'onComplete': const [],
              'onMissed': const [],
            };
      }
    }
  }

  /// Por si quieres calentar un id “on-demand” en background (no bloquea).
  static Future<void> warmAsync(String id) async {
    if (_cache.containsKey(id)) return;
    try {
      final snap =
          await FirebaseFirestore.instance
              .collection('personalities')
              .doc(id)
              .get();
      _cache[id] = _parseMsgs(snap.data());
    } catch (_) {
      _cache[id] = {
        'onEnter': const [],
        'onLoad': const [],
        'onComplete': const [],
        'onMissed': const [],
      };
    }
  }
}
