import 'package:per_habit/features/room/domain/repositories/room_repository.dart';

class UpdateRoomOrderUseCase {
  final RoomRepository repository;

  UpdateRoomOrderUseCase(this.repository);

  Future<void> call({required String roomId, required int order}) {
    return repository.updateRoomOrder(roomId, order);
  }
}
