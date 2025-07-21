class Room {
  final String id;
  final String name;
  final String ownerId;
  final List<String> members;
  final DateTime createdAt;
  final bool shared;

  const Room({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.members,
    required this.createdAt,
    required this.shared,
  });

  Room copyWith({String? name, List<String>? members, bool? shared}) {
    return Room(
      id: id,
      name: name ?? this.name,
      ownerId: ownerId,
      members: members ?? this.members,
      createdAt: createdAt,
      shared: shared ?? this.shared,
    );
  }

  bool get isPrivate => !shared;
  bool get isShared => shared;
  bool isOwner(String uid) => uid == ownerId;
  bool isMember(String uid) => members.contains(uid);
}
