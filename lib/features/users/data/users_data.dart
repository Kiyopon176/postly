import 'package:injectable/injectable.dart';

import '../../../core/error/failure.dart';
import '../../../core/network/api_client.dart';
import '../domain/user.dart';
import '../domain/users_repository.dart';

class UserModel {
  const UserModel(this.json);
  final Map<String, dynamic> json;

  User toEntity() {
    final address = json['address'] as Map<String, dynamic>;
    final company = json['company'] as Map<String, dynamic>;
    final username = json['username'] as String;
    return User(
      id: json['id'] as int,
      name: '${json['firstName']} ${json['lastName']}',
      username: username,
      email: json['email'] as String,
      phone: json['phone'] as String,
      website: '$username.postly.app',
      city: address['city'] as String,
      company: company['name'] as String,
    );
  }
}

@LazySingleton(as: UsersRepository)
class UsersRepositoryImpl implements UsersRepository {
  const UsersRepositoryImpl(this.client);
  final ApiClient client;

  @override
  Future<Result<List<User>>> getUsers() => client.request(() async {
    final response = await client.dio.get<Map<String, dynamic>>(
      '/users',
      queryParameters: {'limit': 0},
    );
    final users = response.data!['users'] as List<dynamic>;
    return users
        .map((json) => UserModel(json as Map<String, dynamic>).toEntity())
        .toList();
  });
}
