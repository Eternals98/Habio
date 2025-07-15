import 'package:per_habit/models/mascotaHabito.dart';

class Lugar {
  final String id;
  String nombre;
  List<MascotaHabito> mascotas;

  Lugar({required this.id, required this.nombre, this.mascotas = const []});
}
