import 'package:per_habit/features/room/domain/entities/room.dart';
import 'package:per_habit/features/room/domain/repositories/room_repository.dart';

class GetRoomByIdUseCase {
  final RoomRepository repository;

  GetRoomByIdUseCase(this.repository);

  Future<Room> call(String id) {
    return repository.getRoomById(id);
  }
}
