import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:test/test.dart';

void main() {
  group("CookieValue", () {
    Dio dio;

    setUp(() {
      dio = Dio();
      dio.interceptors.add(CookieManager(CookieJar()));
    });

    test('cookie', () async {
      Response response =
          await dio.post("http://localhost:8081/cookie", options: Options(cookies: [Cookie("name", "peter")]));
      expect(response.data, [
        {"name": "peter"}
      ]);
    });

    tearDown(() {
      dio = null;
    });
  });
}
