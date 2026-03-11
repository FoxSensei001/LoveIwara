import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/models/api_failure.model.dart';

void main() {
  group('ApiFailureResolver', () {
    test('classifies auth refresh failure from request extras', () {
      final requestOptions = RequestOptions(
        path: '/user/counts',
        extra: {'auth_refresh_failed': true},
      );
      final error = DioException.badResponse(
        statusCode: 401,
        requestOptions: requestOptions,
        response: Response<dynamic>(
          requestOptions: requestOptions,
          statusCode: 401,
          data: {'message': 'errors.forbidden'},
        ),
      );

      final failure = ApiFailureResolver.resolve(error);

      expect(failure.kind, ApiFailureKind.authRefreshFailed);
      expect(failure.statusCode, 401);
    });

    test('classifies forbidden payloads distinctly', () {
      final requestOptions = RequestOptions(path: '/user/counts');
      final error = DioException.badResponse(
        statusCode: 403,
        requestOptions: requestOptions,
        response: Response<dynamic>(
          requestOptions: requestOptions,
          statusCode: 403,
          data: {'message': 'errors.forbidden'},
        ),
      );

      final failure = ApiFailureResolver.resolve(error);

      expect(failure.kind, ApiFailureKind.forbidden);
      expect(failure.apiMessage, 'errors.forbidden');
    });

    test('classifies private video payloads distinctly', () {
      final requestOptions = RequestOptions(path: '/video/abc');
      final error = DioException.badResponse(
        statusCode: 403,
        requestOptions: requestOptions,
        response: Response<dynamic>(
          requestOptions: requestOptions,
          statusCode: 403,
          data: {'message': 'errors.privateVideo'},
        ),
      );

      final failure = ApiFailureResolver.resolve(error);

      expect(failure.kind, ApiFailureKind.privateVideo);
      expect(failure.apiMessage, 'errors.privateVideo');
    });
  });
}
