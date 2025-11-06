import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:per_habit/features/room/data/datasources/room_firestore_datasource.dart';
import 'package:per_habit/features/room/data/models/room_model.dart';

void main() {
  group('RoomFirestoreDatasource', () {
    late FakeFirebaseFirestore fakeFirestore;
    late RoomFirestoreDatasource datasource;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      datasource = RoomFirestoreDatasource(firestore: fakeFirestore);
    });

    test('createRoom persists the room document', () async {
      final room = RoomModel(
        id: 'room-1',
        name: 'Room 1',
        ownerId: 'owner',
        members: const [],
        shared: false,
        createdAt: DateTime.utc(2024, 1, 1),
        order: 1,
      );

      await datasource.createRoom(room);

      final snapshot =
          await fakeFirestore.collection('rooms').doc('room-1').get();
      expect(snapshot.exists, isTrue);
      expect(snapshot.data(), containsPair('name', 'Room 1'));
      expect(snapshot.data(), containsPair('ownerId', 'owner'));
    });

    test(
      'getUserRooms combines owned and shared rooms without duplicates',
      () async {
        final ownerRoom = RoomModel(
          id: 'room-owner',
          name: 'Owner Room',
          ownerId: 'user-id',
          members: const [],
          shared: false,
          createdAt: DateTime.utc(2024, 1, 2),
          order: 0,
        );
        final sharedRoom = RoomModel(
          id: 'room-shared',
          name: 'Shared Room',
          ownerId: 'other',
          members: const ['user-id'],
          shared: true,
          createdAt: DateTime.utc(2024, 1, 3),
          order: 1,
        );

        await fakeFirestore
            .collection('rooms')
            .doc(ownerRoom.id)
            .set(ownerRoom.toMap());
        await fakeFirestore
            .collection('rooms')
            .doc(sharedRoom.id)
            .set(sharedRoom.toMap());

        final rooms = await datasource.getUserRooms('user-id');

        expect(rooms, hasLength(2));
        expect(
          rooms.map((room) => room.id),
          containsAll(['room-owner', 'room-shared']),
        );
      },
    );

    test('inviteMember adds the member and marks the room as shared', () async {
      final room = RoomModel(
        id: 'room-2',
        name: 'Room 2',
        ownerId: 'owner',
        members: const [],
        shared: false,
        createdAt: DateTime.utc(2024, 1, 4),
        order: 0,
      );

      await fakeFirestore.collection('rooms').doc(room.id).set(room.toMap());

      await datasource.inviteMember('room-2', 'new-member');

      final snapshot =
          await fakeFirestore.collection('rooms').doc('room-2').get();
      final data = snapshot.data()!;
      expect(data['members'], contains('new-member'));
      expect(data['shared'], isTrue);
    });

    test('getUserIdByEmail returns the user id when email exists', () async {
      await fakeFirestore.collection('users').doc('user-123').set({
        'email': 'lookup@example.com',
      });

      final userId = await datasource.getUserIdByEmail('lookup@example.com');

      expect(userId, 'user-123');
    });

    test('getRoomById retrieves the saved room', () async {
      final room = RoomModel(
        id: 'room-3',
        name: 'Target Room',
        ownerId: 'owner',
        members: const [],
        shared: false,
        createdAt: DateTime.utc(2024, 1, 5),
        order: 2,
      );

      await fakeFirestore.collection('rooms').doc(room.id).set(room.toMap());

      final fetched = await datasource.getRoomById('room-3');

      expect(fetched.id, 'room-3');
      expect(fetched.name, 'Target Room');
    });
  });
}
