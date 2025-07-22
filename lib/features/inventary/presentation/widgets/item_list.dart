import 'package:flutter/material.dart';
import 'package:per_habit/features/inventary/domain/entities/inventory.dart';
import 'package:per_habit/features/inventary/domain/entities/items.dart';

class ItemList extends StatelessWidget {
  final Inventario inventario;
  final String? selectedCategory;

  const ItemList({super.key, required this.inventario, this.selectedCategory});

  @override
  Widget build(BuildContext context) {
    final items = _getFilteredAndSortedItems();

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return ListTile(
          title: Text(item.nombre),
          subtitle: Text('Cantidad: ${item.cantidad}'),
        );
      },
    );
  }

  List<Item> _getFilteredAndSortedItems() {
    List<Item> items = [];

    if (selectedCategory == null) {
      items = [
        ...inventario.mascotas,
        ...inventario.alimentos,
        ...inventario.accesorios,
        ...inventario.decoraciones,
        ...inventario.fondos,
      ];
    } else {
      switch (selectedCategory) {
        case 'mascota':
          items = [...inventario.mascotas];
          break;
        case 'alimento':
          items = [...inventario.alimentos];
          break;
        case 'accesorio':
          items = [...inventario.accesorios];
          break;
        case 'decoracion':
          items = [...inventario.decoraciones];
          break;
        case 'fondo':
          items = [...inventario.fondos];
          break;
      }
    }

    return items..sort((a, b) => a.nombre.compareTo(b.nombre));
  }
}
