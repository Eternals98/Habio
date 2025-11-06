import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:per_habit/core/theme/app_colors.dart';
import 'package:per_habit/features/auth/presentation/widgets/login_form.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 900;

          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryBackground,
                  AppColors.secondaryBackground,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 32,
                    ),
                    child:
                        isWide
                            ? _WideLayout(hero: _HeroSection(isCompact: false))
                            : const _CompactLayout(),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _WideLayout extends StatelessWidget {
  const _WideLayout({required this.hero});

  final Widget hero;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(flex: 3, child: hero),
        const SizedBox(width: 48),
        const Expanded(flex: 2, child: _FormSection()),
      ],
    );
  }
}

class _CompactLayout extends StatelessWidget {
  const _CompactLayout();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          _HeroSection(isCompact: true),
          SizedBox(height: 32),
          _FormSection(),
        ],
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.isCompact});

  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment:
          isCompact ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Construye hábitos saludables',
          textAlign: isCompact ? TextAlign.center : TextAlign.start,
          style: GoogleFonts.poppins(
            color: AppColors.primaryText,
            fontSize: isCompact ? 28 : 38,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Descubre herramientas que te acompañan cada día en tu camino al bienestar.',
          textAlign: isCompact ? TextAlign.center : TextAlign.start,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.secondaryText,
            fontSize: 16,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 32),
        Align(
          alignment:
              isCompact ? Alignment.center : Alignment.centerLeft,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: isCompact ? 320 : 420,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(36),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.18),
                width: 1.2,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Semantics(
              label: 'Ilustración de hábitos saludables',
              child: Image.asset(
                'assets/images/pets/penguin_full.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FormSection extends StatelessWidget {
  const _FormSection();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.08),
              blurRadius: 32,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        child: const LoginForm(),
      ),
    );
  }
}
