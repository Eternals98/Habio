class Room {
  final String id;
  final String name;
  final String ownerId;
  final List<String> members;
  final DateTime createdAt;
  final bool shared;
  final int order;

  const Room({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.members,
    required this.createdAt,
    required this.shared,
    required this.order,
  });

  Room copyWith({
    String? name,
    List<String>? members,
    bool? shared,
    int? order,
  }) {
    return Room(
      id: id,
      name: name ?? this.name,
      ownerId: ownerId,
      members: members ?? this.members,
      createdAt: createdAt,
      shared: shared ?? this.shared,
      order: order ?? this.order,
    );
  }

  bool get isPrivate => !shared;
  bool get isShared => shared;
  bool isOwner(String uid) => uid == ownerId;
  bool isMember(String uid) => members.contains(uid);
}
