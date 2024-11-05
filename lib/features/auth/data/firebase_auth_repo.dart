import 'package:firebase_auth/firebase_auth.dart';
import 'package:rede_social/features/auth/domain/entities/app_user.dart';
import 'package:rede_social/features/auth/domain/repository/auth_repo.dart';

class FirebaseAuthRepo implements AuthRepo {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  @override
  Future<AppUser?> loginWithEmailPassword(String email, String password) async {
    try {
      // tentar logar
      UserCredential userCredential = await firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      // criar usuário
      AppUser user = AppUser(
        uid: userCredential.user!.uid,
        email: email,
        name: '',
      );

      // retornar usuário
      return user;
    }
    // capturar erros
    catch (e) {
      throw Exception('Login falhou: $e');
    }
  }

  @override
  Future<AppUser?> registerWithEmailPassword(
      String name, String email, String password) async {
    try {
      // tentar cadastrar
      UserCredential userCredential = await firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      // criar usuário
      AppUser user = AppUser(
        uid: userCredential.user!.uid,
        email: email,
        name: name,
      );

      // retornar usuário
      return user;
    }
    // capturar erros
    catch (e) {
      throw Exception('Login falhou: $e');
    }
  }

  @override
  Future<void> logout() async {
    await firebaseAuth.signOut();
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    // identificar o usuário atualmente logado do firebase
    final firebaseUser = firebaseAuth.currentUser;

    // nenhum usuário logado
    if (firebaseUser == null) {
      return null;
    }

    // algum usuário logado
    return AppUser(
      uid: firebaseUser.uid,
      email: firebaseUser.email!,
      name: '',
    );
  }
}
