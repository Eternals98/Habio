import 'package:per_habit/features/room/domain/repositories/room_repository.dart';

class RenameRoomUseCase {
  final RoomRepository repository;

  RenameRoomUseCase(this.repository);

  Future<void> call({required String roomId, required String newName}) {
    return repository.renameRoom(roomId, newName);
  }
}
