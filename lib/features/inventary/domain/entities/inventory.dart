import 'package:per_habit/features/inventary/domain/entities/items.dart';

class Inventario {
  final String userId;
  final List<Mascota> mascotas;
  final List<Alimento> alimentos;
  final List<Accesorio> accesorios;
  final List<Decoracion> decoraciones;
  final List<Fondo> fondos;

  Inventario({
    required this.userId,
    this.mascotas = const [],
    this.alimentos = const [],
    this.accesorios = const [],
    this.decoraciones = const [],
    this.fondos = const [],
  });
}
