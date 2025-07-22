abstract class Item {
  final String id;
  final String nombre;
  final String descripcion;
  final int cantidad;
  final String icono; // 🆕 Icono (puede ser una URL o un asset path)

  Item({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.icono,
    this.cantidad = 1,
  });
}

class Mascota extends Item {
  Mascota({
    required super.id,
    required super.nombre,
    required super.descripcion,
    required super.icono,
    super.cantidad,
  });
}

class Alimento extends Item {
  Alimento({
    required super.id,
    required super.nombre,
    required super.descripcion,
    required super.icono,
    super.cantidad,
  });
}

class Accesorio extends Item {
  Accesorio({
    required super.id,
    required super.nombre,
    required super.descripcion,
    required super.icono,
    super.cantidad,
  });
}

class Decoracion extends Item {
  Decoracion({
    required super.id,
    required super.nombre,
    required super.descripcion,
    required super.icono,
    super.cantidad,
  });
}

class Fondo extends Item {
  Fondo({
    required super.id,
    required super.nombre,
    required super.descripcion,
    required super.icono,
    super.cantidad,
  });
}
