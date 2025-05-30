import 'dart:typed_data';

abstract class StorageRepo {
  // enviar fotos de perfil em plataformas mobile
  Future<String?> uploadProfileImageMobile(String path, String fileName);

  // enviar fotos de perfil em plataformas web
  Future<String?> uploadProfileImageWeb(Uint8List fileBytes, String fileName);

  // enviar posts em plataformas mobile
  Future<String?> uploadPostImageMobile(String path, String fileName);

  // enviar posts em plataformas web
  Future<String?> uploadPostImageWeb(Uint8List fileBytes, String fileName);
}
