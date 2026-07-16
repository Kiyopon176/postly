import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:post_test/core/error/failure.dart';
import 'package:post_test/features/posts/domain/post.dart';
import 'package:post_test/features/posts/domain/posts_repository.dart';
import 'package:post_test/features/posts/presentation/posts_cubit.dart';
import 'package:post_test/features/posts/presentation/posts_screen.dart';

void main() {
  testWidgets('search has local Material inside a lookup boundary', (
    tester,
  ) async {
    final repository = _PostsScreenRepository();
    final cubit = PostsCubit(repository);
    await cubit.load();
    await tester.pumpWidget(
      MaterialApp(
        home: LookupBoundary(
          child: BlocProvider.value(value: cubit, child: const PostsScreen()),
        ),
      ),
    );
    await tester.pump();
    expect(find.byKey(const ValueKey('post-search')), findsOneWidget);
    expect(tester.takeException(), isNull);
    await cubit.close();
  });
}

class _PostsScreenRepository implements PostsRepository {
  @override
  Future<Result<List<Post>>> getPosts() async => const Success([
    Post(id: 1, userId: 1, title: 'A story', body: 'Story body'),
  ]);

  @override
  Future<Set<int>> getFavorites() async => {};

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
