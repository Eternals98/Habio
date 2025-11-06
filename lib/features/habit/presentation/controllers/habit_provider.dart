// lib/features/habit/presentation/controllers/habit_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:per_habit/core/firebase/firebase_providers.dart';
import 'package:per_habit/features/habit/application/habit.services.dart';

import 'habit_controller.dart';
import 'package:per_habit/features/habit/domain/entities/habit.dart';
import 'package:per_habit/features/habit/domain/reposotories/habit_repository.dart';
import 'package:per_habit/features/habit/data/habit_repository_impl.dart';
import 'package:per_habit/features/habit/data/datasources/habit_datasource.dart';

/// 🔹 Datasource Provider
final habitDatasourceProvider = Provider<HabitDatasource>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  return HabitDatasourceImpl(firestore);
});

/// 🔹 Repository Provider
final habitRepositoryProvider = Provider<HabitRepository>((ref) {
  final datasource = ref.read(habitDatasourceProvider);
  return HabitRepositoryImpl(datasource);
});

/// 🔹 Controller Provider
final habitControllerProvider =
    AutoDisposeAsyncNotifierProvider<HabitController, List<Habit>>(
      HabitController.new,
    );

/// 🔹 UseCase Provider
final getHabitsByRoomUseCaseProvider = Provider<GetHabitsByRoomUseCase>((ref) {
  final repository = ref.watch(habitRepositoryProvider);
  return GetHabitsByRoomUseCase(repository);
});

/// 🔹 StreamProvider con roomId dinámico
final habitsByRoomProvider = StreamProvider.family<List<Habit>, String>((
  ref,
  roomId,
) {
  final useCase = ref.watch(getHabitsByRoomUseCaseProvider);
  return useCase(roomId);
});
