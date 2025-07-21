// lib/core/config/providers/config_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:per_habit/core/config/models/mechanic_model.dart';
import 'package:per_habit/core/config/models/personality_model.dart';
import 'package:per_habit/core/config/models/pet_type_model.dart';
import 'package:per_habit/core/config/models/status_model.dart';
import 'package:per_habit/core/config/repositories/config_repository.dart';
import 'package:per_habit/core/config/repositories/config_repository_impl.dart';

final configRepositoryProvider = Provider<ConfigRepository>((ref) {
  return ConfigRepositoryImpl(FirebaseFirestore.instance);
});

final petTypesProvider = FutureProvider<List<PetTypeModel>>((ref) async {
  final repo = ref.read(configRepositoryProvider);
  return repo.getPetTypes();
});

final personalitiesProvider = FutureProvider<List<PersonalityModel>>((
  ref,
) async {
  final repo = ref.read(configRepositoryProvider);
  return repo.getPersonalities();
});

final mechanicsProvider = FutureProvider<List<MechanicModel>>((ref) async {
  final repo = ref.read(configRepositoryProvider);
  return repo.getMechanics();
});

final statusesProvider = FutureProvider<List<StatusModel>>((ref) async {
  final repo = ref.read(configRepositoryProvider);
  return repo.getStatuses();
});
