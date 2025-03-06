import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rede_social/features/auth/domain/entities/app_user.dart';
import 'package:rede_social/features/auth/presentation/components/my_text_field.dart';
import 'package:rede_social/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:rede_social/features/post/domain/entities/comment.dart';
import 'package:rede_social/features/post/domain/entities/post.dart';
import 'package:rede_social/features/post/presentation/components/comment_tile.dart';
import 'package:rede_social/features/post/presentation/cubits/post_cubit.dart';
import 'package:rede_social/features/post/presentation/cubits/post_states.dart';
import 'package:rede_social/features/profile/domain/entities/profile_user.dart';
import 'package:rede_social/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:rede_social/features/profile/presentation/pages/profile_page.dart';

class PostTile extends StatefulWidget {
  final Post post;
  final void Function()? onDeletePressed;
  const PostTile({
    super.key,
    required this.post,
    required this.onDeletePressed,
  });

  @override
  State<PostTile> createState() => _PostTileState();
}

class _PostTileState extends State<PostTile> {
  // cubits
  late final postCubit = context.read<PostCubit>();
  late final profileCubit = context.read<ProfileCubit>();

  bool isOwnPost = false;

  // usuário atual
  AppUser? currentUser;

  // post do usuário
  ProfileUser? postUser;

  // ao iniciar
  @override
  void initState() {
    super.initState();

    getCurrentUser();
    fetchPostUser();
  }

  void getCurrentUser() {
    final authCubit = context.read<AuthCubit>();
    currentUser = authCubit.currentUser;
    isOwnPost = (widget.post.userId == currentUser!.uid);
  }

  Future<void> fetchPostUser() async {
    final fetchedUser = await profileCubit.getUserProfile(widget.post.userId);
    if (fetchedUser != null) {
      setState(() {
        postUser = fetchedUser;
      });
    }
  }

  // usuário aperta o botão de curtir
  void toggleLikePost() {
    // estado atual da curtida
    final isLiked = widget.post.likes.contains(currentUser!.uid);

    // aplicar curtida instantaneamente e atualizar a UI
    setState(() {
      if (isLiked) {
        widget.post.likes.remove(currentUser!.uid);
      } else {
        widget.post.likes.add(currentUser!.uid);
      }
    });

    // atualizar curtida
    postCubit
        .toggleLikePost(widget.post.id, currentUser!.uid)
        .catchError((error) {
      // se houver um erro, voltar ao valor original
      setState(() {
        if (isLiked) {
          widget.post.likes.add(currentUser!.uid); // reverter curtida
        } else {
          widget.post.likes.remove(currentUser!.uid); // reverter descurtida
        }
      });
    });
  }

  // controller do texto do comentário
  final commentTextController = TextEditingController();

  // abrir caixa de comentário quando o usuário quiser escrever um novo comentário
  void openNewCommentBox() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: MyTextField(
          controller: commentTextController,
          hintText: 'Escreva seu comentário',
          obscureText: false,
        ),
        actions: [
          // botão para cancelar
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar')),

          // botão para salvar
          TextButton(
              onPressed: () {
                addComment();
                Navigator.of(context).pop();
              },
              child: const Text('Salvar')),
        ],
      ),
    );
  }

  void addComment() {
    // criar novo comentário
    final newComment = Comment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      postId: widget.post.id,
      userId: currentUser!.uid,
      userName: currentUser!.name,
      text: commentTextController.text,
      timestamp: DateTime.now(),
    );

    // adicionar comentário usando cubit
    if (commentTextController.text.isNotEmpty) {
      postCubit.addComment(widget.post.id, newComment);
    }
  }

  @override
  void dispose() {
    commentTextController.dispose();
    super.dispose();
  }

  // mostrar opções para deletar
  void showOptions() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Deletar postagem?'),
              actions: [
                // botão de cancelar
                TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancelar')),

                // botão de confirmar exclusão
                TextButton(
                    onPressed: () {
                      widget.onDeletePressed!();
                      Navigator.of(context).pop();
                    },
                    child: const Text('Confirmar')),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.secondary,
      child: Column(
        children: [
          GestureDetector(
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ProfilePage(
                          uid: widget.post.userId,
                        ))),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // foto de perfil
                  postUser?.profileImageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: postUser!.profileImageUrl,
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.person),
                          imageBuilder: (context, imageProvider) => Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        )
                      : const Icon(Icons.person),

                  const SizedBox(width: 10),

                  // nome
                  Text(
                    widget.post.userName,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.inversePrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const Spacer(),

                  // botão de deletar
                  if (isOwnPost)
                    GestureDetector(
                      onTap: showOptions,
                      child: Icon(
                        Icons.delete,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    )
                ],
              ),
            ),
          ),

          // imagem
          CachedNetworkImage(
            imageUrl: widget.post.imageUrl,
            height: 430,
            width: double.infinity,
            fit: BoxFit.cover,
            placeholder: (context, url) => const SizedBox(height: 430),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),

          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                SizedBox(
                  width: 50,
                  child: Row(
                    children: [
                      // botão de curtir
                      GestureDetector(
                        onTap: toggleLikePost,
                        child: Icon(
                          widget.post.likes.contains(currentUser!.uid)
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: widget.post.likes.contains(currentUser!.uid)
                              ? Colors.red
                              : Theme.of(context).colorScheme.primary,
                        ),
                      ),

                      const SizedBox(width: 5),

                      // contagem de likes
                      Text(
                        widget.post.likes.length.toString(),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                // botão de comentar
                GestureDetector(
                  onTap: openNewCommentBox,
                  child: Icon(
                    Icons.comment,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),

                const SizedBox(width: 5),

                // contagem de comentários
                Text(
                  widget.post.comments.length.toString(),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 12,
                  ),
                ),

                const Spacer(),

                // horário da postagem
                Text(widget.post.timestamp.toString()),
              ],
            ),
          ),

          // legenda
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20),
            child: Row(
              children: [
                // usuário
                Text(
                  widget.post.userName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(width: 10),

                // texto
                Text(widget.post.text),
              ],
            ),
          ),

          // comentários
          BlocBuilder<PostCubit, PostState>(builder: (context, state) {
            // carregado
            if (state is PostsLoaded) {
              final post =
                  state.posts.firstWhere((post) => (post.id == widget.post.id));

              if (post.comments.isNotEmpty) {
                // contagem de comentários
                int showCommentsCount = post.comments.length;

                return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: showCommentsCount,
                    itemBuilder: (context, index) {
                      // obter comentário individual
                      final comment = post.comments[index];

                      // UI
                      return CommentTile(comment: comment);
                    });
              }
            }

            // carregando
            if (state is PostsLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );

              // erros
            } else if (state is PostsError) {
              return Center(
                child: Text(state.message),
              );
            } else {
              return const SizedBox();
            }
          })
        ],
      ),
    );
  }
}
