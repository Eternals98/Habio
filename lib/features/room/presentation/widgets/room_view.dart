import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:per_habit/features/room/domain/entities/room.dart';

class RoomView extends StatelessWidget {
  final Room room;
  final List<Widget>
  children; // Widgets que van "dentro" de la habitación (mascotas, decoraciones, etc.)

  const RoomView({super.key, required this.room, this.children = const []});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1, // puedes cambiar según la proporción real de tu SVG
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Fondo visual de la habitación (SVG)
          SvgPicture.asset(
            'assets/images/room_icons/room_base.svg',
            fit: BoxFit.cover,
          ),

          // Elementos superpuestos (mascotas, ítems, decoraciones)
          ...children,
        ],
      ),
    );
  }
}
