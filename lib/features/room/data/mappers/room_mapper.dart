import 'package:per_habit/features/room/data/models/room_model.dart';
import 'package:per_habit/features/room/domain/entities/room.dart';

class RoomMapper {
  static Room fromModel(RoomModel model) {
    return Room(
      id: model.id,
      name: model.name,
      ownerId: model.ownerId,
      members: model.members,
      shared: model.shared,
      createdAt: model.createdAt,
    );
  }

  static RoomModel toModel(Room entity) {
    return RoomModel(
      id: entity.id,
      name: entity.name,
      ownerId: entity.ownerId,
      members: entity.members,
      shared: entity.shared,
      createdAt: entity.createdAt,
    );
  }
}
