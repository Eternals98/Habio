import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:per_habit/features/auth/presentation/controllers/auth_providers.dart';
import 'package:per_habit/features/store/presentation/controllers/shop_provider.dart';

class AppBarActions extends ConsumerWidget {
  const AppBarActions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final userId = authState.user?.uid;
    final userState =
        userId != null
            ? ref.watch(userProvider(userId))
            : const AsyncValue.loading();
    final currentLocation = ModalRoute.of(context)?.settings.name;

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
          loading: () => const CircularProgressIndicator(),
          error: (_, __) => const Text('Error'),
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
