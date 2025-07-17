import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = const Uuid();

  /// Sube una imagen al path especificado y devuelve la URL pública de descarga.
  Future<String> uploadHabitImage({
    required String userId,
    required String roomId,
    required String habitId,
    required File imageFile,
  }) async {
    try {
      final String fileName = 'habit_${_uuid.v4()}.jpg';
      final String storagePath = 'users/$userId/rooms/$roomId/habits/$habitId/$fileName';

      final ref = _storage.ref().child(storagePath);
      final uploadTask = await ref.putFile(imageFile);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('Error al subir la imagen: $e');
    }
  }

  /// Borra una imagen de Firebase Storage dado su path
  Future<void> deleteImageByUrl(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      throw Exception('Error al eliminar imagen: $e');
    }
  }
}
