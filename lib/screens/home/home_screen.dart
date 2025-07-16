import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:per_habit/models/rooms.dart';
import 'package:per_habit/screens/room/room_detail.dart';
import 'package:per_habit/utils/sizes.dart';
import 'package:per_habit/widgets/room_card.dart';
import '../../routes/app_routes.dart'; // Ensure this is correct for your routes

// --- HomeScreen ---
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Lugar> _lugares = [];
  int _selectedIndex = -1;
  final ScrollController _scrollController = ScrollController();

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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _addLugar() async {
    final String? nombreLugar = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        TextEditingController controller = TextEditingController();
        return AlertDialog(
          title: const Text('Crear Nuevo Lugar'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: "Nombre del lugar (Ej: Estudio)",
            ),
            autofocus: true,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text('Crear'),
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  Navigator.of(context).pop(controller.text.trim());
                }
              },
            ),
          ],
        );
      },
    );

    if (nombreLugar != null && nombreLugar.isNotEmpty) {
      setState(() {
        final nuevoLugar = Lugar(
          id: UniqueKey().toString(),
          nombre: nombreLugar,
        );
        _lugares.add(nuevoLugar);
        _selectedIndex = _lugares.length - 1;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _scrollToSelected(_selectedIndex);
        }
      });
    }
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

  void _navigateToLugarDetalle(Lugar lugar) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LugarDetalleScreen(lugar: lugar)),
    );
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
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
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, AppRoutes.login);
            },
          ),
        ],
      ),
      body: bodyContent,
    );
  }
}
