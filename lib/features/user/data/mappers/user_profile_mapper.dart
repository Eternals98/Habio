import 'package:per_habit/features/inventary/data/mappers/inventary_mapper.dart';
import 'package:per_habit/features/inventary/data/models/inventory_model.dart';

import '../../domain/entities/user_profile.dart';
import '../models/user_profile_model.dart';

class UserProfileMapper {
  static UserProfile fromModel(UserProfileModel model) {
    final inventarioModel =
        model.inventario is InventarioModel
            ? model.inventario as InventarioModel
            : InventarioMapper.toModel(model.inventario);

    return UserProfile(
      id: model.id,
      email: model.email,
      displayName: model.displayName,
      bio: model.bio,
      photoUrl: model.photoUrl,
      onboardingCompleted: model.onboardingCompleted,
      inventario: InventarioMapper.toEntity(inventarioModel),
      habipoints: model.habipoints,
    );
  }

  static UserProfileModel toModel(UserProfile entity) {
    final inventarioModel =
        entity.inventario is InventarioModel
            ? entity.inventario as InventarioModel
            : InventarioMapper.toModel(entity.inventario);

    return UserProfileModel(
      id: entity.id,
      email: entity.email,
      displayName: entity.displayName,
      bio: entity.bio,
      photoUrl: entity.photoUrl,
      onboardingCompleted: entity.onboardingCompleted,
      inventario: inventarioModel,
      habipoints: entity.habipoints,
    );
  }
}
