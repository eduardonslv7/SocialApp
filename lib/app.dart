import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rede_social/features/auth/data/firebase_auth_repo.dart';
import 'package:rede_social/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:rede_social/features/auth/presentation/cubits/auth_states.dart';
import 'package:rede_social/features/auth/presentation/pages/auth_page.dart';
import 'package:rede_social/features/post/presentation/pages/home_page.dart';
import 'package:rede_social/themes/light_mode.dart';

class MyApp extends StatelessWidget {
  // auth repo
  final authRepo = FirebaseAuthRepo();
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // fornece cubit para o app
    return BlocProvider(
      create: (context) => AuthCubit(authRepo: authRepo)..checkAuth(),
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: lightMode,
          home: BlocConsumer<AuthCubit, AuthState>(
            builder: (context, authState) {
              print(authState);
              // não autenticado => página de autenticação (login/registrar)
              if (authState is Unauthenticated) {
                return const AuthPage();
              }

              // autenticado => home page
              if (authState is Authenticated) {
                return const HomePage();
              }

              // carregando
              else {
                return const Scaffold(
                    body: Center(
                  child: CircularProgressIndicator(),
                ));
              }
            },

            // para erros
            listener: (context, state) {
              if (state is AuthError) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(state.message)));
              }
            },
          )),
    );
  }
}
