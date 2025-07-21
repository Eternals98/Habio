import 'package:cloud_firestore/cloud_firestore.dart';

class RoomModel {
  final String id;
  final String name;
  final String ownerId;
  final List<String> members;
  final bool shared;
  final DateTime createdAt;

  const RoomModel({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.members,
    required this.shared,
    required this.createdAt,
  });

  factory RoomModel.fromMap(Map<String, dynamic> map, String id) {
    return RoomModel(
      id: id,
      name: map['name'] ?? '',
      ownerId: map['ownerId'] ?? '',
      members: List<String>.from(map['members'] ?? []),
      shared: map['shared'] ?? false,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'ownerId': ownerId,
      'members': members,
      'shared': shared,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  RoomModel copyWith({String? name, List<String>? members, bool? shared}) {
    return RoomModel(
      id: id,
      name: name ?? this.name,
      ownerId: ownerId,
      members: members ?? this.members,
      shared: shared ?? this.shared,
      createdAt: createdAt,
    );
  }
}
