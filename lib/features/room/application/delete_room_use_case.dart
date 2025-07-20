import 'package:per_habit/features/room/domain/repositories/room_repository.dart';

class DeleteRoomUseCase {
  final RoomRepository repository;

  DeleteRoomUseCase(this.repository);

  Future<void> call(String roomId) {
    return repository.deleteRoom(roomId);
  }
}
