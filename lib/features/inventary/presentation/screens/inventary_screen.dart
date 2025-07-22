import 'package:flutter/material.dart';
import 'package:per_habit/features/inventary/domain/entities/inventory.dart';
import 'package:per_habit/features/inventary/presentation/widgets/item_list.dart';

class InventaryScreen extends StatefulWidget {
  final Inventario inventario;

  const InventaryScreen({super.key, required this.inventario});

  @override
  State<InventaryScreen> createState() => _InventaryScreenState();
}

class _InventaryScreenState extends State<InventaryScreen> {
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inventario')),
      body: Column(
        children: [
          _buildCategoryButtons(),
          Expanded(
            child: ItemList(
              inventario: widget.inventario,
              selectedCategory: _selectedCategory,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryButtons() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          _buildCategoryButton(null, 'Todos'),
          _buildCategoryButton('mascota', 'Mascotas'),
          _buildCategoryButton('alimento', 'Alimentos'),
          _buildCategoryButton('accesorio', 'Accesorios'),
          _buildCategoryButton('decoracion', 'Decoraciones'),
          _buildCategoryButton('fondo', 'Fondos'),
        ],
      ),
    );
  }

  Widget _buildCategoryButton(String? category, String label) {
    final isSelected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _selectedCategory = category;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Theme.of(context).primaryColor : null,
          foregroundColor: isSelected ? Colors.white : null,
        ),
        child: Text(label),
      ),
    );
  }
}
