import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:per_habit/features/room/application/room_services.dart';
import 'package:per_habit/features/room/domain/entities/room.dart';

class RoomState {
  final bool loading;
  final String? error;

  const RoomState({this.loading = false, this.error});

  RoomState copyWith({bool? loading, String? error}) {
    return RoomState(loading: loading ?? this.loading, error: error);
  }
}

class RoomController extends StateNotifier<RoomState> {
  final GetUserRoomsUseCase getUserRooms;
  final CreateRoomUseCase createRoom;
  final RenameRoomUseCase renameRoom;
  final DeleteRoomUseCase deleteRoom;
  final InviteMemberUseCase inviteMember;
  final GetRoomByIdUseCase getRoomById;
  final UpdateRoomOrderUseCase updateRoomOrder;

  RoomController({
    required this.getUserRooms,
    required this.createRoom,
    required this.renameRoom,
    required this.deleteRoom,
    required this.inviteMember,
    required this.getRoomById,
    required this.updateRoomOrder,
  }) : super(const RoomState());

  Future<void> create(String name, String ownerId) async {
    state = state.copyWith(loading: true, error: null);
    try {
      await createRoom(name: name, ownerId: ownerId);
      state = state.copyWith(loading: false);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> rename(String roomId, String newName) async {
    try {
      await renameRoom(roomId: roomId, newName: newName);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> remove(String roomId) async {
    try {
      await deleteRoom(roomId);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> invite(String roomId, String email) async {
    try {
      await inviteMember(roomId: roomId, email: email);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<Room?> getRooms(String roomId) async {
    try {
      return await getRoomById(roomId);
    } catch (_) {
      return null;
    }
  }

  Future<void> reorderRooms(List<Room> rooms) async {
    try {
      for (int i = 0; i < rooms.length; i++) {
        final room = rooms[i];
        if (room.order != i) {
          await updateRoomOrder(roomId: room.id, order: i);
        }
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}
