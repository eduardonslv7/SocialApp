import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rede_social/features/home/presentation/components/my_drawer.dart';
import 'package:rede_social/features/post/presentation/components/post_tile.dart';
import 'package:rede_social/features/post/presentation/cubits/post_cubit.dart';
import 'package:rede_social/features/post/presentation/cubits/post_states.dart';
import '../../../post/presentation/pages/upload_post_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // post cubit
  late final postCubit = context.read<PostCubit>();

  // ao iniciar:
  @override
  void initState() {
    super.initState();

    // buscar todas as postagens
    fetchAllPosts();
  }

  void fetchAllPosts() {
    postCubit.fetchAllPosts();
  }

  void deletePost(String postId) {
    postCubit.deletePost(postId);
    fetchAllPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Início'),
        foregroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UploadPostPage(),
                  )),
              icon: const Icon(
                Icons.add,
              )),
        ],
        centerTitle: true,
      ),
      drawer: const MyDrawer(),
      body: BlocBuilder<PostCubit, PostState>(builder: (context, state) {
        // carregando
        if (state is PostsLoading && state is PostsUploading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (state is PostsLoaded) {
          final allPosts = state.posts;

          if (allPosts.isEmpty) {
            return const Center(
              child: Text('Sem postagens disponíveis'),
            );
          }
          return ListView.builder(
            itemCount: allPosts.length,
            itemBuilder: (context, index) {
              final post = allPosts[index];

              // imagem
              return PostTile(
                post: post,
                onDeletePressed: () => deletePost(post.id),
              );
            },
          );
        }

        // erros

        else if (state is PostsError) {
          return Center(child: Text(state.message));
        } else {
          return const SizedBox();
        }
      }),
    );
  }
}
