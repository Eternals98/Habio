import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:per_habit/features/room/data/models/room_model.dart';
import 'package:rxdart/rxdart.dart';

class RoomFirestoreDatasource {
  RoomFirestoreDatasource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _roomsRef =>
      _firestore.collection('rooms');
  CollectionReference<Map<String, dynamic>> get _usersRef =>
      _firestore.collection('users');

  Future<List<RoomModel>> getUserRooms(String userId) async {
    final created = await _roomsRef.where('ownerId', isEqualTo: userId).get();
    final shared =
        await _roomsRef.where('members', arrayContains: userId).get();

    final allDocs = {...created.docs, ...shared.docs};

    return allDocs.map((doc) {
      return RoomModel.fromMap(doc.data(), doc.id);
    }).toList();
  }

  Future<RoomModel> createRoom(RoomModel model) async {
    await _roomsRef.doc(model.id).set(model.toMap());
    return model;
  }

  Future<void> renameRoom(String roomId, String newName) async {
    await _roomsRef.doc(roomId).update({'name': newName});
  }

  Future<void> deleteRoom(String roomId) async {
    await _roomsRef.doc(roomId).delete();
  }

  Future<String> getUserIdByEmail(String email) async {
    final result =
        await _usersRef.where('email', isEqualTo: email).limit(1).get();
    if (result.docs.isEmpty) throw Exception('El usuario no existe');
    return result.docs.first.id;
  }

  Future<void> inviteMember(String roomId, String newMemberId) async {
    await _roomsRef.doc(roomId).update({
      'members': FieldValue.arrayUnion([newMemberId]),
      'shared': true,
    });
  }

  Future<RoomModel> getRoomById(String roomId) async {
    final doc = await _roomsRef.doc(roomId).get();
    if (!doc.exists) throw Exception('Room no encontrada');
    return RoomModel.fromMap(doc.data()!, doc.id);
  }

  /// 🔄 Combina los streams de rooms creados y compartidos
  /// utilizando Rx.combineLatest2 para emitir actualizaciones en tiempo real
  Stream<List<RoomModel>> watchUserRooms(String userId) {
    final createdStream =
        _roomsRef.where('ownerId', isEqualTo: userId).snapshots();
    final sharedStream =
        _roomsRef.where('members', arrayContains: userId).snapshots();

    return Rx.combineLatest2<
      QuerySnapshot<Map<String, dynamic>>,
      QuerySnapshot<Map<String, dynamic>>,
      List<RoomModel>
    >(createdStream, sharedStream, (createdSnap, sharedSnap) {
      final allDocs = {...createdSnap.docs, ...sharedSnap.docs};

      return allDocs
          .map((doc) => RoomModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Future<void> updateRoomOrder(String roomId, int newOrder) async {
    await _roomsRef.doc(roomId).update({'order': newOrder});
  }
}
