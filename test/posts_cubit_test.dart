import 'package:flutter_test/flutter_test.dart';
import 'package:post_test/core/error/failure.dart';
import 'package:post_test/features/posts/domain/post.dart';
import 'package:post_test/features/posts/domain/posts_repository.dart';
import 'package:post_test/features/posts/presentation/posts_cubit.dart';

void main() {
  const post = Post(
    id: 1,
    userId: 2,
    title: 'Design systems',
    body: 'A useful story',
  );

  test('load emits success with posts and favorites', () async {
    final cubit = PostsCubit(
      _FakePostsRepository(result: const Success([post]), favorites: {1}),
    );
    await cubit.load();
    expect(cubit.state.status, PostsStatus.success);
    expect(cubit.state.posts, [post]);
    expect(cubit.state.favorites, {1});
    await cubit.close();
  });

  test('load emits failure with readable message', () async {
    final cubit = PostsCubit(
      _FakePostsRepository(result: const Error(Failure('Offline'))),
    );
    await cubit.load();
    expect(cubit.state.status, PostsStatus.failure);
    expect(cubit.state.message, 'Offline');
    await cubit.close();
  });
}

class _FakePostsRepository implements PostsRepository {
  _FakePostsRepository({required this.result, this.favorites = const {}});
  final Result<List<Post>> result;
  final Set<int> favorites;

  @override
  Future<Result<List<Post>>> getPosts() async => result;

  @override
  Future<Set<int>> getFavorites() async => favorites;

  @override
  Future<void> setFavorite(int id, bool value) async {}

  @override
  Future<Result<List<Comment>>> getComments(int postId) async =>
      const Success([]);

  @override
  Future<Result<Post>> updatePost(Post post) async => Success(post);

  @override
  Future<Result<void>> deletePost(int id) async => const Success(null);
}
