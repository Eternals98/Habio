import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:per_habit/features/auth/presentation/controllers/auth_providers.dart';
import 'package:per_habit/features/notification/presentation/notification_controller.dart';
import 'package:per_habit/features/notification/presentation/screens/notification_screen.dart';
import 'package:per_habit/features/store/presentation/controllers/shop_provider.dart';

class AppBarActions extends ConsumerWidget {
  const AppBarActions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final userId = authState.user?.uid;

    // Stream con perfil para HabiPoints
    final userState =
        (userId != null)
            ? ref.watch(userStreamProvider(userId))
            : const AsyncValue.loading();

    final currentLocation = ModalRoute.of(context)?.settings.name;

    // 👇 unread para badge
    final unread = ref.watch(unreadCountProvider);

    return Row(
      children: [
        userState.when(
          data:
              (user) => GestureDetector(
                onTap: () => context.push('/store?category=habipoints'),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Chip(
                    label: Text('${user.habipoints} HabiPoints'),
                    avatar: const Icon(Icons.monetization_on, size: 18),
                  ),
                ),
              ),
          loading:
              () => const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
          error:
              (_, __) => const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Text('HP --'),
              ),
        ),

        // 🔔 Notificaciones locales
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              tooltip: 'Notificaciones',
              icon: const Icon(Icons.notifications),
              onPressed: () => NotificationsSheet.show(context),
            ),
            if (unread > 0)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    unread > 99 ? '99+' : '$unread',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),

        IconButton(
          icon: const Icon(Icons.person),
          onPressed:
              currentLocation == '/profile'
                  ? null
                  : () => context.pushReplacement('/profile'),
          color: currentLocation == '/profile' ? Colors.grey : null,
        ),
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () {
            ref.read(authControllerProvider.notifier).logout();
            context.go('/login');
          },
        ),
      ],
    );
  }
}
