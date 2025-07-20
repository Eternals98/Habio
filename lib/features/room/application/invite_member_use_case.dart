import 'package:per_habit/features/room/domain/entities/room.dart';
import 'package:per_habit/features/room/domain/repositories/room_repository.dart';

class InviteMemberUseCase {
  final RoomRepository repository;

  InviteMemberUseCase(this.repository);

  Future<Room> call({required String roomId, required String email}) {
    return repository.inviteMember(roomId, email);
  }
}
