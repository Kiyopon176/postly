import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/error/failure.dart';
import '../../../core/network/api_client.dart';
import '../domain/post.dart';
import '../domain/posts_repository.dart';

class PostModel {
  const PostModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
  });
  final int id;
  final int userId;
  final String title;
  final String body;

  factory PostModel.fromJson(Map<String, dynamic> json) => PostModel(
    id: json['id'] as int,
    userId: json['userId'] as int,
    title: json['title'] as String,
    body: json['body'] as String,
  );

  Post toEntity() => Post(id: id, userId: userId, title: title, body: body);
}

class CommentModel {
  const CommentModel({
    required this.id,
    required this.name,
    required this.email,
    required this.body,
  });
  final int id;
  final String name;
  final String email;
  final String body;

  factory CommentModel.fromJson(Map<String, dynamic> json) => CommentModel(
    id: json['id'] as int,
    name: (json['user'] as Map<String, dynamic>)['fullName'] as String,
    email: '@${(json['user'] as Map<String, dynamic>)['username'] as String}',
    body: json['body'] as String,
  );

  Comment toEntity() => Comment(id: id, name: name, email: email, body: body);
}

@lazySingleton
class PostsRemoteDataSource {
  const PostsRemoteDataSource(this.client);
  final ApiClient client;

  Future<Result<List<Post>>> getPosts() => client.request(() async {
    final response = await client.dio.get<Map<String, dynamic>>(
      '/posts',
      queryParameters: {'limit': 0},
    );
    final posts = response.data!['posts'] as List<dynamic>;
    return posts
        .map(
          (json) => PostModel.fromJson(json as Map<String, dynamic>).toEntity(),
        )
        .toList();
  });

  Future<Result<List<Comment>>> getComments(int postId) => client.request(
    () async {
      final response = await client.dio.get<Map<String, dynamic>>(
        '/posts/$postId/comments',
      );
      final comments = response.data!['comments'] as List<dynamic>;
      return comments
          .map(
            (json) =>
                CommentModel.fromJson(json as Map<String, dynamic>).toEntity(),
          )
          .toList();
    },
  );

  Future<Result<Post>> updatePost(Post post) => client.request(() async {
    await client.dio.patch<Map<String, dynamic>>(
      '/posts/${post.id}',
      data: {'title': post.title, 'body': post.body},
    );
    return post;
  });

  Future<Result<void>> deletePost(int id) => client.request(() async {
    await client.dio.delete<void>('/posts/$id');
  });
}

@LazySingleton(as: PostsRepository)
class PostsRepositoryImpl implements PostsRepository {
  PostsRepositoryImpl(this.remote, this.preferences);
  final PostsRemoteDataSource remote;
  final SharedPreferences preferences;

  @override
  Future<Result<List<Post>>> getPosts() => remote.getPosts();

  @override
  Future<Result<List<Comment>>> getComments(int postId) =>
      remote.getComments(postId);

  @override
  Future<Result<Post>> updatePost(Post post) => remote.updatePost(post);

  @override
  Future<Result<void>> deletePost(int id) => remote.deletePost(id);

  @override
  Future<Set<int>> getFavorites() async =>
      (preferences.getStringList('favorites') ?? []).map(int.parse).toSet();

  @override
  Future<void> setFavorite(int id, bool value) async {
    final favorites = await getFavorites();
    value ? favorites.add(id) : favorites.remove(id);
    await preferences.setStringList(
      'favorites',
      favorites.map((item) => '$item').toList(),
    );
  }
}
