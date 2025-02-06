import '../../domain/entities/post.dart';

abstract class PostState {}

// estado inicial
class PostsInitial extends PostState {}

// carregando
class PostsLoading extends PostState {}

// enviando
class PostsUploading extends PostState {}

// erros
class PostsError extends PostState {
  final String message;
  PostsError(this.message);
}

// carregado
class PostsLoaded extends PostState {
  final List<Post> posts;
  PostsLoaded(this.posts);
}
