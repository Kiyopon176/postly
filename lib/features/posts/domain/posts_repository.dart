import '../../../core/error/failure.dart';
import 'post.dart';

abstract interface class PostsRepository {
  Future<Result<List<Post>>> getPosts();
  Future<Result<List<Comment>>> getComments(int postId);
  Future<Result<Post>> updatePost(Post post);
  Future<Result<void>> deletePost(int id);
  Future<Set<int>> getFavorites();
  Future<void> setFavorite(int id, bool value);
}

class GetPosts {
  const GetPosts(this.repository);
  final PostsRepository repository;
  Future<Result<List<Post>>> call() => repository.getPosts();
}

class GetComments {
  const GetComments(this.repository);
  final PostsRepository repository;
  Future<Result<List<Comment>>> call(int postId) =>
      repository.getComments(postId);
}
