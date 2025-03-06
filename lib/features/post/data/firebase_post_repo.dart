import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rede_social/features/post/domain/entities/comment.dart';
import 'package:rede_social/features/post/domain/entities/post.dart';
import 'package:rede_social/features/post/domain/repos/post_repo.dart';

class FirebasePostRepo implements PostRepo {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // armazenar as postagens em uma collection chamada 'posts'
  final CollectionReference postsCollection =
      FirebaseFirestore.instance.collection('posts');

  @override
  Future<void> createPost(Post post) async {
    try {
      await postsCollection.doc(post.id).set(post.toJson());
    } catch (e) {
      throw Exception('Erro ao criar o post: $e');
    }
  }

  @override
  Future<void> deletePost(String postId) async {
    await postsCollection.doc(postId).delete();
  }

  @override
  Future<List<Post>> fetchAllPosts() async {
    try {
      // recuperar todas as postagens com as mais recentes no topo
      final postsSnapshot =
          await postsCollection.orderBy('timestamp', descending: true).get();

      final List<Post> allPosts = postsSnapshot.docs
          .map((doc) => Post.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      return allPosts;
    } catch (e) {
      throw Exception('Erro ao buscar postagens: $e');
    }
  }

  @override
  Future<List<Post>> fetchPostsByUserId(String userId) async {
    try {
      // buscar postagens através do user id
      final postsSnapshot =
          await postsCollection.where('userId', isEqualTo: userId).get();

      final userPosts = postsSnapshot.docs
          .map((doc) => Post.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      return userPosts;
    } catch (e) {
      throw Exception('Erro ao buscar postagens do usuário: $e');
    }
  }

  @override
  Future<void> toggleLikePost(String postId, String userId) async {
    try {
      // obter os dados do post através da firestore
      final postDoc = await postsCollection.doc(postId).get();

      if (postDoc.exists) {
        final post = Post.fromJson(postDoc.data() as Map<String, dynamic>);

        // verificar se o usuário ja curtiu o post
        final hasLiked = post.likes.contains(userId);

        // atualizar a lista de likes
        if (hasLiked) {
          post.likes.remove(userId);
        } else {
          post.likes.add(userId);
        }

        // atualizar os dados do post com a nova lista de likes
        await postsCollection.doc(postId).update({
          'likes': post.likes,
        });
      } else {
        throw Exception('Postagem não encontrada');
      }
    } catch (e) {
      throw Exception('Erro ao curtir/descurtir: $e');
    }
  }

  @override
  Future<void> addComment(String postId, Comment comment) async {
    try {
      // obter dados da postagem
      final postDoc = await postsCollection.doc(postId).get();

      if (postDoc.exists) {
        final post = Post.fromJson(postDoc.data() as Map<String, dynamic>);

        // adicionar novo comentário
        post.comments.add(comment);

        // atualizar os dados da postagem no firestore
        await postsCollection.doc(postId).update({
          'comments': post.comments.map((comment) => comment.toJson()).toList()
        });
      } else {
        throw Exception('Postagem não encontrada');
      }
    } catch (e) {
      throw Exception('Erro ao adicionar comentário: $e');
    }
  }

  @override
  Future<void> deleteComment(String postId, String commentId) async {
    try {
      // obter dados da postagem
      final postDoc = await postsCollection.doc(postId).get();

      if (postDoc.exists) {
        final post = Post.fromJson(postDoc.data() as Map<String, dynamic>);

        // remover comentário
        post.comments.removeWhere((comment) => comment.id == commentId);

        // atualizar os dados da postagem no firestore
        await postsCollection.doc(postId).update({
          'comments': post.comments.map((comment) => comment.toJson()).toList()
        });
      } else {
        throw Exception('Postagem não encontrada');
      }
    } catch (e) {
      throw Exception('Erro ao deletar comentário: $e');
    }
  }
}
