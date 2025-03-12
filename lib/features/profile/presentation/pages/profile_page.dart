import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rede_social/features/auth/domain/entities/app_user.dart';
import 'package:rede_social/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:rede_social/features/post/presentation/components/post_tile.dart';
import 'package:rede_social/features/post/presentation/cubits/post_cubit.dart';
import 'package:rede_social/features/post/presentation/cubits/post_states.dart';
import 'package:rede_social/features/profile/presentation/components/bio_box.dart';
import 'package:rede_social/features/profile/presentation/components/follow_button.dart';
import 'package:rede_social/features/profile/presentation/components/profile_stats.dart';
import 'package:rede_social/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:rede_social/features/profile/presentation/cubits/profile_states.dart';
import 'package:rede_social/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:rede_social/features/profile/presentation/pages/follower_page.dart';

class ProfilePage extends StatefulWidget {
  final String uid;
  const ProfilePage({super.key, required this.uid});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // cubits
  late final authCubit = context.read<AuthCubit>();
  late final profileCubit = context.read<ProfileCubit>();

  // obter o usuário atual
  late AppUser? currentUser = authCubit.currentUser;

  // postagens
  int postCount = 0;

  // na inicialização, carregar os dados do perfil
  @override
  void initState() {
    super.initState();

    profileCubit.fetchUserProfile(widget.uid);
  }

  // seguir / deixar de seguir
  void followButtonPressed() {
    final profileState = profileCubit.state;

    if (profileState is! ProfileLoaded) {
      return;
    }

    final profileUser = profileState.profileUser;
    final isFollowing = profileUser.followers.contains(currentUser!.uid);

    // otimiza a atualização da UI
    setState(() {
      // parar de seguir
      if (isFollowing) {
        profileUser.followers.remove(currentUser!.uid);
      }
      // seguir
      else {
        profileUser.followers.add(currentUser!.uid);
      }
    });

    profileCubit.toggleFollow(currentUser!.uid, widget.uid).catchError((error) {
      // reverte a atualização se ocorrer algum erro
      setState(() {
        // parar de seguir
        if (isFollowing) {
          profileUser.followers.add(currentUser!.uid);
        }
        // seguir
        else {
          profileUser.followers.remove(currentUser!.uid);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // é a própria postagem
    bool isOwnPost = (widget.uid == currentUser!.uid);

    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        // carregado
        if (state is ProfileLoaded) {
          // carregar usuário
          final user = state.profileUser;

          return Scaffold(
            appBar: AppBar(
              title: Text(user.name),
              foregroundColor: Theme.of(context).colorScheme.primary,
              actions: [
                // editar perfil
                if (isOwnPost)
                  IconButton(
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditProfilePage(user: user),
                          )),
                      icon: const Icon(Icons.edit))
              ],
            ),
            body: ListView(
              children: [
                // email
                Center(
                  child: Text(
                    user.email,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 25),

                // foto de perfil
                CachedNetworkImage(
                  imageUrl: user.profileImageUrl,

                  // carregando
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(),

                  // erros

                  errorWidget: (context, url, error) => Icon(
                    Icons.person,
                    size: 72,
                    color: Theme.of(context).colorScheme.primary,
                  ),

                  // carregado
                  imageBuilder: (context, imageProvider) => Container(
                    height: 120,
                    width: 120,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        )),
                  ),
                ),

                const SizedBox(height: 25),

                // estatisticas do perfil
                ProfileStats(
                  postCount: postCount,
                  followerCount: user.followers.length,
                  followingCount: user.following.length,
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => FollowerPage(
                                followers: user.followers,
                                following: user.following,
                              ))),
                ),

                const SizedBox(height: 25),

                // botão de seguir
                if (!isOwnPost)
                  FollowButton(
                    onPressed: followButtonPressed,
                    isFollowing: user.followers.contains(currentUser!.uid),
                  ),

                const SizedBox(height: 25),

                // bio
                Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: Row(
                    children: [
                      Text(
                        'Bio',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                BioBox(text: user.bio),

                Padding(
                  padding: const EdgeInsets.only(left: 25.0, top: 25.0),
                  child: Row(
                    children: [
                      Text(
                        'Postagens',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // lista de postagens
                BlocBuilder<PostCubit, PostState>(builder: (context, state) {
                  // carregado
                  if (state is PostsLoaded) {
                    // filtrar as postagens pelo id do usuário
                    final userPosts = state.posts
                        .where((post) => post.userId == widget.uid)
                        .toList();

                    postCount = userPosts.length;

                    return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: postCount,
                        itemBuilder: (context, index) {
                          final post = userPosts[index];

                          return PostTile(
                              post: post,
                              onDeletePressed: () => context
                                  .read<PostCubit>()
                                  .deletePost(post.id));
                        });

                    // carregando
                  } else if (state is PostsLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    return const Center(
                      child: Text('Sem postagens..'),
                    );
                  }
                })
              ],
            ),
          );
        }

        // carregando
        else if (state is ProfileLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else {
          return const Scaffold(
            body: Center(
              child: Text('Nenhum perfil encontrado'),
            ),
          );
        }
      },
    );
  }
}
