//Entidad que representa a un usuario autenticado de forma mínima

class AuthUser {
  final String uid;
  final String email;

  const AuthUser({
    required this.uid,
    required this.email,
  });
}
