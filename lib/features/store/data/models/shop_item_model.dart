import 'package:per_habit/features/inventary/data/models/accesorio_model.dart';
import 'package:per_habit/features/inventary/data/models/alimento_model.dart';
import 'package:per_habit/features/inventary/data/models/decoracion_model.dart';
import 'package:per_habit/features/inventary/data/models/fondo_model.dart';
import 'package:per_habit/features/inventary/data/models/items_model.dart';
import 'package:per_habit/features/inventary/data/models/mascota_model.dart';

class ShopItemModel {
  final String id;
  final String name;
  final String description;
  final String icono;
  final int price;
  final bool isOffer;
  final bool isBundle;
  final List<ItemModel> content;

  ShopItemModel({
    required this.id,
    required this.name,
    required this.description,
    required this.icono,
    required this.price,
    this.isOffer = false,
    this.isBundle = false,
    required this.content,
  });

  factory ShopItemModel.fromMap(Map<String, dynamic> map, {String? id}) {
    final contentList =
        (map['content'] as List<dynamic>?)?.map<ItemModel>((itemMap) {
          switch (itemMap['category']) {
            case 'mascota':
              return MascotaModel.fromMap(itemMap);
            case 'alimento':
              return AlimentoModel.fromMap(itemMap);
            case 'accesorio':
              return AccesorioModel.fromMap(itemMap);
            case 'decoracion':
              return DecoracionModel.fromMap(itemMap);
            case 'fondo':
              return FondoModel.fromMap(itemMap);
            default:
              throw Exception('Unknown category: ${itemMap['category']}');
          }
        }).toList() ??
        [];

    final rawMapId = map['id'];
    final mapId = rawMapId is String ? rawMapId : rawMapId?.toString();
    final resolvedId = (mapId != null && mapId.isNotEmpty) ? mapId : id ?? '';

    return ShopItemModel(
      id: resolvedId,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      icono: map['icono'] ?? '',
      price: map['price'] ?? 0,
      isOffer: map['isOffer'] ?? false,
      isBundle: map['isBundle'] ?? false,
      content: contentList,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icono': icono,
      'price': price,
      'isOffer': isOffer,
      'isBundle': isBundle,
      'content': content.map((item) => item.toMap()).toList(),
    };
  }

  ShopItemModel copyWith({
    String? id,
    String? name,
    String? description,
    String? icono,
    int? price,
    bool? isOffer,
    bool? isBundle,
    List<ItemModel>? content,
  }) {
    return ShopItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icono: icono ?? this.icono,
      price: price ?? this.price,
      isOffer: isOffer ?? this.isOffer,
      isBundle: isBundle ?? this.isBundle,
      content: content ?? this.content,
    );
  }
}
