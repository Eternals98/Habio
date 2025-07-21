import 'package:flutter/material.dart';
import 'package:per_habit/features/navigation/presentation/widgets/custom_bottom_nav_bar.dart';

class NavigationShell extends StatelessWidget {
  final Widget child;
  const NavigationShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }
}
