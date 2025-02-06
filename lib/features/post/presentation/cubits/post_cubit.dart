import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rede_social/features/post/presentation/cubits/post_states.dart';
import '../../../storage/domain/storage_repo.dart';
import '../../domain/entities/post.dart';
import '../../domain/repos/post_repo.dart';

class PostCubit extends Cubit<PostState> {
  final PostRepo postRepo;
  final StorageRepo storageRepo;

  PostCubit({
    required this.postRepo,
    required this.storageRepo,
  }) : super(PostsInitial());

  // criar uma nova postagem
  Future<void> createPost(Post post,
      {String? imagePath, Uint8List? imageBytes}) async {
    String? imageUrl;

    try {
      // enviar imagens em plataformas mobile (com file path)
      if (imagePath != null) {
        emit(PostsUploading());
        imageUrl = await storageRepo.uploadPostImageMobile(imagePath, post.id);
      }

      // enviar imagens em plataformas web (com file bytes)
      else if (imageBytes != null) {
        emit(PostsUploading());
        imageUrl = await storageRepo.uploadPostImageWeb(imageBytes, post.id);
      }

      // fornecer URL da imagem para postar
      final newPost = post.copyWith(imageUrl: imageUrl);

      // criar a postagem no backend
      postRepo.createPost(newPost);

      // buscar novamente todos as postagens
      fetchAllPosts();
    } catch (e) {
      emit(PostsError('Falha ao criar a postagem: $e'));
    }
  }

  // buscar todas postagens
  Future<void> fetchAllPosts() async {
    try {
      emit(PostsLoading());
      final posts = await postRepo.fetchAllPosts();
      emit(PostsLoaded(posts));
    } catch (e) {
      emit(PostsError('Falha ao buscar as pontagens: $e'));
    }
  }

  // excluir postagem
  Future<void> deletePost(String postId) async {
    try {
      await postRepo.deletePost(postId);
    } catch (e) {
      emit(PostsError('Falha ao excluir postagem: $e'));
    }
  }
}
