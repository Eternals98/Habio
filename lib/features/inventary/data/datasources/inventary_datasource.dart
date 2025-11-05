import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:per_habit/features/inventary/data/models/inventory_model.dart';
import 'package:per_habit/features/inventary/data/models/items_model.dart';
import 'package:per_habit/features/inventary/data/models/mascota_model.dart';
import 'package:per_habit/features/inventary/data/models/alimento_model.dart';
import 'package:per_habit/features/inventary/data/models/accesorio_model.dart';
import 'package:per_habit/features/inventary/data/models/decoracion_model.dart';
import 'package:per_habit/features/inventary/data/models/fondo_model.dart';

abstract class InventarioDatasource {
  Future<void> saveInventory(InventarioModel inventario);
  Future<void> replaceInventory(InventarioModel inventario);
  Future<void> createItem(
    ItemModel item,
    String userId,
  ); // Cambiado a ItemModel
  Future<void> updateItem(
    ItemModel item,
    String userId,
  ); // Cambiado a ItemModel
  Future<void> deleteItem(String itemId, String userId);
  Stream<InventarioModel> getInventoryByUser(String userId);
}

class InventarioDatasourceImpl implements InventarioDatasource {
  final FirebaseFirestore firestore;

  InventarioDatasourceImpl(this.firestore);

  @override
  Future<void> saveInventory(InventarioModel inventario) async {
    final userDoc = firestore.collection('users').doc(inventario.userId);
    await userDoc.set({
      'inventario': inventario.toMap(),
    }, SetOptions(merge: true));
  }

  @override
  Future<void> replaceInventory(InventarioModel inventario) async {
    final userDoc = firestore.collection('users').doc(inventario.userId);
    await userDoc.update({'inventario': inventario.toMap()});
  }

  @override
  Future<void> createItem(ItemModel item, String userId) async {
    final userDoc = firestore.collection('users').doc(userId);
    final docSnap = await userDoc.get();
    final data = docSnap.data() ?? {};
    final currentInventario = InventarioModel.fromMap(data['inventario'] ?? {});

    final updatedInventario = InventarioModel(
      userId: userId,
      mascotas:
          item is MascotaModel
              ? [...currentInventario.mascotas, item]
              : currentInventario.mascotas,
      alimentos:
          item is AlimentoModel
              ? [...currentInventario.alimentos, item]
              : currentInventario.alimentos,
      accesorios:
          item is AccesorioModel
              ? [...currentInventario.accesorios, item]
              : currentInventario.accesorios,
      decoraciones:
          item is DecoracionModel
              ? [...currentInventario.decoraciones, item]
              : currentInventario.decoraciones,
      fondos:
          item is FondoModel
              ? [...currentInventario.fondos, item]
              : currentInventario.fondos,
    );

    await userDoc.set({
      'inventario': updatedInventario.toMap(),
    }, SetOptions(merge: true));
  }

  @override
  Future<void> updateItem(ItemModel item, String userId) async {
    final userDoc = firestore.collection('users').doc(userId);
    final docSnap = await userDoc.get();
    final data = docSnap.data() ?? {};
    final currentInventario = InventarioModel.fromMap(data['inventario'] ?? {});

    final updatedInventario = InventarioModel(
      userId: userId,
      mascotas:
          item is MascotaModel
              ? currentInventario.mascotas
                  .map((m) => m.id == item.id ? item : m)
                  .toList()
              : currentInventario.mascotas,
      alimentos:
          item is AlimentoModel
              ? currentInventario.alimentos
                  .map((a) => a.id == item.id ? item : a)
                  .toList()
              : currentInventario.alimentos,
      accesorios:
          item is AccesorioModel
              ? currentInventario.accesorios
                  .map((a) => a.id == item.id ? item : a)
                  .toList()
              : currentInventario.accesorios,
      decoraciones:
          item is DecoracionModel
              ? currentInventario.decoraciones
                  .map((d) => d.id == item.id ? item : d)
                  .toList()
              : currentInventario.decoraciones,
      fondos:
          item is FondoModel
              ? currentInventario.fondos
                  .map((f) => f.id == item.id ? item : f)
                  .toList()
              : currentInventario.fondos,
    );

    await userDoc.update({'inventario': updatedInventario.toMap()});
  }

  @override
  Future<void> deleteItem(String itemId, String userId) async {
    final userDoc = firestore.collection('users').doc(userId);
    final docSnap = await userDoc.get();
    final data = docSnap.data() ?? {};
    final currentInventario = InventarioModel.fromMap(data['inventario'] ?? {});

    final updatedInventario = InventarioModel(
      userId: userId,
      mascotas:
          currentInventario.mascotas.where((m) => m.id != itemId).toList(),
      alimentos:
          currentInventario.alimentos.where((a) => a.id != itemId).toList(),
      accesorios:
          currentInventario.accesorios.where((a) => a.id != itemId).toList(),
      decoraciones:
          currentInventario.decoraciones.where((d) => d.id != itemId).toList(),
      fondos: currentInventario.fondos.where((f) => f.id != itemId).toList(),
    );

    await userDoc.update({'inventario': updatedInventario.toMap()});
  }

  @override
  Stream<InventarioModel> getInventoryByUser(String userId) {
    return firestore.collection('users').doc(userId).snapshots().map((snap) {
      final data = snap.data() ?? {};
      final inventarioMap = data['inventario'] ?? {};
      final model = InventarioModel.fromMap(inventarioMap);
      return model.copyWith(userId: userId);
    });
  }
}
