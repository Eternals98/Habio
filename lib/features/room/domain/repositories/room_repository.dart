import 'package:per_habit/features/room/domain/entities/room.dart';

abstract class RoomRepository {
  Future<List<Room>> getUserRooms(String userId);
  Future<Room> createRoom(String name, String ownerId);
  Future<void> renameRoom(String roomId, String newName);
  Future<void> deleteRoom(String roomId);
  Future<Room> inviteMember(String roomId, String email);
  Future<Room> getRoomById(String roomId);
  Stream<List<Room>> watchUserRooms(String userId);
  Future<void> updateRoomOrder(String roomId, int newOrder);
}
