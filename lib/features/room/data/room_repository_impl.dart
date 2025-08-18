import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:per_habit/features/room/data/mappers/room_mapper.dart';
import 'package:per_habit/features/room/data/models/room_model.dart';
import 'package:per_habit/features/room/domain/entities/room.dart';
import 'package:per_habit/features/room/domain/repositories/room_repository.dart';

import 'datasources/room_firestore_datasource.dart';

class RoomRepositoryImpl implements RoomRepository {
  final RoomFirestoreDatasource datasource;

  RoomRepositoryImpl(this.datasource);

  @override
  Future<List<Room>> getUserRooms(String userId) async {
    final models = await datasource.getUserRooms(userId);
    return models.map(RoomMapper.fromModel).toList();
  }

  @override
  Future<void> updateRoomOrder(String roomId, int newOrder) {
    return datasource.updateRoomOrder(roomId, newOrder);
  }

  @override
  Future<Room> createRoom(String name, String ownerId) async {
    final newDocId = FirebaseFirestore.instance.collection('rooms').doc().id;

    // 🔢 Obtener rooms existentes para calcular el siguiente "order"
    final userRooms = await datasource.getUserRooms(ownerId);
    final maxOrder = userRooms
        .map((r) => r.order)
        .fold<int>(0, (prev, o) => o > prev ? o : prev);

    final model = RoomModel(
      id: newDocId,
      name: name,
      ownerId: ownerId,
      members: [],
      shared: false,
      createdAt: DateTime.now(),
      order: maxOrder + 1,
    );

    final saved = await datasource.createRoom(model);
    return RoomMapper.fromModel(saved);
  }

  @override
  Future<void> renameRoom(String roomId, String newName) {
    return datasource.renameRoom(roomId, newName);
  }

  @override
  Future<void> deleteRoom(String roomId) {
    return datasource.deleteRoom(roomId);
  }

  @override
  Future<Room> inviteMember(String roomId, String email) async {
    final newMemberId = await datasource.getUserIdByEmail(email);
    final currentRoom = await datasource.getRoomById(roomId);

    if (currentRoom.members.contains(newMemberId)) {
      throw Exception('El usuario ya es miembro');
    }

    await datasource.inviteMember(roomId, newMemberId);

    final updatedRoom = currentRoom.copyWith(
      members: [...currentRoom.members, newMemberId],
      shared: true,
    );

    return RoomMapper.fromModel(updatedRoom);
  }

  @override
  Future<Room> getRoomById(String roomId) async {
    final model = await datasource.getRoomById(roomId);
    return RoomMapper.fromModel(model);
  }

  /// 🔄 Nuevo: stream en tiempo real de rooms del usuario
  @override
  Stream<List<Room>> watchUserRooms(String userId) {
    return datasource
        .watchUserRooms(userId)
        .map((models) => models.map(RoomMapper.fromModel).toList());
  }
}
