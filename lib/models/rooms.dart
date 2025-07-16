import 'package:per_habit/models/mascotaHabito.dart';
import 'package:per_habit/models/user_model.dart';

class Lugar {
  final String id;
  String nombre;
  List<MascotaHabito> mascotas;
  List<UserModel> owners;

  Lugar({
    required this.id,
    required this.nombre,
    this.mascotas = const [],
    this.owners = const [],
  });
}
