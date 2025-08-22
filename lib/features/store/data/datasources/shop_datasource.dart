// lib/features/store/data/datasources/shop_datasource.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:per_habit/features/inventary/data/models/items_model.dart';
import 'package:per_habit/features/store/data/models/shop_item_model.dart';
import 'package:per_habit/features/user/data/models/user_profile_model.dart';

// Inventario (modelo compuesto dentro del user doc)
import 'package:per_habit/features/inventary/data/models/inventory_model.dart';
import 'package:per_habit/features/inventary/data/models/mascota_model.dart';
import 'package:per_habit/features/inventary/data/models/alimento_model.dart';
import 'package:per_habit/features/inventary/data/models/accesorio_model.dart';
import 'package:per_habit/features/inventary/data/models/decoracion_model.dart';
import 'package:per_habit/features/inventary/data/models/fondo_model.dart';

abstract class ShopDatasource {
  Stream<List<ShopItemModel>> watchShopItems();
  Future<void> purchaseShopItem(String userId, ShopItemModel shopItem);
  Future<void> purchaseHabiPoints(String userId, int amount);
  Future<UserProfileModel> getUser(String userId);
}

class ShopDatasourceImpl implements ShopDatasource {
  final FirebaseFirestore firestore;
  ShopDatasourceImpl(this.firestore);

  @override
  Stream<List<ShopItemModel>> watchShopItems() {
    return firestore
        .collection('shop')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => ShopItemModel.fromMap(doc.data()))
                  .toList(),
        );
  }

  @override
  Future<void> purchaseShopItem(String userId, ShopItemModel shopItem) async {
    final userRef = firestore.collection('users').doc(userId);

    await firestore.runTransaction((tx) async {
      final userSnap = await tx.get(userRef);
      if (!userSnap.exists) {
        throw Exception('Usuario no encontrado');
      }

      final user = UserProfileModel.fromMap(userSnap.data()!, userId);
      if (user.habipoints < shopItem.price) {
        throw Exception('Insufficient HabiPoints');
      }

      // Lee inventario actual (puede venir vacío)
      final invMap =
          (userSnap.data()!['inventario'] as Map<String, dynamic>?) ?? {};
      InventarioModel inventario = InventarioModel.fromMap(invMap);

      // Copias mutables de las listas (tipadas)
      final List<MascotaModel> mascotas = List<MascotaModel>.from(
        inventario.mascotas,
      );
      final List<AlimentoModel> alimentos = List<AlimentoModel>.from(
        inventario.alimentos,
      );
      final List<AccesorioModel> accesorios = List<AccesorioModel>.from(
        inventario.accesorios,
      );
      final List<DecoracionModel> decoraciones = List<DecoracionModel>.from(
        inventario.decoraciones,
      );
      final List<FondoModel> fondos = List<FondoModel>.from(inventario.fondos);

      // Helpers de merge por tipo (sin cast genérico)
      void mergeMascota(ItemModel base) {
        final idx = mascotas.indexWhere((e) => e.id == base.id);
        if (idx >= 0) {
          final prev = mascotas[idx];
          mascotas[idx] = MascotaModel(
            id: prev.id,
            nombre: prev.nombre,
            descripcion: prev.descripcion,
            icono: prev.icono,
            cantidad: prev.cantidad + base.cantidad,
            category: 'mascota',
          );
        } else {
          mascotas.add(
            MascotaModel(
              id: base.id,
              nombre: base.nombre,
              descripcion: base.descripcion,
              icono: base.icono,
              cantidad: base.cantidad,
              category: 'mascota',
            ),
          );
        }
      }

      void mergeAlimento(ItemModel base) {
        final idx = alimentos.indexWhere((e) => e.id == base.id);
        if (idx >= 0) {
          final prev = alimentos[idx];
          alimentos[idx] = AlimentoModel(
            id: prev.id,
            nombre: prev.nombre,
            descripcion: prev.descripcion,
            icono: prev.icono,
            cantidad: prev.cantidad + base.cantidad,
            category: 'alimento',
          );
        } else {
          alimentos.add(
            AlimentoModel(
              id: base.id,
              nombre: base.nombre,
              descripcion: base.descripcion,
              icono: base.icono,
              cantidad: base.cantidad,
              category: 'alimento',
            ),
          );
        }
      }

      void mergeAccesorio(ItemModel base) {
        final idx = accesorios.indexWhere((e) => e.id == base.id);
        if (idx >= 0) {
          final prev = accesorios[idx];
          accesorios[idx] = AccesorioModel(
            id: prev.id,
            nombre: prev.nombre,
            descripcion: prev.descripcion,
            icono: prev.icono,
            cantidad: prev.cantidad + base.cantidad,
            category: 'accesorio',
          );
        } else {
          accesorios.add(
            AccesorioModel(
              id: base.id,
              nombre: base.nombre,
              descripcion: base.descripcion,
              icono: base.icono,
              cantidad: base.cantidad,
              category: 'accesorio',
            ),
          );
        }
      }

      void mergeDecoracion(ItemModel base) {
        final idx = decoraciones.indexWhere((e) => e.id == base.id);
        if (idx >= 0) {
          final prev = decoraciones[idx];
          decoraciones[idx] = DecoracionModel(
            id: prev.id,
            nombre: prev.nombre,
            descripcion: prev.descripcion,
            icono: prev.icono,
            cantidad: prev.cantidad + base.cantidad,
            category: 'decoracion',
          );
        } else {
          decoraciones.add(
            DecoracionModel(
              id: base.id,
              nombre: base.nombre,
              descripcion: base.descripcion,
              icono: base.icono,
              cantidad: base.cantidad,
              category: 'decoracion',
            ),
          );
        }
      }

      void mergeFondo(ItemModel base) {
        final idx = fondos.indexWhere((e) => e.id == base.id);
        if (idx >= 0) {
          final prev = fondos[idx];
          fondos[idx] = FondoModel(
            id: prev.id,
            nombre: prev.nombre,
            descripcion: prev.descripcion,
            icono: prev.icono,
            cantidad: prev.cantidad + base.cantidad,
            category: 'fondo',
          );
        } else {
          fondos.add(
            FondoModel(
              id: base.id,
              nombre: base.nombre,
              descripcion: base.descripcion,
              icono: base.icono,
              cantidad: base.cantidad,
              category: 'fondo',
            ),
          );
        }
      }

      // Procesa el contenido del ítem/paquete
      for (final base in shopItem.content) {
        switch ((base.category).toLowerCase()) {
          case 'mascota':
            mergeMascota(base);
            break;
          case 'alimento':
            mergeAlimento(base);
            break;
          case 'accesorio':
            mergeAccesorio(base);
            break;
          case 'decoracion':
            mergeDecoracion(base);
            break;
          case 'fondo':
            mergeFondo(base);
            break;
          default:
            throw Exception(
              'Categoría desconocida en compra: "${base.category}" para item ${base.id}',
            );
        }
      }

      // Guarda inventario y descuenta puntos
      final updatedInventario = InventarioModel(
        userId: userId,
        mascotas: mascotas,
        alimentos: alimentos,
        accesorios: accesorios,
        decoraciones: decoraciones,
        fondos: fondos,
      );

      tx.update(userRef, {
        'habipoints': user.habipoints - shopItem.price,
        'inventario': updatedInventario.toMap(),
      });
    });
  }

  @override
  Future<void> purchaseHabiPoints(String userId, int amount) async {
    final userRef = firestore.collection('users').doc(userId);
    await firestore.runTransaction((tx) async {
      final snap = await tx.get(userRef);
      if (!snap.exists) throw Exception('Usuario no encontrado');
      final user = UserProfileModel.fromMap(snap.data()!, userId);
      tx.update(userRef, {'habipoints': user.habipoints + amount});
    });
  }

  @override
  Future<UserProfileModel> getUser(String userId) async {
    final doc = await firestore.collection('users').doc(userId).get();
    if (!doc.exists) throw Exception('Usuario no encontrado');
    return UserProfileModel.fromMap(doc.data()!, userId);
  }
}
