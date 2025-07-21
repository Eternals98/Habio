// lib/core/config/repositories/config_repository_impl.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:per_habit/core/config/models/mechanic_model.dart';
import 'package:per_habit/core/config/models/personality_model.dart';
import 'package:per_habit/core/config/models/pet_type_model.dart';
import 'package:per_habit/core/config/models/status_model.dart';
import 'package:per_habit/core/config/repositories/config_repository.dart';

class ConfigRepositoryImpl implements ConfigRepository {
  final FirebaseFirestore firestore;

  ConfigRepositoryImpl(this.firestore);

  @override
  Future<List<PetTypeModel>> getPetTypes() async {
    final snapshot = await firestore.collection('petTypes').get();
    return snapshot.docs.map((doc) {
      return PetTypeModel.fromMap(doc.id, doc.data());
    }).toList();
  }

  @override
  Future<List<PersonalityModel>> getPersonalities() async {
    final snapshot = await firestore.collection('personalities').get();
    return snapshot.docs.map((doc) {
      return PersonalityModel.fromMap(doc.id, doc.data());
    }).toList();
  }

  @override
  Future<List<MechanicModel>> getMechanics() async {
    final snapshot = await firestore.collection('mechanics').get();
    return snapshot.docs.map((doc) {
      return MechanicModel.fromMap(doc.id, doc.data());
    }).toList();
  }

  @override
  Future<List<StatusModel>> getStatuses() async {
    final snapshot = await firestore.collection('statuses').get();
    return snapshot.docs.map((doc) {
      return StatusModel.fromMap(doc.id, doc.data());
    }).toList();
  }
}
