import '../../../core/error/failure.dart';
import 'user.dart';

abstract interface class UsersRepository {
  Future<Result<List<User>>> getUsers();
}

class GetUsers {
  const GetUsers(this.repository);
  final UsersRepository repository;
  Future<Result<List<User>>> call() => repository.getUsers();
}
