import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:per_habit/features/user/domain/entities/user_profile.dart';
import 'package:per_habit/features/user/presentation/controllers/user_provider.dart';

class UserProfileForm extends ConsumerWidget {
  final UserProfile profile;

  const UserProfileForm({super.key, required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController(text: profile.displayName);
    final avatarController = TextEditingController(text: profile.photoUrl);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nombre de usuario',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: nameController,
          decoration: const InputDecoration(
            hintText: 'Tu nombre',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        const Text('Avatar URL', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: avatarController,
          decoration: const InputDecoration(
            hintText: 'https://...',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              final updated = profile.copyWith(
                displayName: nameController.text.trim(),
                photoUrl: avatarController.text.trim(),
              );

              ref.read(userControllerProvider.notifier).updateProfile(updated);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Perfil actualizado')),
              );
            },
            child: const Text('Guardar cambios'),
          ),
        ),
      ],
    );
  }
}
