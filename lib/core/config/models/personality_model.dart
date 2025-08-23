// lib/core/config/models/personality_model.dart
class PersonalityModel {
  final String id;
  final String name;
  final double moodBoostRate;
  final double rewardMultiplier;

  // ✅ Nuevo: mensajes por evento
  // Estructura esperada en Firestore:
  // messages: { enter: [..], load: [..], complete: [..] }
  final List<String> onEnterMessages;
  final List<String> onLoadMessages;
  final List<String> onCompleteMessages;

  PersonalityModel({
    required this.id,
    required this.name,
    required this.moodBoostRate,
    required this.rewardMultiplier,
    this.onEnterMessages = const [],
    this.onLoadMessages = const [],
    this.onCompleteMessages = const [],
  });

  factory PersonalityModel.fromMap(String id, Map<String, dynamic> map) {
    final msgs = (map['messages'] as Map<String, dynamic>?) ?? const {};
    List<String> listOf(dynamic v) {
      if (v is List) {
        return v
            .map((e) => e?.toString() ?? '')
            .where((s) => s.isNotEmpty)
            .toList();
      }
      return const [];
    }

    return PersonalityModel(
      id: id.toString(),
      name: (map['name'] ?? '').toString(),
      moodBoostRate: (map['moodBoostRate'] as num?)?.toDouble() ?? 0.0,
      rewardMultiplier: (map['rewardMultiplier'] as num?)?.toDouble() ?? 1.0,
      onEnterMessages: listOf(msgs['enter']),
      onLoadMessages: listOf(msgs['load']),
      onCompleteMessages: listOf(msgs['complete']),
    );
  }
}
