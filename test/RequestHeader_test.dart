import 'dart:io';

import 'package:dio/dio.dart';
import 'package:test/test.dart';

void main() {
  group("users", () {
    Dio dio;

    setUp(() {
      dio = Dio(BaseOptions(contentType: ContentType.json));
    });

    test('users', () async {
      Response response =
          await dio.post("http://localhost:8081/header", data: {}, options: Options(contentType: ContentType.json));
      expect(response.data, {"Content-Type": "application/json; charset=utf-8"});
    });

    tearDown(() {
      dio = null;
    });
  });
}
