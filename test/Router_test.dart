import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:test/test.dart';

const server = 'http://localhost:8081';

void main() {
  group('Router', () {
    test('urequest_no_content_typesers', () async {
      Response response = await Dio().post("$server/request_no_content_type");
      expect(response.data, {"contentType": null});
    });

    test('application_json', () async {
      Response response = await Dio().post("$server/application_json");
      expect(response.data, null);
    });

    test('application_json', () async {
      Response response = await Dio().post("$server/application_json", data: {"name": "peter"});
      expect(response.data, {"name": "peter"});
    });

//    test('application_json', () async {
//      bool exception = false;
//      try {
//        await Dio().post("$server/application_json", data: "peter", options: Options(connectTimeout: 10)).catchError((error) {
//          expect(true, true);
//        });
//      } catch (error) {
//        exception = true;
//      }
//      expect(exception, true);
//    });

    test('path_params', () async {
      Response response = await Dio().get("$server/path_params?age=16&isHero=true&friends=thor&friends=iron man&grandpa");
      expect(response.data, {
        "age": 16,
        "isHero": true,
        "friends": ["thor", 'iron man'],
        "grandpa": '',
        "money": null,
        "actors": null
      });
    });

    test('x-www-form-urlencoded', () async {
      Response response = await Dio().post("$server/x-www-form-urlencoded?age=16&isHero=true&friends=thor&friends=iron man&grandpa",
          data: {
            'actors': ["Tobey Maguire", "I dont care"]
          },
          options: Options(contentType: ContentType.parse('application/x-www-form-urlencoded')));
      expect(response.data, {
        "age": 16,
        "isHero": true,
        "friends": ["thor", 'iron man'],
        "grandpa": '',
        "money": null,
        "actors": ["Tobey Maguire", "I dont care"]
      });
    });
  });

  group("CookieValue", () {
    Dio dio;

    setUp(() {
      dio = Dio();
      dio.interceptors.add(CookieManager(CookieJar()));
    });

    test('cookie', () async {
      Response response = await dio.post("$server/cookie", options: Options(cookies: [Cookie("name", "peter")]));
      expect(response.data, [
        {"name": "peter"}
      ]);
    });

    tearDown(() {
      dio = null;
    });
  });

  group("users", () {
    Dio dio;

    setUp(() {
      dio = Dio(BaseOptions(contentType: ContentType.json));
    });

    test('users', () async {
      Response response = await dio.post("$server/header", data: {}, options: Options(contentType: ContentType.json));
      expect(response.data, {"Content-Type": "application/json; charset=utf-8"});
    });

    tearDown(() {
      dio = null;
    });
  });

  group("SessionValue", () {
    Dio dio;

    setUp(() {
      dio = Dio();
      dio.interceptors.add(CookieManager(CookieJar()));
    });

    test('session', () async {
      Response setSessionRes = await dio.post("$server/setSession");
      expect(setSessionRes.data["jsessionid"] != null, true);
      expect(setSessionRes.data["name"], "peter");

      Response getSessionRes =
          await dio.post("$server/setSession", options: Options(cookies: [Cookie("set-cookie", setSessionRes.data["jsessionid"])]));
      expect(getSessionRes.data["name"], "peter");
    });

    tearDown(() {
      dio = null;
    });
  });

  group("formdata", () {
    test('multipart-form-data', () async {
      File file = File(Directory.current.path + "/test/example/20180902193200.jpg");
      Response response = await Dio().post('$server/multipart-form-data',
          data: FormData.from({
            "name": "peter",
            "friends": ["thor", 'iron man'],
            "file": UploadFileInfo(file, "20180902193200.jpg")
          }));
      expect(response.data, {
        "name": "peter",
        "friends": ["thor", 'iron man'],
        "file_length": 1
      });
    });
  });
}
