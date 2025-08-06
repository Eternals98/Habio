import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:per_habit/features/store/domain/entities/shop_item.dart';
import 'package:per_habit/features/store/presentation/controllers/shop_provider.dart';
import 'package:per_habit/features/store/presentation/widgets/item_list.dart';

class ShopScreen extends ConsumerStatefulWidget {
  const ShopScreen({super.key});

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen> {
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return const Scaffold(
        body: Center(
          child: Text('Por favor, inicia sesión para ver la tienda.'),
        ),
      );
    }

    final shopItemsState = ref.watch(shopItemsStreamProvider);
    final userState = ref.watch(userProvider(userId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tienda'),
        actions: [
          userState.when(
            data:
                (user) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Chip(
                    label: Text('${user.habipoints} HabiPoints'),
                    avatar: const Icon(Icons.monetization_on, size: 18),
                  ),
                ),
            loading: () => const CircularProgressIndicator(),
            error: (_, __) => const Text('Error'),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildCategoryButtons(),
          Expanded(
            child: shopItemsState.when(
              data:
                  (shopItems) => ShopItemList(
                    shopItems: shopItems,
                    selectedCategory: _selectedCategory,
                    onPurchase: (shopItem) => _onPurchase(shopItem),
                  ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Error: $error')),
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
          _buildCategoryButton('oferta', 'Ofertas'),
          _buildCategoryButton('mascota', 'Mascotas'),
          _buildCategoryButton('alimento', 'Alimentos'),
          _buildCategoryButton('accesorio', 'Accesorios'),
          _buildCategoryButton('decoracion', 'Decoraciones'),
          _buildCategoryButton('fondo', 'Fondos'),
          _buildCategoryButton('habipoints', 'HabiPoints'),
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

  void _onPurchase(ShopItem shopItem) async {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, inicia sesión para comprar.')),
      );
      return;
    }
    try {
      if (shopItem.name.contains('HabiPoints')) {
        final amount = _getHabiPointsAmount(shopItem);
        if (amount == null) return;
        await ref.read(
          purchaseHabiPointsProvider(
            PurchaseHabiPointsParams(userId, amount),
          ).future,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Compraste $amount HabiPoints')),
          );
        }
      } else {
        await ref.read(
          purchaseShopItemProvider(
            PurchaseShopItemParams(userId, shopItem),
          ).future,
        );
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Compraste ${shopItem.name}')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al comprar: $e')));
      }
    }
  }

  int? _getHabiPointsAmount(ShopItem shopItem) {
    final packages = {
      '100 HabiPoints': 100,
      '500 HabiPoints': 500,
      '1000 HabiPoints': 1000,
    };
    return packages[shopItem.name];
  }
}
