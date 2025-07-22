import 'package:per_habit/features/inventary/domain/entities/inventory.dart';
import 'package:per_habit/features/inventary/domain/entities/items.dart';
import 'package:per_habit/features/user/domain/entities/user_profile.dart';
import 'package:per_habit/features/user/domain/repositories/user_repository.dart';

class BotarObjeto {
  final UserRepository repository;

  BotarObjeto(this.repository);

  Future<void> call(UserProfile userProfile, Item itemToRemove) async {
    final updatedInventario = Inventario(
      mascotas:
          userProfile.inventario.mascotas
              .where((mascota) => mascota.id != itemToRemove.id)
              .toList(),
      alimentos:
          userProfile.inventario.alimentos
              .where((alimento) => alimento.id != itemToRemove.id)
              .toList(),
      accesorios:
          userProfile.inventario.accesorios
              .where((accesorio) => accesorio.id != itemToRemove.id)
              .toList(),
      decoraciones:
          userProfile.inventario.decoraciones
              .where((decoracion) => decoracion.id != itemToRemove.id)
              .toList(),
      fondos:
          userProfile.inventario.fondos
              .where((fondo) => fondo.id != itemToRemove.id)
              .toList(),
    );

    final updatedProfile = userProfile.copyWith(inventario: updatedInventario);

    await repository.updateUserProfile(updatedProfile);
  }
}
