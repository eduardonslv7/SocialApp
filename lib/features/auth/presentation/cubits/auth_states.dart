import 'package:rede_social/features/auth/domain/entities/app_user.dart';

abstract class AuthState {}

// estado inicial
class AuthInitial extends AuthState {}

// carregando
class AuthLoading extends AuthState {}

// autenticado
class Authenticated extends AuthState {
  final AppUser user;
  Authenticated(this.user);
}

// não autenticado
class Unauthenticated extends AuthState {}

// erros
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}
