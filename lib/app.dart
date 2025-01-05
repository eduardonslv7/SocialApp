import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rede_social/features/auth/data/firebase_auth_repo.dart';
import 'package:rede_social/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:rede_social/features/auth/presentation/cubits/auth_states.dart';
import 'package:rede_social/features/auth/presentation/pages/auth_page.dart';
import 'package:rede_social/features/home/presentation/pages/home_page.dart';
import 'package:rede_social/features/profile/data/firebase_profile_repo.dart';
import 'package:rede_social/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:rede_social/features/storage/data/firebase_storage_repo.dart';
import 'package:rede_social/themes/light_mode.dart';

class MyApp extends StatelessWidget {
  // auth repo
  final firebaseAuthRepo = FirebaseAuthRepo();

  // profile repo
  final firebaseProfileRepo = FirebaseProfileRepo();

  // storage repo
  final firebaseStorageRepo = FirebaseStorageRepo();

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // fornece cubits para o app
    return MultiBlocProvider(
      providers: [
        // auth cubit
        BlocProvider<AuthCubit>(
          create: (context) =>
              AuthCubit(authRepo: firebaseAuthRepo)..checkAuth(),
        ),

        // profile cubit
        BlocProvider<ProfileCubit>(
          create: (context) => ProfileCubit(
            profileRepo: firebaseProfileRepo,
            storageRepo: firebaseStorageRepo,
          ),
        ),
      ],
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
