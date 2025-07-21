import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:per_habit/features/room/application/create_room_use_case.dart';
import 'package:per_habit/features/room/application/delete_room_use_case.dart';
import 'package:per_habit/features/room/application/get_room_by_id_use_case.dart';
import 'package:per_habit/features/room/application/get_user_rooms_use_case.dart';
import 'package:per_habit/features/room/application/invite_member_use_case.dart';
import 'package:per_habit/features/room/application/rename_room_use_case.dart';
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

  RoomController({
    required this.getUserRooms,
    required this.createRoom,
    required this.renameRoom,
    required this.deleteRoom,
    required this.inviteMember,
    required this.getRoomById,
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
}
