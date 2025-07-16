import 'package:flutter/material.dart';
import 'package:per_habit/models/rooms.dart';

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
          border: isSelected ? Border.all(width: 3) : Border.all(width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              lugar.nombre,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Icon(Icons.category_rounded),
            ElevatedButton(onPressed: onAbrir, child: const Text("Abrir")),
          ],
        ),
      ),
    );
  }
}
