// © 2025 Javier Gómez. All rights reserved.
// This file is part of the proprietary Habio application.
// Unauthorized use or distribution is prohibited.

import 'package:flutter/material.dart';
import 'dart:math' as math; // Para el UniqueKey y colores aleatorios
import 'screens/login_screen.dart';

// --- Modelo de Datos ---
class Lugar {
  final String id;
  String nombre;
  Color color; // Para diferenciar visualmente los lugares
  List<MascotaHabito> mascotas; // Para el futuro

  Lugar({
    required this.id,
    required this.nombre,
    required this.color,
    this.mascotas = const [],
  });
}

// Modelo básico para mascotas (a expandir en el futuro)
class MascotaHabito {
  final String id;
  String nombre;
  // ... más propiedades

  MascotaHabito({required this.id, required this.nombre});
}

// --- App Principal ---
void main() {
  runApp(const HabitPetApp());
}

class HabitPetApp extends StatelessWidget {
  const HabitPetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HabitPet',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor:
            Colors.green[100], // Un verde más claro para el fondo general
        fontFamily:
            'RoundedMplus', // Ejemplo, asegúrate de añadir la fuente a pubspec.yaml y assets
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[600],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.green[700],
          elevation: 0,
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            fontFamily: 'RoundedMplus',
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        textTheme: TextTheme(
          // Tipografía más amigable
          bodyLarge: TextStyle(color: Colors.grey[800], fontSize: 16),
          titleLarge: TextStyle(
            color: Colors.green[800],
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          // Para los TextField al crear lugares
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.green[700]!, width: 2),
          ),
          labelStyle: TextStyle(color: Colors.green[700]),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}

// --- Pantalla Principal (HomeScreen) ---
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Lugar> _lugares = [];
  int _selectedIndex = -1;
  final ScrollController _scrollController = ScrollController();

  // Constantes para el cálculo de tamaños
  static const _desktopBreakpoint = 800.0;
  static const _desktopWidthRatio = 0.25;
  static const _mobileWidthRatio = 0.60;
  static const _desktopMarginRatio = 0.015;
  static const _mobileMarginRatio = 0.02;
  static const _minContainerWidth = 150.0;
  static const _maxContainerWidth = 250.0;

  _Sizes _calculateSizes(double screenWidth) {
    final isDesktop = screenWidth > _desktopBreakpoint;
    final containerWidth = (isDesktop
            ? screenWidth * _desktopWidthRatio
            : screenWidth * _mobileWidthRatio)
        .clamp(_minContainerWidth, _maxContainerWidth);
    final containerHeight = containerWidth * 1.2;
    final horizontalMargin =
        screenWidth * (isDesktop ? _desktopMarginRatio : _mobileMarginRatio);
    final listViewPadding = screenWidth * 0.05;
    return _Sizes(
      containerWidth: containerWidth,
      containerHeight: containerHeight,
      horizontalMargin: horizontalMargin,
      padding: listViewPadding,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose(); // Siempre hacer dispose de los controllers
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
          color: Color(
            (math.Random().nextDouble() * 0xFFFFFF).toInt(),
          ).withOpacity(1.0),
        );
        _lugares.add(nuevoLugar);
        _selectedIndex = _lugares.length - 1;
      });
      // CORRECCIÓN: Llamar a _scrollToSelected después de que el frame se haya construido
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          // Asegurarse que el widget todavía está en el árbol
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
    // CORRECCIÓN: Llamar a _scrollToSelected después de que el frame se haya construido
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _scrollToSelected(index);
      }
    });
  }

  void _scrollToSelected(int index) {
    // CORRECCIÓN: Verificar si el controller está adjunto
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

    // Asegurarse de que el offset está dentro de los límites del scroll
    // Acceder a .position solo después de verificar .hasClients
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
            Text(
              "¡Crea tu primer lugar para empezar!",
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: Colors.green[700]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.add_circle_outline_rounded),
              label: const Text("Crear Lugar"),
              onPressed: _addLugar,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
                textStyle: const TextStyle(fontSize: 18),
              ),
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
              controller:
                  _scrollController, // Asegúrate de que el controller se pasa aquí
              thumbVisibility: true,
              trackVisibility: true,
              thickness: 8.0,
              radius: const Radius.circular(4.0),
              child: ListView.builder(
                controller: _scrollController, // Y aquí también
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
                        borderRadius: BorderRadius.circular(25),
                        child: Container(
                          width: sizes.containerWidth * 0.6,
                          height: sizes.containerHeight,
                          decoration: BoxDecoration(
                            color: Colors.green[300]?.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: Colors.green[600]!,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            Icons.add_rounded,
                            size: sizes.containerWidth * 0.3,
                            color: Colors.green[700],
                          ),
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
        title: const Text("HabitPet Lugares"),
        actions: [
          if (_lugares.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              tooltip: "Crear Nuevo Lugar",
              onPressed: _addLugar,
            ),
          IconButton(
            onPressed: () {
              /* Lógica de logout futura */
            },
            icon: const Icon(Icons.logout),
            tooltip: "Cerrar Sesión",
          ),
        ],
      ),
      body: bodyContent,
    );
  }
}

// --- Widget para cada Lugar (Contenedor Personalizado) ---
class LugarCard extends StatelessWidget {
  final Lugar lugar;
  final double width;
  final double height;
  final double margin;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onAbrir;

  const LugarCard({
    required this.lugar,
    required this.width,
    required this.height,
    required this.margin,
    required this.isSelected,
    required this.onTap,
    required this.onAbrir,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        margin: EdgeInsets.symmetric(horizontal: margin, vertical: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: lugar.color.withOpacity(0.8),
          borderRadius: BorderRadius.circular(25),
          border:
              isSelected
                  ? Border.all(color: Colors.yellowAccent, width: 3)
                  : Border.all(
                    color: lugar.color.withGreen(
                      (lugar.color.green * 0.7).toInt(),
                    ),
                    width: 1.5,
                  ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isSelected ? 0.25 : 0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              lugar.nombre,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: width * 0.12,
                fontWeight: FontWeight.bold,
                color: Colors.white.withOpacity(0.9),
                shadows: const [
                  Shadow(
                    blurRadius: 1,
                    color: Colors.black26,
                    offset: Offset(1, 1),
                  ),
                ],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Icon(
              Icons.category_rounded,
              size: width * 0.25,
              color: Colors.white.withOpacity(0.7),
            ),
            ElevatedButton.icon(
              label: const Text("Abrir"),
              onPressed: onAbrir,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withValues(),
                foregroundColor: lugar.color
                    .withRed((lugar.color.red * 0.7).toInt())
                    .withBlue((lugar.color.blue * 0.7).toInt()),
                padding: EdgeInsets.symmetric(
                  horizontal: width * 0.1,
                  vertical: height * 0.05,
                ),
                textStyle: TextStyle(
                  fontSize: width * 0.07,
                  fontWeight: FontWeight.bold,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Estructura para los tamaños calculados ---
class _Sizes {
  final double containerWidth;
  final double containerHeight;
  final double horizontalMargin;
  final double padding;

  _Sizes({
    required this.containerWidth,
    required this.containerHeight,
    required this.horizontalMargin,
    required this.padding,
  });
}

// --- Pantalla de Detalle del Lugar (Placeholder) ---
class LugarDetalleScreen extends StatelessWidget {
  final Lugar lugar;

  const LugarDetalleScreen({super.key, required this.lugar});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(lugar.nombre), backgroundColor: lugar.color),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: 'lugar_icon_${lugar.id}',
              child: Icon(
                Icons.category_rounded,
                size: 100,
                color: lugar.color,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Detalles de "${lugar.nombre}"',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            Text(
              'Aquí se mostrarán las mascotas (hábitos) de este lugar.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
