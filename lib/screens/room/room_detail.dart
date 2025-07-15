import 'package:flutter/material.dart';
import 'package:per_habit/models/rooms.dart';

class LugarDetalleScreen extends StatelessWidget {
  final Lugar lugar;

  const LugarDetalleScreen({super.key, required this.lugar});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(lugar.nombre)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.category_rounded, size: 100),
            const SizedBox(height: 20),
            Text('Detalles de "${lugar.nombre}"'),
            const SizedBox(height: 20),
            const Text(
              'Aquí se mostrarán las mascotas (hábitos) de este lugar.',
            ),
          ],
        ),
      ),
    );
  }
}
