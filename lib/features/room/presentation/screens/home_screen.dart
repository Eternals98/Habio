import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:per_habit/features/auth/presentation/controllers/auth_providers.dart';
// ignore: unused_import
import 'package:per_habit/features/user/presentation/controllers/user_controller.dart';
import 'package:per_habit/features/room/presentation/controllers/room_providers.dart';
import 'package:per_habit/features/room/presentation/widgets/create_room_dialog.dart';
import 'package:per_habit/features/room/presentation/widgets/room_carousel.dart';
import 'package:per_habit/features/user/presentation/controllers/user_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      final uid = ref.read(authControllerProvider).user?.uid;
      if (uid != null) {
        ref.read(userControllerProvider.notifier).loadProfile(uid);
      }
    });
  }

  Future<void> _createRoom() async {
    final user = ref.read(authControllerProvider).user;
    if (user == null) return;

    final name = await CreateRoomDialog.show(context);
    if (name != null && name.isNotEmpty) {
      await ref.read(roomControllerProvider.notifier).create(name, user.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).user;
    final roomsAsync = ref.watch(roomStreamProvider(user?.uid ?? ''));
    final profile = ref.watch(userControllerProvider).profile;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Mis lugares'),
            if (profile != null)
              Text(
                profile.displayName,
                style: Theme.of(context).textTheme.labelMedium,
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authControllerProvider.notifier).logout();
              context.go('/login');
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createRoom,
        child: const Icon(Icons.add),
      ),
      body: roomsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (rooms) {
          if (rooms.isEmpty) {
            return const Center(child: Text('Aún no tienes lugares.'));
          }

          return RoomCarousel(
            rooms: rooms,
            selectedIndex: _selectedIndex,
            onPageChanged: (index) {
              setState(() => _selectedIndex = index);
            },
            onTap: (room) => context.push('/room/${room.id}'),
            onEdit: (room) async {
              final name = await CreateRoomDialog.show(context);
              if (name != null && name.isNotEmpty) {
                await ref
                    .read(roomControllerProvider.notifier)
                    .rename(room.id, name);
              }
            },
            onDelete: (room) async {
              await ref.read(roomControllerProvider.notifier).remove(room.id);
            },
          );
        },
      ),
    );
  }
}
