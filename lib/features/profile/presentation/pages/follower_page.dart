import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rede_social/features/profile/presentation/components/user_tile.dart';
import 'package:rede_social/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:rede_social/responsive/constrained_scaffold.dart';

class FollowerPage extends StatelessWidget {
  final List<String> followers;
  final List<String> following;

  const FollowerPage({
    super.key,
    required this.followers,
    required this.following,
  });

  @override
  Widget build(BuildContext context) {
    // tab controller
    return DefaultTabController(
        length: 2,

        // scaffold
        child: ConstrainedScaffold(
          // app bar
          appBar: AppBar(
            bottom: TabBar(
                dividerColor: Colors.transparent,
                labelColor: Theme.of(context).colorScheme.inversePrimary,
                unselectedLabelColor: Theme.of(context).colorScheme.primary,
                tabs: const [
                  Tab(text: 'Seguidores'),
                  Tab(text: 'Seguindo'),
                ]),
          ),

          // tab bar view
          body: TabBarView(children: [
            _buildUserList(followers, 'Sem seguidores', context),
            _buildUserList(following, 'Sem usuários seguidos', context)
          ]),
        ));
  }

// construir lista de usuários
  Widget _buildUserList(
      List<String> uids, String emptyMessage, BuildContext context) {
    return uids.isEmpty
        ? Center(child: Text(emptyMessage))
        : ListView.builder(
            itemCount: uids.length,
            itemBuilder: (context, index) {
              // obter cada uid
              final uid = uids[index];

              return FutureBuilder(
                future: context.read<ProfileCubit>().getUserProfile(uid),
                builder: (context, snapshot) {
                  // usuário carregado
                  if (snapshot.hasData) {
                    final user = snapshot.data!;
                    return UserTile(user: user);
                  }
                  // carregando
                  else if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const ListTile(
                      title: Text('Carregando..'),
                    );
                  }
                  // não encontrado
                  else {
                    return const ListTile(
                      title: Text('Usuário não encontrado..'),
                    );
                  }
                },
              );
            });
  }
}
