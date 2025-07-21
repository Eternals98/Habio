import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({super.key});

  static const _tabs = ['/home', '/store', '/inventary', '/profile'];

  int _locationToIndex(String location) {
    return _tabs.indexWhere((path) => location.startsWith(path));
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _locationToIndex(location);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, -2),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: BottomNavigationBar(
          currentIndex: currentIndex != -1 ? currentIndex : 0,
          onTap: (index) => context.go(_tabs[index]),
          backgroundColor: Colors.white,
          elevation: 0,
          selectedItemColor: const Color(0xFF4CAF50), // verde emocional Habio
          unselectedItemColor: Colors.grey[400],
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.pets), label: 'Espacios'),
            BottomNavigationBarItem(
              icon: Icon(Icons.local_mall),
              label: 'Tienda',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.inventory),
              label: 'Inventario',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
          ],
        ),
      ),
    );
  }
}
