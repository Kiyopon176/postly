import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../shared/widgets/app_widgets.dart';
import 'post_card.dart';
import 'posts_cubit.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<PostsCubit>().state;
    final favorites = state.posts
        .where((post) => state.favorites.contains(post.id))
        .toList();
    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: [
          const SliverPadding(
            padding: EdgeInsets.fromLTRB(20, 24, 20, 24),
            sliver: SliverToBoxAdapter(
              child: SectionHeader(eyebrow: 'Your library', title: 'Избранное'),
            ),
          ),
          if (favorites.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: StatusView(
                icon: Icons.bookmarks_outlined,
                title: 'Сохранённых историй пока нет',
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 130),
              sliver: SliverList.separated(
                itemCount: favorites.length,
                separatorBuilder: (_, _) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final post = favorites[index];
                  return PostCard(
                    post: post,
                    isFavorite: true,
                    onFavorite: () =>
                        context.read<PostsCubit>().toggleFavorite(post.id),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
