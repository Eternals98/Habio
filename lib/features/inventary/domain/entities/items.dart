abstract class Item {
  final String id;
  final String nombre;
  final int cantidad;

  Item({required this.id, required this.nombre, this.cantidad = 1});
}

class Mascota extends Item {
  Mascota({required super.id, required super.nombre, super.cantidad});
}

class Alimento extends Item {
  Alimento({required super.id, required super.nombre, super.cantidad});
}

class Accesorio extends Item {
  Accesorio({required super.id, required super.nombre, super.cantidad});
}

class Decoracion extends Item {
  Decoracion({required super.id, required super.nombre, super.cantidad});
}

class Fondo extends Item {
  Fondo({required super.id, required super.nombre, super.cantidad});
}
