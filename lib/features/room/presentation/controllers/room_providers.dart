import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:per_habit/core/firebase/firebase_providers.dart';
import 'package:per_habit/features/room/application/room_services.dart';
import 'package:per_habit/features/room/data/datasources/room_firestore_datasource.dart';
import 'package:per_habit/features/room/data/room_repository_impl.dart';
import 'package:per_habit/features/room/domain/entities/room.dart';
import 'package:per_habit/features/room/domain/repositories/room_repository.dart';
import 'room_controller.dart';

final roomDatasourceProvider = Provider<RoomFirestoreDatasource>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  return RoomFirestoreDatasource(firestore: firestore);
});

final roomRepositoryProvider = Provider<RoomRepository>((ref) {
  final ds = ref.read(roomDatasourceProvider);
  final firestore = ref.watch(firebaseFirestoreProvider);
  return RoomRepositoryImpl(ds, firestore: firestore);
});

final getUserRoomsUseCaseProvider = Provider<GetUserRoomsUseCase>((ref) {
  return GetUserRoomsUseCase(ref.read(roomRepositoryProvider));
});

final createRoomUseCaseProvider = Provider<CreateRoomUseCase>((ref) {
  return CreateRoomUseCase(ref.read(roomRepositoryProvider));
});

final renameRoomUseCaseProvider = Provider<RenameRoomUseCase>((ref) {
  return RenameRoomUseCase(ref.read(roomRepositoryProvider));
});

final deleteRoomUseCaseProvider = Provider<DeleteRoomUseCase>((ref) {
  return DeleteRoomUseCase(ref.read(roomRepositoryProvider));
});

final inviteMemberUseCaseProvider = Provider<InviteMemberUseCase>((ref) {
  return InviteMemberUseCase(ref.read(roomRepositoryProvider));
});

final getRoomByIdUseCaseProvider = Provider<GetRoomByIdUseCase>((ref) {
  return GetRoomByIdUseCase(ref.read(roomRepositoryProvider));
});

final updateRoomOrderUseCaseProvider = Provider<UpdateRoomOrderUseCase>((ref) {
  return UpdateRoomOrderUseCase(ref.read(roomRepositoryProvider));
});

final roomControllerProvider = StateNotifierProvider<RoomController, RoomState>(
  (ref) {
    return RoomController(
      getUserRooms: ref.read(getUserRoomsUseCaseProvider),
      createRoom: ref.read(createRoomUseCaseProvider),
      renameRoom: ref.read(renameRoomUseCaseProvider),
      deleteRoom: ref.read(deleteRoomUseCaseProvider),
      inviteMember: ref.read(inviteMemberUseCaseProvider),
      getRoomById: ref.read(getRoomByIdUseCaseProvider),
      updateRoomOrder: ref.read(updateRoomOrderUseCaseProvider),
    );
  },
);

final roomStreamProvider = StreamProvider.family<List<Room>, String>((
  ref,
  userId,
) {
  final repo = ref.read(roomRepositoryProvider);
  return repo.watchUserRooms(userId);
});
