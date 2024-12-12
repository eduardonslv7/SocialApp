import 'package:rede_social/features/profile/domain/entities/profile_user.dart';

abstract class ProfileState {}

// estado inicial
class ProfileInitial extends ProfileState {}

// carregando
class ProfileLoading extends ProfileState {}

// carregado
class ProfileLoaded extends ProfileState {
  final ProfileUser profileUser;
  ProfileLoaded(this.profileUser);
}

// erros
class ProfileError extends ProfileState {
  final String message;
  ProfileError(this.message);
}
