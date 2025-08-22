// lib/features/admin/presentation/screens/admin_panel_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:per_habit/core/config/present/screens/tabs/catalogo_tab.dart';
import 'package:per_habit/core/config/present/screens/tabs/pets_tab.dart';
import 'package:per_habit/core/config/present/screens/tabs/shop_tab.dart';

class AdminPanelScreen extends ConsumerStatefulWidget {
  const AdminPanelScreen({super.key});
  @override
  ConsumerState<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends ConsumerState<AdminPanelScreen>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Mascotas + Catálogo + Tienda
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin'),
          actions: [
            IconButton(
              tooltip: 'Inicio',
              icon: const Icon(Icons.home),
              onPressed: () => context.go('/home'),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Mascotas'),
              Tab(text: 'Catálogo'),
              Tab(text: 'Tienda'),
            ],
          ),
        ),
        body: const TabBarView(children: [PetsTab(), CatalogTab(), ShopTab()]),
      ),
    );
  }
}
