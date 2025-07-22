import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:per_habit/features/auth/application/login_case_use_case.dart';
import 'package:per_habit/features/auth/application/register_use_case.dart';
import 'package:per_habit/features/auth/application/reset_password_use_case.dart';
import 'package:per_habit/features/auth/domain/entities/auth_user.dart';
import 'package:per_habit/features/auth/domain/repositories/auth_repository.dart';
import 'package:per_habit/features/user/application/get_user_profile_use_case.dart';

/// Estado del controlador de autenticación
class AuthState {
  final bool loading;
  final AuthUser? user;
  final String? error;

  const AuthState({this.loading = false, this.user, this.error});

  AuthState copyWith({bool? loading, AuthUser? user, String? error}) {
    return AuthState(
      loading: loading ?? this.loading,
      user: user ?? this.user,
      error: error,
    );
  }
}

/// Controlador de autenticación con lógica desacoplada de la UI
class AuthController extends StateNotifier<AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final ResetPasswordUseCase resetPasswordUseCase;
  final AuthRepository repository;
  final GetUserProfileUseCase getUserProfileUseCase;

  AuthController({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.resetPasswordUseCase,
    required this.repository,
    required this.getUserProfileUseCase,
  }) : super(const AuthState()) {
    _init();
  }

  void _init() {
    FirebaseAuth.instance.authStateChanges().listen((firebaseUser) async {
      if (firebaseUser == null) {
        state = const AuthState(user: null, loading: false);
      } else {
        try {
          final userProfile = await getUserProfileUseCase(firebaseUser.uid);
          state = state.copyWith(
            user: AuthUser(uid: userProfile.id, email: userProfile.email),
            loading: false,
            error: null,
          );
        } catch (e) {
          state = state.copyWith(
            user: null,
            loading: false,
            error: e.toString(),
          );
        }
      }
    });
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final user = await loginUseCase(email: email, password: password);
      state = state.copyWith(loading: false, user: user);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> register(String email, String password) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final user = await registerUseCase(email: email, password: password);
      state = state.copyWith(loading: false, user: user);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> resetPassword(String email) async {
    state = state.copyWith(loading: true, error: null);
    try {
      await resetPasswordUseCase(email: email);
      state = state.copyWith(loading: false);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> logout() async {
    state = state.copyWith(loading: true, error: null);
    try {
      await repository.logout(); // Cierra sesión en Firebase
      state = const AuthState(user: null, loading: false);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }
}
