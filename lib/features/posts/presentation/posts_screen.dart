import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_widgets.dart';
import 'post_card.dart';
import 'posts_cubit.dart';

class PostsScreen extends StatelessWidget {
  const PostsScreen({super.key});

  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.ink,
    child: SafeArea(
      bottom: false,
      child: BlocBuilder<PostsCubit, PostsState>(
        builder: (context, state) {
          if (state.status == PostsStatus.loading ||
              state.status == PostsStatus.initial) {
            return const SkeletonList();
          }
          if (state.status == PostsStatus.failure) {
            return StatusView(
              icon: Icons.cloud_off_rounded,
              title: state.message ?? 'Не удалось загрузить публикации',
              actionLabel: 'Попробовать снова',
              onAction: context.read<PostsCubit>().load,
            );
          }
          return RefreshIndicator(
            color: AppColors.lime,
            backgroundColor: AppColors.panel,
            onRefresh: () => context.read<PostsCubit>().load(refresh: true),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      children: [
                        const SectionHeader(
                          eyebrow: 'Postly digest',
                          title: 'Свежие\nистории',
                        ),
                        const SizedBox(height: 24),
                        TextField(
                          key: const ValueKey('post-search'),
                          onChanged: context.read<PostsCubit>().search,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.search_rounded),
                            hintText: 'Найти историю',
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 42,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: 11,
                            separatorBuilder: (_, _) =>
                                const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              final id = index == 0 ? null : index;
                              final selected = state.authorId == id;
                              return ChoiceChip(
                                label: Text(
                                  id == null ? 'Все авторы' : 'Автор $id',
                                ),
                                selected: selected,
                                onSelected: (_) => context
                                    .read<PostsCubit>()
                                    .filterByAuthor(id),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (state.visiblePosts.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: StatusView(
                      icon: Icons.auto_stories_outlined,
                      title: 'Ничего не найдено',
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 130),
                    sliver: SliverList.separated(
                      itemCount: state.visiblePosts.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final post = state.visiblePosts[index];
                        return TweenAnimationBuilder<double>(
                          duration: Duration(
                            milliseconds: 280 + index.clamp(0, 8) * 50,
                          ),
                          tween: Tween(begin: 0, end: 1),
                          builder: (context, value, child) =>
                              Transform.translate(
                                offset: Offset(0, 22 * (1 - value)),
                                child: Opacity(opacity: value, child: child),
                              ),
                          child: PostCard(
                            post: post,
                            isFavorite: state.favorites.contains(post.id),
                            onFavorite: () => context
                                .read<PostsCubit>()
                                .toggleFavorite(post.id),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    ),
  );
}
