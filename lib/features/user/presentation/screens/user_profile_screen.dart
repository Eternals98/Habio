import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:per_habit/features/auth/presentation/controllers/auth_providers.dart';
import 'package:per_habit/features/user/presentation/controllers/user_provider.dart';
import 'package:per_habit/features/user/presentation/widgets/user_profile_form.dart';
// ignore: unused_import
import 'package:per_habit/features/auth/domain/entities/auth_user.dart';
// ignore: unused_import
import 'package:firebase_auth/firebase_auth.dart';

class UserProfileScreen extends ConsumerStatefulWidget {
  const UserProfileScreen({super.key});

  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final authUser = ref.read(authControllerProvider).user;
      if (authUser != null) {
        ref.read(userControllerProvider.notifier).loadProfile(authUser.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userControllerProvider);
    final authState = ref.watch(authControllerProvider);

    if (authState.user == null) {
      return const Scaffold(body: Center(child: Text('Sesión no iniciada')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil de usuario')),
      body:
          userState.loading
              ? const Center(child: CircularProgressIndicator())
              : userState.profile == null
              ? Center(child: Text(userState.error ?? 'Perfil no encontrado'))
              : Padding(
                padding: const EdgeInsets.all(16),
                child: UserProfileForm(profile: userState.profile!),
              ),
    );
  }
}
