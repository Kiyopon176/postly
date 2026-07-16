import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/posts/data/posts_data.dart';
import '../../features/posts/domain/posts_repository.dart';
import '../../features/posts/presentation/posts_cubit.dart';
import '../../features/users/data/users_data.dart';
import '../../features/users/domain/users_repository.dart';
import '../../features/users/presentation/users_cubit.dart';
import '../network/api_client.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  final preferences = await SharedPreferences.getInstance();
  getIt.registerSingleton(preferences);
  getIt.registerLazySingleton(ApiClient.new);
  getIt.registerLazySingleton(() => PostsRemoteDataSource(getIt()));
  getIt.registerLazySingleton<PostsRepository>(
    () => PostsRepositoryImpl(getIt(), getIt()),
  );
  getIt.registerLazySingleton<UsersRepository>(
    () => UsersRepositoryImpl(getIt()),
  );
  getIt.registerFactory(() => PostsCubit(getIt()));
  getIt.registerFactory(() => UsersCubit(getIt()));
}
