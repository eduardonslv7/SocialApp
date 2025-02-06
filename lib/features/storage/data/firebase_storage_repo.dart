import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:rede_social/features/storage/domain/storage_repo.dart';

class FirebaseStorageRepo implements StorageRepo {
  final FirebaseStorage storage = FirebaseStorage.instance;

  // FOTOS DE PERFIL - enviar para o storage

  @override
  Future<String?> uploadProfileImageMobile(String path, String fileName) {
    return _uploadFile(path, fileName, "profile_images");
  }

  @override
  Future<String?> uploadProfileImageWeb(Uint8List fileBytes, String fileName) {
    return _uploadFileBytes(fileBytes, fileName, "profile_images");
  }

  // IMAGENS DE POSTS - enviar para o storage

  @override
  Future<String?> uploadPostImageMobile(String path, String fileName) {
    return _uploadFile(path, fileName, "post_images");
  }

  @override
  Future<String?> uploadPostImageWeb(Uint8List fileBytes, String fileName) {
    return _uploadFileBytes(fileBytes, fileName, "post_images");
  }

  // plataformas mobile (file)
  Future<String?> _uploadFile(
      String path, String fileName, String folder) async {
    try {
      // obter o arquivo
      final file = File(path);

      // obter local de armazenamento
      final storageRef = storage.ref().child('$folder/$fileName');

      // upload
      final uploadTask = await storageRef.putFile(file);

      // obter url do download da imagem
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      return null;
    }
  }

  // plataformas web (bytes)
  Future<String?> _uploadFileBytes(
      Uint8List fileBytes, String fileName, String folder) async {
    try {
      // obter local de armazenamento
      final storageRef = storage.ref().child('$folder/$fileName');

      // upload
      final uploadTask = await storageRef.putData(fileBytes);

      // obter url do download da imagem
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      return null;
    }
  }
}
