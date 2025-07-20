import 'package:per_habit/features/room/domain/entities/room.dart';
import 'package:per_habit/features/room/domain/repositories/room_repository.dart';

class CreateRoomUseCase {
  final RoomRepository repository;

  CreateRoomUseCase(this.repository);

  Future<Room> call({required String name, required String ownerId}) {
    return repository.createRoom(name, ownerId);
  }
}
