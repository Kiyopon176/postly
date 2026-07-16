import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../core/di/injection.dart';
import '../core/theme/app_theme.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/posts/domain/post.dart';
import '../features/posts/presentation/favorites_screen.dart';
import '../features/posts/presentation/post_detail_screen.dart';
import '../features/posts/presentation/posts_cubit.dart';
import '../features/posts/presentation/posts_screen.dart';
import '../features/users/domain/user.dart';
import '../features/users/presentation/user_profile_screen.dart';
import '../features/users/presentation/users_cubit.dart';
import '../features/users/presentation/users_screen.dart';
import 'app_shell.dart';

final _router = GoRouter(
  routes: [
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(path: '/', builder: (_, _) => const DashboardScreen()),
        GoRoute(path: '/posts', builder: (_, _) => const PostsScreen()),
        GoRoute(
          path: '/posts/:id',
          builder: (context, state) {
            final post = state.extra as Post?;
            if (post != null) return PostDetailScreen(post: post);
            final id = int.tryParse(state.pathParameters['id'] ?? '');
            final posts = context.read<PostsCubit>().state.posts;
            final match = posts.where((item) => item.id == id).firstOrNull;
            return match == null
                ? const PostsScreen()
                : PostDetailScreen(post: match);
          },
        ),
        GoRoute(path: '/users', builder: (_, _) => const UsersScreen()),
        GoRoute(
          path: '/users/:id',
          builder: (context, state) {
            final user = state.extra as User?;
            if (user != null) return UserProfileScreen(user: user);
            final id = int.tryParse(state.pathParameters['id'] ?? '');
            final users = context.read<UsersCubit>().state.users;
            final match = users.where((item) => item.id == id).firstOrNull;
            return match == null
                ? const UsersScreen()
                : UserProfileScreen(user: match);
          },
        ),
        GoRoute(path: '/favorites', builder: (_, _) => const FavoritesScreen()),
      ],
    ),
  ],
);

class PostlyApp extends StatelessWidget {
  const PostlyApp({super.key});

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
    providers: [
      BlocProvider(create: (_) => getIt<PostsCubit>()..load()),
      BlocProvider(create: (_) => getIt<UsersCubit>()..load()),
    ],
    child: MaterialApp.router(
      title: 'Postly',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      routerConfig: _router,
    ),
  );
}
