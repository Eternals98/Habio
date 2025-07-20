import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:per_habit/features/auth/presentation/controller/auth_providers.dart';


class LogoutButton extends ConsumerWidget {
  final String redirectRoute;

  const LogoutButton({super.key, this.redirectRoute = '/login'});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loading = ref.watch(authControllerProvider).loading;

    return TextButton(
      onPressed: loading
          ? null
          : () async {
              await ref.read(authControllerProvider.notifier).logout();
              context.go(redirectRoute);
            },
      child: const Text('Cerrar sesión'),
    );
  }
}
