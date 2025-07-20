// lib/features/habit/presentation/controllers/habit_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'habit_controller.dart';
import 'package:per_habit/features/habit/domain/entities/habit.dart';
import 'package:per_habit/features/habit/domain/reposotories/habit_repository.dart';
import 'package:per_habit/features/habit/data/habit_repository_impl.dart';
import 'package:per_habit/features/habit/data/datasources/habit_datasource.dart';

final habitDatasourceProvider = Provider<HabitDatasource>((ref) {
  return HabitDatasourceImpl(FirebaseFirestore.instance);
});

final habitRepositoryProvider = Provider<HabitRepository>((ref) {
  final datasource = ref.read(habitDatasourceProvider);
  return HabitRepositoryImpl(datasource);
});

final habitControllerProvider =
    AutoDisposeAsyncNotifierProvider<HabitController, List<Habit>>(
      HabitController.new,
    );
