import 'package:equatable/equatable.dart';

class Post extends Equatable {
  const Post({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
  });
  final int id;
  final int userId;
  final String title;
  final String body;

  Post copyWith({String? title, String? body}) => Post(
    id: id,
    userId: userId,
    title: title ?? this.title,
    body: body ?? this.body,
  );

  @override
  List<Object> get props => [id, userId, title, body];
}

class Comment extends Equatable {
  const Comment({
    required this.id,
    required this.name,
    required this.email,
    required this.body,
  });
  final int id;
  final String name;
  final String email;
  final String body;

  @override
  List<Object> get props => [id, name, email, body];
}
