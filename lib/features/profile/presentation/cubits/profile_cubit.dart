import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rede_social/features/profile/domain/repository/profile_repo.dart';
import 'package:rede_social/features/profile/presentation/cubits/profile_states.dart';
import 'package:rede_social/features/storage/domain/storage_repo.dart';

import '../../domain/entities/profile_user.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepo profileRepo;
  final StorageRepo storageRepo;

  ProfileCubit({required this.profileRepo, required this.storageRepo})
      : super(ProfileInitial());

  // busca o perfil do usuário usando o repo
  Future<void> fetchUserProfile(String uid) async {
    try {
      emit(ProfileLoading());
      final user = await profileRepo.fetchUserProfile(uid);

      if (user != null) {
        emit(ProfileLoaded(user));
      } else {
        emit(ProfileError('Usuário não encontrado'));
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  // retorna perfil do usuário com o uid fornecido
  Future<ProfileUser?> getUserProfile(String uid) async {
    final user = await profileRepo.fetchUserProfile(uid);
    return user;
  }

  // atualiza a bio e/ou a foto de perfil
  Future<void> updateProfile({
    required String uid,
    String? newBio,
    String? imageMobilePath,
    Uint8List? imageWebBytes,
  }) async {
    emit(ProfileLoading());

    try {
      // primeiro busca os dados atuais do perfil
      final currentUser = await profileRepo.fetchUserProfile(uid);

      if (currentUser == null) {
        emit(ProfileError('Falha ao obter os dados atualizados do usuário'));
        return;
      }

      // atualiza foto de perfil
      String? imageDownloadUrl;

      if (imageWebBytes != null || imageMobilePath != null) {
        // para mobile
        if (imageMobilePath != null) {
          imageDownloadUrl =
              await storageRepo.uploadProfileImageMobile(imageMobilePath, uid);

          // para web
        } else if (imageWebBytes != null) {
          imageDownloadUrl =
              await storageRepo.uploadProfileImageWeb(imageWebBytes, uid);
        }
        if (imageDownloadUrl == null) {
          emit(ProfileError('Falha ao enviar imagem'));
          return;
        }
      }

      // atualiza o novo perfil
      final updatedProfile = currentUser.copyWith(
        newBio: newBio ?? currentUser.bio,
        newProfileImageUrl: imageDownloadUrl ?? currentUser.profileImageUrl,
      );

      // atualiza no repo
      await profileRepo.updateProfile(updatedProfile);

      // re-fetch o perfil atualizado
      await fetchUserProfile(uid);
    } catch (e) {
      emit(ProfileError('Erro ao atualizar o perfil: $e'));
    }
  }
}
