import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/error/failure.dart';
import '../domain/user.dart';
import '../domain/users_repository.dart';

enum UsersStatus { initial, loading, success, failure }

class UsersState extends Equatable {
  const UsersState({
    this.status = UsersStatus.initial,
    this.users = const [],
    this.message,
  });
  final UsersStatus status;
  final List<User> users;
  final String? message;

  @override
  List<Object?> get props => [status, users, message];
}

class UsersCubit extends Cubit<UsersState> {
  UsersCubit(this.repository) : super(const UsersState());
  final UsersRepository repository;

  Future<void> load() async {
    emit(const UsersState(status: UsersStatus.loading));
    final result = await repository.getUsers();
    switch (result) {
      case Success(value: final users):
        emit(UsersState(status: UsersStatus.success, users: users));
      case Error(failure: final failure):
        emit(UsersState(status: UsersStatus.failure, message: failure.message));
    }
  }
}
