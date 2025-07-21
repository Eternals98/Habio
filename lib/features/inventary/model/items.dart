abstract class Item {
  String id;
  String nombre;
  int cantidad;

  Item({required this.id, required this.nombre, this.cantidad = 1});

  Map<String, dynamic> toMap();
}

class Mascota extends Item {
  Mascota({required super.id, required super.nombre, super.cantidad});

  @override
  Map<String, dynamic> toMap() => {
    'id': id,
    'nombre': nombre,
    'cantidad': cantidad,
  };
}

class Alimento extends Item {
  Alimento({required super.id, required super.nombre, super.cantidad});

  @override
  Map<String, dynamic> toMap() => {
    'id': id,
    'nombre': nombre,
    'cantidad': cantidad,
  };
}

class Accesorio extends Item {
  Accesorio({required super.id, required super.nombre, super.cantidad});

  @override
  Map<String, dynamic> toMap() => {
    'id': id,
    'nombre': nombre,
    'cantidad': cantidad,
  };
}

class Decoracion extends Item {
  Decoracion({required super.id, required super.nombre, super.cantidad});

  @override
  Map<String, dynamic> toMap() => {
    'id': id,
    'nombre': nombre,
    'cantidad': cantidad,
  };
}

class Fondo extends Item {
  Fondo({required super.id, required super.nombre, super.cantidad});

  @override
  Map<String, dynamic> toMap() => {
    'id': id,
    'nombre': nombre,
    'cantidad': cantidad,
  };
}
