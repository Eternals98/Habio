// lib/core/config/models/pet_type_model.dart

class PetTypeModel {
  final String id;
  final String name;
  final String description;
  final String image;
  final bool available;
  final int price;
  final int maxLevel;
  final List<int> rewardTable;
  final List<int> reducedRewardTable;
  final String defaultPersonalityId;
  final List<String> mechanicIds;

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
      name: map['name'],
      description: map['description'],
      image: map['image'],
      available: map['available'],
      price: map['price'],
      maxLevel: map['maxLevel'],
      rewardTable: List<int>.from(map['rewardTable']),
      reducedRewardTable: List<int>.from(map['reducedRewardTable']),
      defaultPersonalityId: map['defaultPersonalityId'],
      mechanicIds: List<String>.from(map['mechanicIds']),
    );
  }
}
