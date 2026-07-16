import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_widgets.dart';
import 'users_cubit.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) => SafeArea(
    bottom: false,
    child: BlocBuilder<UsersCubit, UsersState>(
      builder: (context, state) {
        if (state.status == UsersStatus.loading ||
            state.status == UsersStatus.initial) {
          return const SkeletonList();
        }
        if (state.status == UsersStatus.failure) {
          return StatusView(
            icon: Icons.people_outline_rounded,
            title: state.message ?? 'Не удалось загрузить авторов',
            actionLabel: 'Попробовать снова',
            onAction: context.read<UsersCubit>().load,
          );
        }
        return CustomScrollView(
          slivers: [
            const SliverPadding(
              padding: EdgeInsets.fromLTRB(20, 24, 20, 24),
              sliver: SliverToBoxAdapter(
                child: SectionHeader(
                  eyebrow: 'Creative community',
                  title: 'Наши\nавторы',
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 130),
              sliver: SliverGrid.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 260,
                  mainAxisExtent: 235,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                ),
                itemCount: state.users.length,
                itemBuilder: (context, index) {
                  final user = state.users[index];
                  final colors = index.isEven
                      ? [AppColors.coral, const Color(0xFF7F5AF0)]
                      : [AppColors.sky, const Color(0xFF26736A)];
                  return Hero(
                    tag: 'user-${user.id}',
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(30),
                        onTap: () =>
                            context.push('/users/${user.id}', extra: user),
                        child: Ink(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: colors,
                            ),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(32),
                              topRight: Radius.circular(12),
                              bottomLeft: Radius.circular(12),
                              bottomRight: Radius.circular(32),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 28,
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
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                user.name,
                                maxLines: 2,
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(color: Colors.white),
                              ),
                              const SizedBox(height: 7),
                              Text(
                                '@${user.username}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on_outlined,
                                    size: 17,
                                  ),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    child: Text(
                                      user.city,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    ),
  );
}
