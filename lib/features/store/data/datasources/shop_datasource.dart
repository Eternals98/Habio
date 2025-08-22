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

  /// 🔴 Para UI en tiempo real (HabiPoints y demás campos del usuario)
  Stream<UserProfileModel> watchUser(String userId);
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
  Stream<UserProfileModel> watchUser(String userId) {
    return firestore.collection('users').doc(userId).snapshots().map((snap) {
      if (!snap.exists) {
        throw Exception('Usuario no encontrado');
      }
      return UserProfileModel.fromMap(snap.data()!, userId);
    });
  }

  @override
  Future<UserProfileModel> getUser(String userId) async {
    final doc = await firestore.collection('users').doc(userId).get();
    if (!doc.exists) throw Exception('Usuario no encontrado');
    return UserProfileModel.fromMap(doc.data()!, userId);
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
      final inventario = InventarioModel.fromMap(invMap);

      // Pasamos listas a mapas para merges O(1) por id
      final mascotasMap = <String, MascotaModel>{
        for (final m in inventario.mascotas)
          if (m is MascotaModel)
            m.id: m
          else
            m.id: MascotaModel(
              id: m.id,
              nombre: m.nombre,
              descripcion: m.descripcion,
              icono: m.icono,
              cantidad: m.cantidad,
              category: 'mascota',
            ),
      };

      final alimentosMap = <String, AlimentoModel>{
        for (final a in inventario.alimentos)
          if (a is AlimentoModel)
            a.id: a
          else
            a.id: AlimentoModel(
              id: a.id,
              nombre: a.nombre,
              descripcion: a.descripcion,
              icono: a.icono,
              cantidad: a.cantidad,
              category: 'alimento',
            ),
      };

      final accesoriosMap = <String, AccesorioModel>{
        for (final a in inventario.accesorios)
          if (a is AccesorioModel)
            a.id: a
          else
            a.id: AccesorioModel(
              id: a.id,
              nombre: a.nombre,
              descripcion: a.descripcion,
              icono: a.icono,
              cantidad: a.cantidad,
              category: 'accesorio',
            ),
      };

      final decoracionesMap = <String, DecoracionModel>{
        for (final d in inventario.decoraciones)
          if (d is DecoracionModel)
            d.id: d
          else
            d.id: DecoracionModel(
              id: d.id,
              nombre: d.nombre,
              descripcion: d.descripcion,
              icono: d.icono,
              cantidad: d.cantidad,
              category: 'decoracion',
            ),
      };

      final fondosMap = <String, FondoModel>{
        for (final f in inventario.fondos)
          if (f is FondoModel)
            f.id: f
          else
            f.id: FondoModel(
              id: f.id,
              nombre: f.nombre,
              descripcion: f.descripcion,
              icono: f.icono,
              cantidad: f.cantidad,
              category: 'fondo',
            ),
      };

      // Helpers de merge por tipo (sin cast genérico)
      void mergeMascota(ItemModel base) {
        final prev = mascotasMap[base.id];
        if (prev != null) {
          mascotasMap[base.id] = MascotaModel(
            id: prev.id,
            nombre: prev.nombre,
            descripcion: prev.descripcion,
            icono: prev.icono,
            cantidad: prev.cantidad + base.cantidad,
            category: 'mascota',
          );
        } else {
          mascotasMap[base.id] = MascotaModel(
            id: base.id,
            nombre: base.nombre,
            descripcion: base.descripcion,
            icono: base.icono,
            cantidad: base.cantidad,
            category: 'mascota',
          );
        }
      }

      void mergeAlimento(ItemModel base) {
        final prev = alimentosMap[base.id];
        if (prev != null) {
          alimentosMap[base.id] = AlimentoModel(
            id: prev.id,
            nombre: prev.nombre,
            descripcion: prev.descripcion,
            icono: prev.icono,
            cantidad: prev.cantidad + base.cantidad,
            category: 'alimento',
          );
        } else {
          alimentosMap[base.id] = AlimentoModel(
            id: base.id,
            nombre: base.nombre,
            descripcion: base.descripcion,
            icono: base.icono,
            cantidad: base.cantidad,
            category: 'alimento',
          );
        }
      }

      void mergeAccesorio(ItemModel base) {
        final prev = accesoriosMap[base.id];
        if (prev != null) {
          accesoriosMap[base.id] = AccesorioModel(
            id: prev.id,
            nombre: prev.nombre,
            descripcion: prev.descripcion,
            icono: prev.icono,
            cantidad: prev.cantidad + base.cantidad,
            category: 'accesorio',
          );
        } else {
          accesoriosMap[base.id] = AccesorioModel(
            id: base.id,
            nombre: base.nombre,
            descripcion: base.descripcion,
            icono: base.icono,
            cantidad: base.cantidad,
            category: 'accesorio',
          );
        }
      }

      void mergeDecoracion(ItemModel base) {
        final prev = decoracionesMap[base.id];
        if (prev != null) {
          decoracionesMap[base.id] = DecoracionModel(
            id: prev.id,
            nombre: prev.nombre,
            descripcion: prev.descripcion,
            icono: prev.icono,
            cantidad: prev.cantidad + base.cantidad,
            category: 'decoracion',
          );
        } else {
          decoracionesMap[base.id] = DecoracionModel(
            id: base.id,
            nombre: base.nombre,
            descripcion: base.descripcion,
            icono: base.icono,
            cantidad: base.cantidad,
            category: 'decoracion',
          );
        }
      }

      void mergeFondo(ItemModel base) {
        final prev = fondosMap[base.id];
        if (prev != null) {
          fondosMap[base.id] = FondoModel(
            id: prev.id,
            nombre: prev.nombre,
            descripcion: prev.descripcion,
            icono: prev.icono,
            cantidad: prev.cantidad + base.cantidad,
            category: 'fondo',
          );
        } else {
          fondosMap[base.id] = FondoModel(
            id: base.id,
            nombre: base.nombre,
            descripcion: base.descripcion,
            icono: base.icono,
            cantidad: base.cantidad,
            category: 'fondo',
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

      // Convierte mapas a listas
      final updatedInventario = InventarioModel(
        userId: userId,
        mascotas: mascotasMap.values.toList(),
        alimentos: alimentosMap.values.toList(),
        accesorios: accesoriosMap.values.toList(),
        decoraciones: decoracionesMap.values.toList(),
        fondos: fondosMap.values.toList(),
      );

      final newBalance = user.habipoints - shopItem.price;

      tx.update(userRef, {
        'habipoints': newBalance,
        'inventario': updatedInventario.toMap(),
      });
    });
  }
}
