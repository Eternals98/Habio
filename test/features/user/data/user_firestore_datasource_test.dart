import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:per_habit/features/user/data/datasources/user_firebase_datasource.dart';
import 'package:per_habit/features/user/data/models/user_profile_model.dart';

void main() {
  group('UserFirestoreDatasource', () {
    late FakeFirebaseFirestore fakeFirestore;
    late UserFirestoreDatasource datasource;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      datasource = UserFirestoreDatasource(firestore: fakeFirestore);
    });

    test('createUser stores the user document', () async {
      final user = UserProfileModel(
        id: 'user-1',
        email: 'user@example.com',
        displayName: 'Test User',
        bio: 'bio',
        photoUrl: 'photo',
        habipoints: 10,
      );

      await datasource.createUser(user);

      final snapshot =
          await fakeFirestore.collection('users').doc('user-1').get();
      expect(snapshot.exists, isTrue);
      expect(snapshot.data(), containsPair('email', 'user@example.com'));
    });

    test(
      'getUser returns a UserProfileModel when the document exists',
      () async {
        await fakeFirestore.collection('users').doc('user-2').set({
          'email': 'existing@example.com',
          'displayName': 'Existing User',
          'bio': 'Existing bio',
          'photoUrl': 'photo',
          'onboardingCompleted': true,
          'habipoints': 5,
          'inventario': {'userId': 'user-2'},
        });

        final result = await datasource.getUser('user-2');

        expect(result, isNotNull);
        expect(result!.email, 'existing@example.com');
        expect(result.displayName, 'Existing User');
      },
    );

    test('updateUser updates the stored document', () async {
      await fakeFirestore.collection('users').doc('user-3').set({
        'email': 'old@example.com',
        'displayName': 'Old User',
        'bio': 'Old bio',
        'photoUrl': 'photo',
        'onboardingCompleted': false,
        'habipoints': 0,
        'inventario': {'userId': 'user-3'},
      });

      final updatedUser = UserProfileModel(
        id: 'user-3',
        email: 'new@example.com',
        displayName: 'Updated User',
        bio: 'Updated bio',
        photoUrl: 'new-photo',
        habipoints: 50,
      );

      await datasource.updateUser(updatedUser);

      final snapshot =
          await fakeFirestore.collection('users').doc('user-3').get();
      expect(snapshot.data(), containsPair('email', 'new@example.com'));
      expect(snapshot.data(), containsPair('displayName', 'Updated User'));
      expect(snapshot.data(), containsPair('habipoints', 50));
    });
  });
}
