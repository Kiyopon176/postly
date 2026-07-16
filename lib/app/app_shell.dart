import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/app_theme.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    final isDetail = path.startsWith('/posts/') || path.startsWith('/users/');
    if (isDetail) {
      return child;
    }
    final index = path.startsWith('/posts')
        ? 1
        : path.startsWith('/users')
        ? 2
        : path.startsWith('/favorites')
        ? 3
        : 0;
    return Scaffold(
      extendBody: true,
      body: child,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.panel.withValues(alpha: .96),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withValues(alpha: .08)),
            boxShadow: const [
              BoxShadow(
                color: Colors.black54,
                blurRadius: 30,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: NavigationBar(
            height: 72,
            backgroundColor: Colors.transparent,
            indicatorColor: AppColors.lime,
            selectedIndex: index,
            onDestinationSelected: (value) => context.go(
              const ['/', '/posts', '/users', '/favorites'][value],
            ),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.grid_view_rounded),
                label: 'Обзор',
              ),
              NavigationDestination(
                icon: Icon(Icons.auto_stories_rounded),
                label: 'Истории',
              ),
              NavigationDestination(
                icon: Icon(Icons.people_alt_rounded),
                label: 'Авторы',
              ),
              NavigationDestination(
                icon: Icon(Icons.bookmark_rounded),
                label: 'Моё',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
