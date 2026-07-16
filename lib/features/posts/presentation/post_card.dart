import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_widgets.dart';
import '../domain/post.dart';

class PostCard extends StatelessWidget {
  const PostCard({
    super.key,
    required this.post,
    required this.isFavorite,
    required this.onFavorite,
  });
  final Post post;
  final bool isFavorite;
  final VoidCallback onFavorite;

  @override
  Widget build(BuildContext context) => Hero(
    tag: 'post-${post.id}',
    child: GlassCard(
      onTap: () => context.push('/posts/${post.id}', extra: post),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: AppColors.lime,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Text(
                  '${post.id}'.padLeft(2, '0'),
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                key: ValueKey('favorite-${post.id}'),
                onPressed: onFavorite,
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (child, animation) =>
                      ScaleTransition(scale: animation, child: child),
                  child: Icon(
                    isFavorite
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_outline_rounded,
                    key: ValueKey(isFavorite),
                    color: isFavorite ? AppColors.coral : Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            post.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          Text(post.body, maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 18),
          Row(
            children: [
              Text(
                'АВТОР ${post.userId.toString().padLeft(2, '0')}',
                style: const TextStyle(
                  color: AppColors.sky,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
              const Spacer(),
              const Icon(Icons.arrow_outward_rounded, color: AppColors.coral),
            ],
          ),
        ],
      ),
    ),
  );
}
