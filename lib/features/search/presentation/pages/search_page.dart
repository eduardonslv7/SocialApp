import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rede_social/features/profile/presentation/components/user_tile.dart';
import 'package:rede_social/features/search/presentation/cubits/search_cubit.dart';
import 'package:rede_social/features/search/presentation/cubits/search_states.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController searchController = TextEditingController();
  late final searchCubit = context.read<SearchCubit>();

  void onSearchChanged() {
    final query = searchController.text;
    searchCubit.searchUsers(query);
  }

  @override
  void initState() {
    super.initState();
    searchController.addListener(onSearchChanged);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: TextField(
          controller: searchController,
          decoration: InputDecoration(
              hintText: 'Buscar usuários..',
              hintStyle:
                  TextStyle(color: Theme.of(context).colorScheme.primary)),
        )),

        // resultados da busca
        body: BlocBuilder<SearchCubit, SearchState>(builder: (context, state) {
          // carregado
          if (state is SearchLoaded) {
            // sem usuários encontrados
            if (state.users.isEmpty) {
              return const Center(
                child: Text('Nenhum usuário encontrado'),
              );
            }

            // usuários encontrados
            return ListView.builder(
              itemCount: state.users.length,
              itemBuilder: (context, index) {
                final user = state.users[index];
                return UserTile(user: user!);
              },
            );
          }

          // carregando
          else if (state is SearchLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // erros
          else if (state is SearchError) {
            return Center(
              child: Text(state.message),
            );
          }
          // padrão
          return const Center(
            child: Text('Comece a buscar por usuários..'),
          );
        }));
  }
}
