import 'package:per_habit/core/config/models/mechanic_model.dart';
import 'package:per_habit/core/config/models/personality_model.dart';
import 'package:per_habit/core/config/models/pet_type_model.dart';
import 'package:per_habit/core/config/models/status_model.dart';

abstract class ConfigRepository {
  Future<List<PetTypeModel>> getPetTypes();
  Future<List<PersonalityModel>> getPersonalities();
  Future<List<MechanicModel>> getMechanics();
  Future<List<StatusModel>> getStatuses();
}
