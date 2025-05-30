import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rede_social/features/auth/data/firebase_auth_repo.dart';
import 'package:rede_social/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:rede_social/features/auth/presentation/cubits/auth_states.dart';
import 'package:rede_social/features/auth/presentation/pages/auth_page.dart';
import 'package:rede_social/features/home/presentation/pages/home_page.dart';
import 'package:rede_social/features/post/data/firebase_post_repo.dart';
import 'package:rede_social/features/post/presentation/cubits/post_cubit.dart';
import 'package:rede_social/features/profile/data/firebase_profile_repo.dart';
import 'package:rede_social/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:rede_social/features/search/data/firebase_search_repo.dart';
import 'package:rede_social/features/search/presentation/cubits/search_cubit.dart';
import 'package:rede_social/features/storage/data/firebase_storage_repo.dart';
import 'package:rede_social/themes/theme_cubit.dart';

class MyApp extends StatelessWidget {
  // auth repo
  final firebaseAuthRepo = FirebaseAuthRepo();

  // profile repo
  final firebaseProfileRepo = FirebaseProfileRepo();

  // storage repo
  final firebaseStorageRepo = FirebaseStorageRepo();

  // post repo
  final firebasePostRepo = FirebasePostRepo();

  // search repo
  final firebaseSearchRepo = FirebaseSearchRepo();

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

          // post cubit
          BlocProvider<PostCubit>(
              create: (context) => PostCubit(
                    postRepo: firebasePostRepo,
                    storageRepo: firebaseStorageRepo,
                  )),

          // search cubit
          BlocProvider<SearchCubit>(
            create: (context) => SearchCubit(searchRepo: firebaseSearchRepo),
          ),

          // theme cubit
          BlocProvider<ThemeCubit>(create: (context) => ThemeCubit()),
        ],

        // bloc builder: temas
        child: BlocBuilder<ThemeCubit, ThemeData>(
          builder: (context, currentTheme) => MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: currentTheme,

              // bloc builder: verificar o auth state atual
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
        ));
  }
}
