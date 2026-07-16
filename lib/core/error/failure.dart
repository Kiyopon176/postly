import 'package:equatable/equatable.dart';

sealed class Result<T> {
  const Result();
}

final class Success<T> extends Result<T> {
  const Success(this.value);
  final T value;
}

final class Error<T> extends Result<T> {
  const Error(this.failure);
  final Failure failure;
}

class Failure extends Equatable {
  const Failure(this.message, {this.code});
  final String message;
  final int? code;

  @override
  List<Object?> get props => [message, code];
}
