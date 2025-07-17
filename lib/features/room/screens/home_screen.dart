// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:per_habit/features/room/services/room_service.dart';
import 'package:per_habit/features/room/models/room_model.dart';
import 'package:go_router/go_router.dart';
import 'package:per_habit/features/room/screens/room_detail.dart';
import 'package:per_habit/core/utils/sizes.dart';
import 'package:per_habit/features/room/widgets/room_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Room> _rooms = [];
  int _selectedIndex = -1;
  final RoomService _roomService = RoomService();
  final user = FirebaseAuth.instance.currentUser;

  static const _desktopBreakpoint = 800.0;
  static const _desktopWidthRatio = 0.25;
  static const _mobileWidthRatio = 0.60;
  static const _desktopMarginRatio = 0.015;
  static const _mobileMarginRatio = 0.02;
  static const _minContainerWidth = 150.0;
  static const _maxContainerWidth = 250.0;

  @override
  void initState() {
    super.initState();
    _loadRooms();
  }

  Future<void> _loadRooms() async {
    if (user == null) return;
    try {
      if (mounted) {
        setState(() {
          _rooms.clear();
        });
      }
      final querySnapshot =
          await FirebaseFirestore.instance
              .collection('rooms')
              .where('owner', isEqualTo: user!.uid)
              .get();
      final memberQuerySnapshot =
          await FirebaseFirestore.instance
              .collection('rooms')
              .where('members', arrayContains: user!.uid)
              .get();

      final allDocs = {...querySnapshot.docs, ...memberQuerySnapshot.docs};
      final rooms = <Room>[];
      for (var doc in allDocs) {
        try {
          final room = Room.fromMap(doc.data());
          if (room.id.isNotEmpty && room.owner.isNotEmpty) {
            rooms.add(room);
          } else {
            if (kDebugMode) {
              print('Documento inválido, ID: ${doc.id}, datos: ${doc.data()}');
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error al procesar documento ${doc.id}: $e');
          }
        }
      }

      if (mounted) {
        setState(() {
          _rooms.addAll(rooms);
          if (kDebugMode) {
            print('Lugares cargados desde Firestore: $_rooms');
          }
          if (_rooms.isNotEmpty && _selectedIndex == -1) {
            _selectedIndex = 0;
          }
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error al cargar lugares: $e');
      }
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al cargar lugares: $e')));
      }
    }
  }

  Sizes _calculateSizes(double screenWidth) {
    final isDesktop = screenWidth > _desktopBreakpoint;
    final containerWidth = (isDesktop
            ? screenWidth * _desktopWidthRatio
            : screenWidth * _mobileWidthRatio)
        .clamp(_minContainerWidth, _maxContainerWidth);
    final containerHeight = containerWidth * 1.2;
    final horizontalMargin =
        screenWidth * (isDesktop ? _desktopMarginRatio : _mobileMarginRatio);
    final listViewPadding = screenWidth * 0.05;
    return Sizes(
      containerWidth: containerWidth,
      containerHeight: containerHeight,
      horizontalMargin: horizontalMargin,
      padding: listViewPadding,
    );
  }

  void _selectRoom(int index) {
    if (_rooms.isEmpty) return;
    setState(() {
      _selectedIndex = index.clamp(0, _rooms.length);
    });
  }

  void _navigateToRoomDetails(Room room) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => RoomDetailsScreen(
              room: room,
              rooms: _rooms,
              setState: setState,
              selectedIndex: _selectedIndex,
              scrollToSelected: _selectRoom,
            ),
      ),
    );
    if (result is Room && mounted) {
      setState(() {
        final index = _rooms.indexWhere((r) => r.id == result.id);
        if (index != -1) {
          _rooms[index] = result;
          if (kDebugMode) {
            print('Room actualizado en HomeScreen: $result');
          }
        }
      });
    }
  }

  void _addRoom() {
    _roomService.addRoom(
      context: context,
      rooms: _rooms,
      setState: setState,
      owner: user!.uid,
      scrollToSelected: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
    );
  }

  void _updateRoom(Room room) {
    _roomService.updateRoom(
      context: context,
      room: room,
      rooms: _rooms,
      setState: setState,
      selectedIndex: _selectedIndex,
      scrollToSelected: _selectRoom,
    );
  }

  void _deleteRoom(Room room) {
    _roomService.deleteRoom(
      context: context,
      room: room,
      rooms: _rooms,
      setState: setState,
      selectedIndex: _selectedIndex,
      scrollToSelected: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final sizes = _calculateSizes(screenWidth);
    Widget bodyContent;

    if (_rooms.isEmpty) {
      bodyContent = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Hola ${user?.displayName ?? 'usuario'} 👋",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            const Text('¡Crea tu primer lugar para empezar!'),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.add_circle_outline_rounded),
              label: const Text("Crear Lugar"),
              onPressed: _addRoom,
            ),
          ],
        ),
      );
    } else {
      bodyContent = Column(
        children: [
          const SizedBox(height: 10),
          Text(
            "Bienvenido, ${user?.displayName ?? user?.email ?? 'usuario'} 👋",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_left),
                    onPressed:
                        _selectedIndex > 0
                            ? () => _selectRoom(_selectedIndex - 1)
                            : null,
                    tooltip: 'Anterior',
                  ),
                  SizedBox(width: sizes.horizontalMargin),
                  // Left Card
                  _selectedIndex > 0
                      ? RoomCard(
                        room: _rooms[_selectedIndex - 1],
                        width: sizes.containerWidth,
                        height: sizes.containerHeight,
                        margin: sizes.horizontalMargin,
                        isSelected: false,
                        onTap: () => _selectRoom(_selectedIndex - 1),
                        onAbrir:
                            () => _navigateToRoomDetails(
                              _rooms[_selectedIndex - 1],
                            ),
                        onEdit: () => _updateRoom(_rooms[_selectedIndex - 1]),
                        onDelete: () => _deleteRoom(_rooms[_selectedIndex - 1]),
                      )
                      : SizedBox(
                        width: sizes.containerWidth,
                        height: sizes.containerHeight,
                      ),
                  SizedBox(width: sizes.horizontalMargin),
                  // Center Card
                  _selectedIndex < _rooms.length
                      ? RoomCard(
                        room: _rooms[_selectedIndex],
                        width: sizes.containerWidth,
                        height: sizes.containerHeight,
                        margin: sizes.horizontalMargin,
                        isSelected: true,
                        onTap: () => _selectRoom(_selectedIndex),
                        onAbrir:
                            () =>
                                _navigateToRoomDetails(_rooms[_selectedIndex]),
                        onEdit: () => _updateRoom(_rooms[_selectedIndex]),
                        onDelete: () => _deleteRoom(_rooms[_selectedIndex]),
                      )
                      : InkWell(
                        onTap: _addRoom,
                        child: Container(
                          width: sizes.containerWidth * 0.6,
                          height: sizes.containerHeight,
                          decoration: BoxDecoration(
                            border: Border.all(width: 2),
                          ),
                          child: const Icon(Icons.add_rounded),
                        ),
                      ),
                  SizedBox(width: sizes.horizontalMargin),
                  // Right Card
                  _selectedIndex < _rooms.length - 1
                      ? RoomCard(
                        room: _rooms[_selectedIndex + 1],
                        width: sizes.containerWidth,
                        height: sizes.containerHeight,
                        margin: sizes.horizontalMargin,
                        isSelected: false,
                        onTap: () => _selectRoom(_selectedIndex + 1),
                        onAbrir:
                            () => _navigateToRoomDetails(
                              _rooms[_selectedIndex + 1],
                            ),
                        onEdit: () => _updateRoom(_rooms[_selectedIndex + 1]),
                        onDelete: () => _deleteRoom(_rooms[_selectedIndex + 1]),
                      )
                      : _selectedIndex == _rooms.length
                      ? SizedBox(
                        width: sizes.containerWidth * 0.6,
                        height: sizes.containerHeight,
                      )
                      : InkWell(
                        onTap: _addRoom,
                        child: Container(
                          width: sizes.containerWidth * 0.6,
                          height: sizes.containerHeight,
                          decoration: BoxDecoration(
                            border: Border.all(width: 2),
                          ),
                          child: const Icon(Icons.add_rounded),
                        ),
                      ),
                  SizedBox(width: sizes.horizontalMargin),
                  IconButton(
                    icon: const Icon(Icons.arrow_right),
                    onPressed:
                        _selectedIndex < _rooms.length
                            ? () => _selectRoom(_selectedIndex + 1)
                            : null,
                    tooltip: 'Siguiente',
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          if (_rooms.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: _addRoom,
              tooltip: 'Crear Lugar',
            ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'logout') {
                await FirebaseAuth.instance.signOut();
                context.go('/login');
              } else if (value == 'profile') {
                context.push('/profile');
              }
            },
            itemBuilder: (BuildContext context) {
              return const [
                PopupMenuItem<String>(
                  value: 'profile',
                  child: Text('Mi Perfil'),
                ),
                PopupMenuItem<String>(
                  value: 'logout',
                  child: Text('Cerrar Sesión'),
                ),
              ];
            },
          ),
        ],
      ),
      body: bodyContent,
    );
  }
}
