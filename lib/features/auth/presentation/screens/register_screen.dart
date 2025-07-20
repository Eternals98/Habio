import 'package:flutter/material.dart';
import 'package:per_habit/core/theme/app_colors.dart';
import 'package:per_habit/features/auth/presentation/widgets/login_form.dart';


class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? AppColors.primaryBackgroundDark : AppColors.primaryBackground;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: const Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 48),
          child: LoginForm(isLogin: false),
        ),
      ),
    );
  }
}
