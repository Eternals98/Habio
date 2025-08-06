import 'package:flutter/material.dart';
import 'package:per_habit/features/inventary/domain/entities/items.dart';
import 'package:per_habit/features/store/domain/entities/shop_item.dart';

class ShopItemList extends StatelessWidget {
  final List<ShopItem> shopItems;
  final String? selectedCategory;
  final void Function(ShopItem) onPurchase;

  const ShopItemList({
    super.key,
    required this.shopItems,
    this.selectedCategory,
    required this.onPurchase,
  });

  @override
  Widget build(BuildContext context) {
    final filteredItems = _getFilteredItems();

    return ListView.builder(
      itemCount: filteredItems.length,
      itemBuilder: (context, index) {
        final item = filteredItems[index];
        return ListTile(
          leading: Text(item.icono),
          title: Text(item.name),
          subtitle: Text(
            '${item.description}\nPrecio: ${item.price} HabiPoints${item.isOffer ? ' (Oferta)' : ''}\nContenido: ${_getContentDescription(item.content)}',
          ),
          trailing: IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () => onPurchase(item),
          ),
        );
      },
    );
  }

  List<ShopItem> _getFilteredItems() {
    if (selectedCategory == null) {
      return shopItems;
    }
    if (selectedCategory == 'oferta') {
      return shopItems.where((item) => item.isOffer).toList();
    }
    if (selectedCategory == 'habipoints') {
      return shopItems
          .where((item) => item.name.contains('HabiPoints'))
          .toList();
    }
    return shopItems.where((item) {
      return item.content.any((contentItem) {
        return switch (contentItem) {
          Mascota _ => selectedCategory == 'mascota',
          Alimento _ => selectedCategory == 'alimento',
          Accesorio _ => selectedCategory == 'accesorio',
          Decoracion _ => selectedCategory == 'decoracion',
          Fondo _ => selectedCategory == 'fondo',
          _ => false,
        };
      });
    }).toList();
  }

  String _getContentDescription(List<Item> content) {
    if (content.isEmpty) return 'Ninguno';
    return content
        .map((item) => '${item.nombre} (x${item.cantidad})')
        .join(', ');
  }
}
