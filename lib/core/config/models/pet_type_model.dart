// lib/core/config/models/pet_type_model.dart
class PetTypeModel {
  final String id;
  final String name;
  final String description;
  final String image; // ruta del sprite en assets
  final bool available;
  final int price;
  final int maxLevel;
  final List<int> rewardTable;
  final List<int> reducedRewardTable;
  final String
  defaultPersonalityId; // debe existir en tu colección de personalidades
  final List<String> mechanicIds; // ids de mecánicas válidas

  PetTypeModel({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.available,
    required this.price,
    required this.maxLevel,
    required this.rewardTable,
    required this.reducedRewardTable,
    required this.defaultPersonalityId,
    required this.mechanicIds,
  });

  factory PetTypeModel.fromMap(String id, Map<String, dynamic> map) {
    return PetTypeModel(
      id: id,
      name: map['name'] as String,
      description: map['description']?.toString() ?? '',
      image: map['image'] as String,
      available: map['available'] as bool? ?? true,
      price: (map['price'] as num?)?.toInt() ?? 0,
      maxLevel: (map['maxLevel'] as num?)?.toInt() ?? 50,
      rewardTable: List<int>.from(map['rewardTable'] ?? const <int>[]),
      reducedRewardTable: List<int>.from(
        map['reducedRewardTable'] ?? const <int>[],
      ),
      defaultPersonalityId: map['defaultPersonalityId'] as String? ?? 'happy',
      mechanicIds: List<String>.from(map['mechanicIds'] ?? const <String>[]),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'image': image,
      'available': available,
      'price': price,
      'maxLevel': maxLevel,
      'rewardTable': rewardTable,
      'reducedRewardTable': reducedRewardTable,
      'defaultPersonalityId': defaultPersonalityId,
      'mechanicIds': mechanicIds,
    };
  }

  PetTypeModel copyWith({
    String? id,
    String? name,
    String? description,
    String? image,
    bool? available,
    int? price,
    int? maxLevel,
    List<int>? rewardTable,
    List<int>? reducedRewardTable,
    String? defaultPersonalityId,
    List<String>? mechanicIds,
  }) {
    return PetTypeModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      image: image ?? this.image,
      available: available ?? this.available,
      price: price ?? this.price,
      maxLevel: maxLevel ?? this.maxLevel,
      rewardTable: rewardTable ?? this.rewardTable,
      reducedRewardTable: reducedRewardTable ?? this.reducedRewardTable,
      defaultPersonalityId: defaultPersonalityId ?? this.defaultPersonalityId,
      mechanicIds: mechanicIds ?? this.mechanicIds,
    );
  }
}
