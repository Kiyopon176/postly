import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:post_test/core/theme/app_theme.dart';
import 'package:post_test/features/posts/domain/post.dart';
import 'package:post_test/features/posts/presentation/post_card.dart';

void main() {
  const post = Post(
    id: 7,
    userId: 3,
    title: 'A remarkable title',
    body: 'Editorial body copy',
  );

  testWidgets('post card renders editorial content', (tester) async {
    await tester.pumpWidget(_TestApp(post: post, onFavorite: () {}));
    expect(find.text('A remarkable title'), findsOneWidget);
    expect(find.text('АВТОР 03'), findsOneWidget);
    expect(find.text('07'), findsOneWidget);
  });

  testWidgets('favorite button invokes callback', (tester) async {
    var taps = 0;
    await tester.pumpWidget(_TestApp(post: post, onFavorite: () => taps++));
    await tester.tap(find.byKey(const ValueKey('favorite-7')));
    await tester.pump();
    expect(taps, 1);
  });
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.post, required this.onFavorite});
  final Post post;
  final VoidCallback onFavorite;

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => Scaffold(
            body: PostCard(
              post: post,
              isFavorite: false,
              onFavorite: onFavorite,
            ),
          ),
        ),
        GoRoute(path: '/posts/:id', builder: (_, _) => const SizedBox()),
      ],
    );
    return MaterialApp.router(theme: buildTheme(), routerConfig: router);
  }
}
