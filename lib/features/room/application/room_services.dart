import 'package:per_habit/features/room/domain/entities/room.dart';
import 'package:per_habit/features/room/domain/repositories/room_repository.dart';

class UpdateRoomOrderUseCase {
  final RoomRepository repository;

  UpdateRoomOrderUseCase(this.repository);

  Future<void> call({required String roomId, required int order}) {
    return repository.updateRoomOrder(roomId, order);
  }
}

class RenameRoomUseCase {
  final RoomRepository repository;

  RenameRoomUseCase(this.repository);

  Future<void> call({required String roomId, required String newName}) {
    return repository.renameRoom(roomId, newName);
  }
}

class InviteMemberUseCase {
  final RoomRepository repository;

  InviteMemberUseCase(this.repository);

  Future<Room> call({required String roomId, required String email}) {
    return repository.inviteMember(roomId, email);
  }
}

class GetUserRoomsUseCase {
  final RoomRepository repository;

  GetUserRoomsUseCase(this.repository);

  /// Obtiene las salas del usuario por su ID.
  Future<List<Room>> call(String userId) {
    return repository.getUserRooms(userId);
  }
}

class GetRoomByIdUseCase {
  final RoomRepository repository;

  GetRoomByIdUseCase(this.repository);

  Future<Room> call(String id) {
    return repository.getRoomById(id);
  }
}

class DeleteRoomUseCase {
  final RoomRepository repository;

  DeleteRoomUseCase(this.repository);

  Future<void> call(String roomId) {
    return repository.deleteRoom(roomId);
  }
}

class CreateRoomUseCase {
  final RoomRepository repository;

  CreateRoomUseCase(this.repository);

  Future<Room> call({required String name, required String ownerId}) {
    return repository.createRoom(name, ownerId);
  }
}
