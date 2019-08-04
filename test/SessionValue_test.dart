import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:test/test.dart';

void main() {
  group("SessionValue", () {
    Dio dio;

    setUp(() {
      dio = Dio();
      dio.interceptors.add(CookieManager(CookieJar()));
    });

    test('session', () async {
      Response setSessionRes = await dio.post("http://localhost:8081/setSession");
      expect(setSessionRes.data["jsessionid"] != null, true);
      expect(setSessionRes.data["name"], "peter");

      Response getSessionRes = await dio.post("http://localhost:8081/setSession",
          options: Options(cookies: [Cookie("set-cookie", setSessionRes.data["jsessionid"])]));
      expect(getSessionRes.data["name"], "peter");
    });

    tearDown(() {
      dio = null;
    });
  });
}
