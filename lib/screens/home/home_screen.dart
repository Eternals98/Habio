// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:per_habit/data/lugar_service.dart';
import 'package:per_habit/models/room_model.dart';
import 'package:per_habit/routes/app_routes.dart';
import 'package:per_habit/screens/room/room_detail.dart';
import 'package:per_habit/utils/sizes.dart';
import 'package:per_habit/widgets/room_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Lugar> _lugares = [];
  int _selectedIndex = -1;
  final ScrollController _scrollController = ScrollController();
  final LugarService _lugarService = LugarService();
  final user = FirebaseAuth.instance.currentUser;

  static const _desktopBreakpoint = 800.0;
  static const _desktopWidthRatio = 0.25;
  static const _mobileWidthRatio = 0.60;
  static const _desktopMarginRatio = 0.015;
  static const _mobileMarginRatio = 0.02;
  static const _minContainerWidth = 150.0;
  static const _maxContainerWidth = 250.0;

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

  void _scrollToSelected(int index) {
    if (!_scrollController.hasClients ||
        index < 0 ||
        index >= _lugares.length) {
      return;
    }

    final sizes = _calculateSizes(MediaQuery.of(context).size.width);
    final itemWidthWithMargin =
        sizes.containerWidth + (sizes.horizontalMargin * 2);

    double targetOffset =
        (index * itemWidthWithMargin) +
        (itemWidthWithMargin / 2) -
        (MediaQuery.of(context).size.width / 2) +
        sizes.padding;

    targetOffset = targetOffset.clamp(
      _scrollController.position.minScrollExtent,
      _scrollController.position.maxScrollExtent,
    );

    _scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _selectLugar(int index) {
    if (_selectedIndex == index) return;
    setState(() {
      _selectedIndex = index;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _scrollToSelected(index);
      }
    });
  }

  void _navigateToLugarDetalle(Lugar lugar) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => LugarDetalleScreen(
              lugar: lugar,
              lugares: _lugares,
              setState: setState,
              selectedIndex: _selectedIndex,
              scrollToSelected: _scrollToSelected,
            ),
      ),
    );
  }

  void _addLugar() {
    _lugarService.addLugar(
      context: context,
      lugares: _lugares,
      setState: setState,
      scrollToSelected: (index) {
        _selectedIndex = index;
        _scrollToSelected(index);
      },
    );
  }

  void _updateLugar(Lugar lugar) {
    _lugarService.updateLugar(
      context: context,
      lugar: lugar,
      lugares: _lugares,
      setState: setState,
      selectedIndex: _selectedIndex,
      scrollToSelected: _scrollToSelected,
    );
  }

  void _deleteLugar(Lugar lugar) {
    _lugarService.deleteLugar(
      context: context,
      lugar: lugar,
      lugares: _lugares,
      setState: setState,
      selectedIndex: _selectedIndex,
      scrollToSelected: (index) {
        setState(() {
          _selectedIndex = index;
        });
        _scrollToSelected(index);
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final sizes = _calculateSizes(screenWidth);
    Widget bodyContent;

    if (_lugares.isEmpty) {
      bodyContent = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Hola ${user?.email ?? 'usuario'} 👋",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            const Text('¡Crea tu primer lugar para empezar!'),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.add_circle_outline_rounded),
              label: const Text("Crear Lugar"),
              onPressed: _addLugar,
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
          SizedBox(
            height: sizes.containerHeight + 20,
            child: Scrollbar(
              controller: _scrollController,
              thumbVisibility: true,
              trackVisibility: true,
              child: ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.symmetric(horizontal: sizes.padding),
                scrollDirection: Axis.horizontal,
                itemCount: _lugares.length + 1,
                itemBuilder: (context, index) {
                  if (index == _lugares.length) {
                    return Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: sizes.horizontalMargin,
                        vertical: 10,
                      ),
                      child: InkWell(
                        onTap: _addLugar,
                        child: Container(
                          width: sizes.containerWidth * 0.6,
                          height: sizes.containerHeight,
                          decoration: BoxDecoration(
                            border: Border.all(width: 2),
                          ),
                          child: const Icon(Icons.add_rounded),
                        ),
                      ),
                    );
                  }

                  final lugar = _lugares[index];
                  return LugarCard(
                    lugar: lugar,
                    width: sizes.containerWidth,
                    height: sizes.containerHeight,
                    margin: sizes.horizontalMargin,
                    isSelected: _selectedIndex == index,
                    onTap: () => _selectLugar(index),
                    onAbrir: () => _navigateToLugarDetalle(lugar),
                    onEdit: () => _updateLugar(lugar),
                    onDelete: () => _deleteLugar(lugar),
                  );
                },
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
          if (_lugares.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: _addLugar,
              tooltip: 'Crear Lugar',
            ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'logout') {
                await FirebaseAuth.instance.signOut();
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
              }
              // Aquí podrías agregar más opciones de menú
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
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
