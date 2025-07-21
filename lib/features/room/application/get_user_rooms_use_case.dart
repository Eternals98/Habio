import 'package:per_habit/features/room/domain/entities/room.dart';
import 'package:per_habit/features/room/domain/repositories/room_repository.dart';

class GetUserRoomsUseCase {
  final RoomRepository repository;

  GetUserRoomsUseCase(this.repository);

  /// Obtiene las salas del usuario por su ID.
  Future<List<Room>> call(String userId) {
    return repository.getUserRooms(userId);
  }
}
