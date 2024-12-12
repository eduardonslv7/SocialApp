import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rede_social/features/profile/domain/repository/profile_repo.dart';
import 'package:rede_social/features/profile/presentation/cubits/profile_states.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepo profileRepo;

  ProfileCubit({required this.profileRepo}) : super(ProfileInitial());

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

  // atualiza a bio e/ou a foto de perfil

  Future<void> updateProfile({required String uid, String? newBio}) async {
    emit(ProfileLoading());

    try {
      // primeiro busca os dados atuais do perfil
      final currentUser = await profileRepo.fetchUserProfile(uid);

      if (currentUser == null) {
        emit(ProfileError('Falha ao obter os dados atualizados do usuário'));
        return;
      }

      // atualiza foto de perfil

      // atualiza o novo perfil
      final updatedProfile =
          currentUser.copyWith(newBio: newBio ?? currentUser.bio);

      // atualiza no repo
      await profileRepo.updateProfile(updatedProfile);

      // re-fetch o perfil atualizado
      await fetchUserProfile(uid);
    } catch (e) {
      emit(ProfileError('Erro ao atualizar o perfil: $e'));
    }
  }
}
