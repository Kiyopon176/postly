import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/error/failure.dart';
import '../domain/post.dart';
import '../domain/posts_repository.dart';

enum PostsStatus { initial, loading, success, failure }

class PostsState extends Equatable {
  const PostsState({
    this.status = PostsStatus.initial,
    this.posts = const [],
    this.favorites = const {},
    this.query = '',
    this.authorId,
    this.message,
  });
  final PostsStatus status;
  final List<Post> posts;
  final Set<int> favorites;
  final String query;
  final int? authorId;
  final String? message;

  List<Post> get visiblePosts => posts.where((post) {
    final matchesQuery = post.title.toLowerCase().contains(query.toLowerCase());
    final matchesAuthor = authorId == null || post.userId == authorId;
    return matchesQuery && matchesAuthor;
  }).toList();

  PostsState copyWith({
    PostsStatus? status,
    List<Post>? posts,
    Set<int>? favorites,
    String? query,
    int? authorId,
    bool clearAuthor = false,
    String? message,
  }) => PostsState(
    status: status ?? this.status,
    posts: posts ?? this.posts,
    favorites: favorites ?? this.favorites,
    query: query ?? this.query,
    authorId: clearAuthor ? null : authorId ?? this.authorId,
    message: message,
  );

  @override
  List<Object?> get props => [
    status,
    posts,
    favorites,
    query,
    authorId,
    message,
  ];
}

class PostsCubit extends Cubit<PostsState> {
  PostsCubit(this.repository) : super(const PostsState());
  final PostsRepository repository;

  Future<void> load({bool refresh = false}) async {
    if (!refresh) emit(state.copyWith(status: PostsStatus.loading));
    final result = await repository.getPosts();
    switch (result) {
      case Success(value: final posts):
        final favorites = await repository.getFavorites();
        emit(
          state.copyWith(
            status: PostsStatus.success,
            posts: posts,
            favorites: favorites,
          ),
        );
      case Error(failure: final failure):
        emit(
          state.copyWith(status: PostsStatus.failure, message: failure.message),
        );
    }
  }

  void search(String value) => emit(state.copyWith(query: value));

  void filterByAuthor(int? id) =>
      emit(state.copyWith(authorId: id, clearAuthor: id == null));

  Future<void> toggleFavorite(int id) async {
    final favorites = {...state.favorites};
    final value = !favorites.contains(id);
    value ? favorites.add(id) : favorites.remove(id);
    emit(state.copyWith(favorites: favorites));
    await repository.setFavorite(id, value);
  }

  Future<bool> update(Post post) async {
    final previous = state.posts;
    final updated = previous
        .map((item) => item.id == post.id ? post : item)
        .toList();
    emit(state.copyWith(posts: updated));
    final result = await repository.updatePost(post);
    if (result case Error(failure: final failure)) {
      emit(state.copyWith(posts: previous, message: failure.message));
      return false;
    }
    return true;
  }

  Future<bool> delete(int id) async {
    final previous = state.posts;
    emit(
      state.copyWith(posts: previous.where((post) => post.id != id).toList()),
    );
    final result = await repository.deletePost(id);
    if (result case Error(failure: final failure)) {
      emit(state.copyWith(posts: previous, message: failure.message));
      return false;
    }
    return true;
  }
}
