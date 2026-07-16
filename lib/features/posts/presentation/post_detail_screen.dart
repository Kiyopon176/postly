import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/injection.dart';
import '../../../core/error/failure.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_widgets.dart';
import '../domain/post.dart';
import '../domain/posts_repository.dart';
import 'posts_cubit.dart';

class PostDetailScreen extends StatefulWidget {
  const PostDetailScreen({super.key, required this.post});
  final Post post;

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  late Post post = widget.post;
  late Future<Result<List<Comment>>> comments = getIt<PostsRepository>()
      .getComments(post.id);

  Future<void> _edit() async {
    final result = await showModalBottomSheet<Post>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: .72),
      builder: (context) => _PostEditorSheet(post: post),
    );
    if (result == null || !mounted) return;
    setState(() => post = result);
    await context.read<PostsCubit>().update(result);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: CustomScrollView(
      slivers: [
        SliverAppBar.medium(
          pinned: true,
          backgroundColor: AppColors.ink,
          actions: [
            BlocBuilder<PostsCubit, PostsState>(
              builder: (context, state) => IconButton(
                onPressed: () =>
                    context.read<PostsCubit>().toggleFavorite(post.id),
                icon: Icon(
                  state.favorites.contains(post.id)
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_outline_rounded,
                ),
              ),
            ),
            IconButton(onPressed: _edit, icon: const Icon(Icons.edit_rounded)),
            IconButton(
              onPressed: () async {
                final router = GoRouter.of(context);
                final deleted = await context.read<PostsCubit>().delete(
                  post.id,
                );
                if (deleted) router.pop();
              },
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: AppColors.coral,
              ),
            ),
          ],
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 48),
          sliver: SliverList.list(
            children: [
              Hero(
                tag: 'post-${post.id}',
                child: GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ИСТОРИЯ ${post.id.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          color: AppColors.lime,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        post.title,
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        post.body,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 36),
              const SectionHeader(
                eyebrow: 'Conversation',
                title: 'Комментарии',
              ),
              const SizedBox(height: 18),
              FutureBuilder<Result<List<Comment>>>(
                future: comments,
                builder: (context, snapshot) {
                  final result = snapshot.data;
                  if (result == null) {
                    return const SizedBox(height: 300, child: SkeletonList());
                  }
                  if (result case Error(failure: final failure)) {
                    return StatusView(
                      icon: Icons.sms_failed_outlined,
                      title: failure.message,
                      actionLabel: 'Попробовать снова',
                      onAction: () => setState(
                        () => comments = getIt<PostsRepository>().getComments(
                          post.id,
                        ),
                      ),
                    );
                  }
                  final items = (result as Success<List<Comment>>).value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 128.0),
                    child: Column(
                      children: items
                          .map(
                            (comment) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: GlassCard(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: AppColors.sky,
                                      foregroundColor: AppColors.ink,
                                      child: Text(
                                        comment.email[0].toUpperCase(),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            comment.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(comment.body),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _PostEditorSheet extends StatefulWidget {
  const _PostEditorSheet({required this.post});
  final Post post;

  @override
  State<_PostEditorSheet> createState() => _PostEditorSheetState();
}

class _PostEditorSheetState extends State<_PostEditorSheet> {
  late final TextEditingController title = TextEditingController(
    text: widget.post.title,
  );
  late final TextEditingController body = TextEditingController(
    text: widget.post.body,
  );

  bool get canSave =>
      title.text.trim().isNotEmpty && body.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    title.addListener(_refresh);
    body.addListener(_refresh);
  }

  void _refresh() => setState(() {});

  @override
  void dispose() {
    title.dispose();
    body.dispose();
    super.dispose();
  }

  void _save() {
    Navigator.pop(
      context,
      widget.post.copyWith(title: title.text.trim(), body: body.text.trim()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    return AnimatedPadding(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.only(bottom: keyboard),
      child: FractionallySizedBox(
        heightFactor: keyboard > 0 ? .94 : .78,
        alignment: Alignment.bottomCenter,
        child: Material(
          color: AppColors.panel,
          clipBehavior: Clip.antiAlias,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(34)),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .18),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: AppColors.lime,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: const Icon(
                              Icons.edit_note_rounded,
                              color: AppColors.ink,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Редактировать историю',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.headlineSmall,
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'Изменения появятся сразу после сохранения',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      const _EditorLabel(
                        label: 'ЗАГОЛОВОК',
                        color: AppColors.sky,
                      ),
                      const SizedBox(height: 10),
                      Material(
                        color: Colors.transparent,
                        child: TextField(
                          controller: title,
                          textCapitalization: TextCapitalization.sentences,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            hintText: 'Название истории',
                            filled: true,
                            fillColor: AppColors.panelSoft,
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      const _EditorLabel(
                        label: 'ТЕКСТ',
                        color: AppColors.coral,
                      ),
                      const SizedBox(height: 10),
                      Material(
                        color: Colors.transparent,
                        child: TextField(
                          controller: body,
                          textCapitalization: TextCapitalization.sentences,
                          minLines: 5,
                          maxLines: 10,
                          decoration: const InputDecoration(
                            hintText: 'Расскажите свою историю',
                            filled: true,
                            fillColor: AppColors.panelSoft,
                            alignLabelWithHint: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
                decoration: BoxDecoration(
                  color: AppColors.panel,
                  border: Border(
                    top: BorderSide(color: Colors.white.withValues(alpha: .07)),
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton.icon(
                      onPressed: canSave ? _save : null,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.lime,
                        foregroundColor: AppColors.ink,
                        disabledBackgroundColor: AppColors.panelSoft,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      icon: const Icon(Icons.check_rounded),
                      label: const Text(
                        'Сохранить изменения',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditorLabel extends StatelessWidget {
  const _EditorLabel({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 7,
        height: 7,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 9),
      Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.5,
        ),
      ),
    ],
  );
}
