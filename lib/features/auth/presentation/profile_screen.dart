import 'package:flutter/material.dart';
import 'package:per_habit/features/auth/widgets/profile_form.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi Perfil')),
      body: ProfileForm(),
    );
  }
}
