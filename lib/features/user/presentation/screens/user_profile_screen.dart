import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:per_habit/features/auth/presentation/controllers/auth_providers.dart';
import 'package:per_habit/features/navigation/presentation/widgets/app_bar_actions.dart';
import 'package:per_habit/features/user/presentation/controllers/user_provider.dart';
import 'package:per_habit/features/user/presentation/widgets/user_profile_form.dart';

class UserProfileScreen extends ConsumerStatefulWidget {
  const UserProfileScreen({super.key});

  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userControllerProvider);
    final authState = ref.watch(authControllerProvider);

    if (authState.user == null) {
      return const Scaffold(body: Center(child: Text('Sesión no iniciada')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil de usuario'),
        actions: const [AppBarActions()],
      ),
      body: userState.when(
        data:
            (profile) =>
                profile == null
                    ? const Center(child: Text('Perfil no encontrado'))
                    : Padding(
                      padding: const EdgeInsets.all(16),
                      child: UserProfileForm(profile: profile),
                    ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
