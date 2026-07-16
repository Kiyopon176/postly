import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../shared/widgets/app_widgets.dart';
import '../posts/presentation/posts_cubit.dart';
import '../users/presentation/users_cubit.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final posts = context.watch<PostsCubit>().state;
    final users = context.watch<UsersCubit>().state;
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 30, 20, 130),
        children: [
          Text(
            'POSTLY / 24',
            style: const TextStyle(
              color: AppColors.lime,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Идеи, которые\nостаются.',
            style: Theme.of(context).textTheme.displayLarge,
          ),
          const SizedBox(height: 18),
          const Text(
            'Тихое пространство для сильных мыслей, любопытных людей и честных разговоров.',
          ),
          const SizedBox(height: 34),
          LayoutBuilder(
            builder: (context, constraints) => Row(
              children: [
                Expanded(
                  child: _Metric(
                    value: '${posts.posts.length}',
                    label: 'историй',
                    color: AppColors.coral,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _Metric(
                    value: '${users.users.length}',
                    label: 'авторов',
                    color: AppColors.sky,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          GlassCard(
            onTap: () => context.go('/posts'),
            padding: EdgeInsets.zero,
            child: Stack(
              children: [
                Positioned(
                  right: -30,
                  top: -45,
                  child: Container(
                    width: 170,
                    height: 170,
                    decoration: const BoxDecoration(
                      color: AppColors.lime,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'СЕГОДНЯ В ФОКУСЕ',
                        style: TextStyle(
                          color: AppColors.coral,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.4,
                        ),
                      ),
                      const SizedBox(height: 56),
                      Text(
                        posts.posts.isEmpty
                            ? 'Откройте свежий выпуск'
                            : posts.posts.first.title,
                        maxLines: 3,
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                      const SizedBox(height: 16),
                      const Row(
                        children: [
                          Text(
                            'Читать подборку',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded),
                        ],
                      ),
                    ],
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

class _Metric extends StatelessWidget {
  const _Metric({
    required this.value,
    required this.label,
    required this.color,
  });
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: color,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(30),
        topRight: Radius.circular(12),
        bottomLeft: Radius.circular(12),
        bottomRight: Radius.circular(30),
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.headlineLarge?.copyWith(color: AppColors.ink),
        ),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.ink,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    ),
  );
}
