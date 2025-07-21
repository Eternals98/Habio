import 'package:per_habit/features/inventary/model/items.dart';

class Inventario {
  List<Mascota> mascotas;
  List<Alimento> alimentos;
  List<Accesorio> accesorios;
  List<Decoracion> decoraciones;
  List<Fondo> fondos;

  Inventario({
    this.mascotas = const [],
    this.alimentos = const [],
    this.accesorios = const [],
    this.decoraciones = const [],
    this.fondos = const [],
  });

  Map<String, dynamic> toMap() => {
    'mascotas': mascotas.map((m) => m.toMap()).toList(),
    'alimentos': alimentos.map((a) => a.toMap()).toList(),
    'accesorios': accesorios.map((a) => a.toMap()).toList(),
    'decoraciones': decoraciones.map((d) => d.toMap()).toList(),
    'fondos': fondos.map((f) => f.toMap()).toList(),
  };
}
