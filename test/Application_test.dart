import 'dart:io';

import 'package:Q/Q.dart';
import 'package:dio/dio.dart' as dio;
import 'package:test/test.dart';

void main() {
  group('测试Application', () {
    Application application;

    setUp(() {
      application = Application();
    });

    test('Application单例模式', () {
      expect(application, Application());
    });
  });

  group("Application request", () {
    test('users', () async {
      dio.Response response = await dio.Dio(dio.BaseOptions(contentType: ContentType.json)).post("http://localhost:8081/users");
      expect(response.data, [
        {"name": "peter"}
      ]);
    });

    test('user', () async {
      dio.Response response = await dio.Dio(dio.BaseOptions(contentType: ContentType.json)).get("http://localhost:8081/user");
      expect(response.data, {"name": "peter"});
    });
  });
}
