import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rede_social/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:rede_social/features/home/presentation/components/my_drawer_tile.dart';
import 'package:rede_social/features/profile/presentation/pages/profile_page.dart';
import 'package:rede_social/features/search/presentation/pages/search_page.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(
            children: [
              // TODO: implementar logo aqui
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 50.0),
                child: Icon(
                  Icons.person,
                  size: 80,
                ),
              ),
              Divider(
                color: Theme.of(context).colorScheme.secondary,
              ),
              MyDrawerTile(
                title: 'INÍCIO',
                icon: Icons.home,
                onTap: () => Navigator.of(context).pop(),
              ),
              MyDrawerTile(
                title: 'PERFIL',
                icon: Icons.person,
                onTap: () {
                  Navigator.of(context).pop();
                  // recupera o usuário atual
                  final user = context.read<AuthCubit>().currentUser;
                  String? uid = user!.uid;

                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ProfilePage(
                                uid: uid,
                              )));
                },
              ),
              MyDrawerTile(
                title: 'BUSCAR',
                icon: Icons.search,
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SearchPage())),
              ),
              MyDrawerTile(
                title: 'CONFIGURAÇÕES',
                icon: Icons.settings,
                onTap: () {},
              ),
              const Spacer(),
              MyDrawerTile(
                title: 'SAIR',
                icon: Icons.logout,
                onTap: () => context.read<AuthCubit>().logout(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
