// lib/core/config/models/personality_model.dart

class PersonalityModel {
  final String id;
  final String name;
  final double moodBoostRate;
  final double rewardMultiplier;

  PersonalityModel({
    required this.id,
    required this.name,
    required this.moodBoostRate,
    required this.rewardMultiplier,
  });

  factory PersonalityModel.fromMap(String id, Map<String, dynamic> map) {
    return PersonalityModel(
      id: id.toString(),
      name: map['name'].toString(),
      moodBoostRate: (map['moodBoostRate'] as num).toDouble(),
      rewardMultiplier: (map['rewardMultiplier'] as num).toDouble(),
    );
  }
}
