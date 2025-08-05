import 'package:per_habit/features/inventary/domain/entities/items.dart';

class ShopItem {
  final String id;
  final String name;
  final String description;
  final String icono;
  final int price; // In HabiPoints
  final bool isOffer; // For 'Ofertas' tab
  final bool isBundle; // True for packages
  final List<Item> content; // Always a List<Item>, single or multiple

  ShopItem({
    required this.id,
    required this.name,
    required this.description,
    required this.icono,
    required this.price,
    this.isOffer = false,
    this.isBundle = false,
    required this.content,
  });
}
