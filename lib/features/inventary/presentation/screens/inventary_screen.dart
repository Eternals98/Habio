// lib/features/inventary/presentation/screens/inventary_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:per_habit/features/inventary/presentation/controllers/inventary_provider.dart';
import 'package:per_habit/features/inventary/presentation/widgets/item_list.dart';
import 'package:per_habit/features/navigation/presentation/widgets/app_bar_actions.dart';

class InventaryScreen extends ConsumerStatefulWidget {
  const InventaryScreen({super.key});

  @override
  ConsumerState<InventaryScreen> createState() => _InventaryScreenState();
}

class _InventaryScreenState extends ConsumerState<InventaryScreen> {
  String? _selectedCategory;
  String? _boundUserId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null && uid != _boundUserId) {
      _boundUserId = uid;
      // Suscríbete al inventario del usuario
      ref.read(inventoryControllerProvider.notifier).listenToInventory(uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(inventoryControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventario'),
        actions: const [AppBarActions()],
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (inventario) {
          return Column(
            children: [
              _buildCategoryButtons(),
              Expanded(
                child: ItemList(
                  inventario: inventario,
                  selectedCategory: _selectedCategory,
                ),
              ),
            ],
          );
        },
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
        onPressed: () => setState(() => _selectedCategory = category),
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Theme.of(context).primaryColor : null,
          foregroundColor: isSelected ? Colors.white : null,
        ),
        child: Text(label),
      ),
    );
  }
}
