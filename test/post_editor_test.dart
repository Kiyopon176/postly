import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:post_test/core/di/injection.dart';
import 'package:post_test/core/error/failure.dart';
import 'package:post_test/features/posts/domain/post.dart';
import 'package:post_test/features/posts/domain/posts_repository.dart';
import 'package:post_test/features/posts/presentation/post_detail_screen.dart';
import 'package:post_test/features/posts/presentation/posts_cubit.dart';

void main() {
  const post = Post(id: 1, userId: 1, title: 'Title', body: 'Body');

  setUp(() async {
    await getIt.reset();
    getIt.registerSingleton<PostsRepository>(_EditorRepository());
  });

  tearDown(getIt.reset);

  testWidgets('editor fields have a Material ancestor', (tester) async {
    final repository = getIt<PostsRepository>();
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider(
          create: (_) => PostsCubit(repository),
          child: const PostDetailScreen(post: post),
        ),
      ),
    );
    await tester.tap(find.byIcon(Icons.edit_rounded));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });
}

class _EditorRepository implements PostsRepository {
  @override
  Future<Result<List<Comment>>> getComments(int postId) async =>
      const Success([]);

  @override
  Future<Result<List<Post>>> getPosts() async => const Success([]);

  @override
  Future<Set<int>> getFavorites() async => {};

  @override
  Future<void> setFavorite(int id, bool value) async {}

  @override
  Future<Result<Post>> updatePost(Post post) async => Success(post);

  @override
  Future<Result<void>> deletePost(int id) async => const Success(null);
}
