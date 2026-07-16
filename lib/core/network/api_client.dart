import 'dart:io';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../error/failure.dart';

@lazySingleton
class ApiClient {
  ApiClient()
    : dio = Dio(
        BaseOptions(
          baseUrl: 'https://dummyjson.com',
          connectTimeout: const Duration(seconds: 8),
          receiveTimeout: const Duration(seconds: 8),
        ),
      )..interceptors.add(LogInterceptor(requestBody: true));

  final Dio dio;

  Future<Result<T>> request<T>(Future<T> Function() action) async {
    try {
      return Success(await action());
    } on DioException catch (exception) {
      return Error(_mapDioException(exception));
    } on SocketException {
      return const Error(Failure('Нет подключения к интернету'));
    } on FormatException {
      return const Error(Failure('Сервис вернул некорректные данные'));
    } catch (_) {
      return const Error(Failure('Произошла непредвиденная ошибка'));
    }
  }

  Failure _mapDioException(DioException exception) {
    if (exception.type == DioExceptionType.connectionTimeout ||
        exception.type == DioExceptionType.receiveTimeout ||
        exception.type == DioExceptionType.sendTimeout) {
      return const Failure('Сервис отвечает слишком долго');
    }
    if (exception.type == DioExceptionType.connectionError) {
      return const Failure('Нет подключения к интернету');
    }
    final status = exception.response?.statusCode;
    if (status != null && status >= 500) {
      return Failure('Ошибка сервера. Попробуйте позже', code: status);
    }
    if (status != null && status >= 400) {
      return Failure('Запрос не может быть выполнен', code: status);
    }
    return const Failure('Не удалось загрузить данные');
  }
}
