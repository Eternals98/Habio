import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:per_habit/core/config/present/screens/tabs/catalogo_tab.dart';
import 'package:per_habit/core/config/present/screens/tabs/notification_tab.dart';
import 'package:per_habit/core/config/present/screens/tabs/pets_tab.dart';
import 'package:per_habit/core/config/present/screens/tabs/shop_tab.dart';

// ⬇️ NUEVO: provider para disparar “guardar todo”
import 'package:per_habit/core/config/providers/config_provider.dart';

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
      length: 4, // Mascotas + Catálogo + Tienda + Notificaciones
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin'),
          actions: [
            // ⬇️ Botón Guardar (para otras pestañas)
            IconButton(
              tooltip: 'Guardar cambios',
              icon: const Icon(Icons.save),
              onPressed: () {
                ref.read(saveAllProvider.notifier).bump();
                FocusScope.of(context).unfocus();
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Guardando…')));
              },
            ),
            IconButton(
              tooltip: 'Inicio',
              icon: const Icon(Icons.home),
              onPressed: () => context.go('/home'),
            ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Mascotas'),
              Tab(text: 'Catálogo'),
              Tab(text: 'Tienda'),
              Tab(text: 'Notificaciones'), // ⬅️ NUEVO
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            PetsTab(),
            CatalogTab(),
            ShopTab(),
            NotificationsTab(), // ⬅️ NUEVO
          ],
        ),
      ),
    );
  }
}
