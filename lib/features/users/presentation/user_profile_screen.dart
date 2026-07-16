import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_widgets.dart';
import '../../posts/presentation/post_card.dart';
import '../../posts/presentation/posts_cubit.dart';
import '../domain/user.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key, required this.user});
  final User user;

  @override
  Widget build(BuildContext context) {
    final postsState = context.watch<PostsCubit>().state;
    final posts = postsState.posts
        .where((post) => post.userId == user.id)
        .toList();
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(backgroundColor: AppColors.ink, pinned: true),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 50),
            sliver: SliverList.list(
              children: [
                Hero(
                  tag: 'user-${user.id}',
                  child: Container(
                    padding: const EdgeInsets.all(26),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.coral, Color(0xFF7F5AF0)],
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(38),
                        topRight: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(38),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 38,
                          backgroundColor: AppColors.paper,
                          foregroundColor: AppColors.ink,
                          child: Text(
                            user.name
                                .split(' ')
                                .map((part) => part[0])
                                .take(2)
                                .join(),
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 20,
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        Text(
                          user.name,
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${user.company} · ${user.city}',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                GlassCard(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _Contact(
                        icon: Icons.mail_outline_rounded,
                        label: user.email,
                      ),
                      _Contact(icon: Icons.phone_outlined, label: user.phone),
                      _Contact(
                        icon: Icons.language_rounded,
                        label: user.website,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 34),
                const SectionHeader(
                  eyebrow: 'Selected writing',
                  title: 'Публикации',
                ),
                const SizedBox(height: 18),
                ...posts.map(
                  (post) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: PostCard(
                      post: post,
                      isFavorite: postsState.favorites.contains(post.id),
                      onFavorite: () =>
                          context.read<PostsCubit>().toggleFavorite(post.id),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Contact extends StatelessWidget {
  const _Contact({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Chip(
    avatar: Icon(icon, size: 17, color: AppColors.lime),
    label: Text(label),
  );
}
