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
          options: Options(contentType: 'application/x-www-form-urlencoded'));
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
    });

    test('cookie', () async {
      Response response = await dio.post("$server/cookie", options: Options(headers: {"Cookie": "name=peter"}));
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
      dio = Dio(BaseOptions(contentType: 'application/json'));
    });

    test('users', () async {
      Response response = await dio.post("$server/header", data: {}, options: Options(contentType: 'application/json'));
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
    });

    test('session', () async {
      Response setSessionRes = await dio.post("$server/setSession");
      expect(setSessionRes.data["jsessionid"] != null, true);
      expect(setSessionRes.data["name"], "peter");

      Response getSessionRes =
          await dio.post("$server/setSession", options: Options(headers: {"Cookie": "set-cookie=${setSessionRes.data["jsessionid"]}"}));
      expect(getSessionRes.data["name"], "peter");
    });

    tearDown(() {
      dio = null;
    });
  });

  group("formdata", () {
    test('multipart-form-data', () async {
      File file = File(Directory.current.path + "/test/example/20180902193200.jpg");
      FormData formData = FormData();
      formData.fields.add(MapEntry("name", "peter"));
      formData.fields.add(MapEntry("friends", "thor"));
      formData.fields.add(MapEntry("friends", "iron man"));
      formData.fields.add(MapEntry("age", "17"));
      formData.files.add(MapEntry("file", await MultipartFile.fromFile(file.path, filename: "20180902193200.jpg")));
      Response response = await Dio().post('$server/multipart-form-data', data: formData);
      expect(response.data, {
        "name": "peter",
        "friends": ["thor", 'iron man'],
        "file_length": 1,
        "file_bytes_length": await file.length(),
        "age": 17
      });
    });
  });

  group('timeout', () {
    Dio dio;

    setUp(() {
      dio = Dio();
    });

    test('/router-timeout', () async {
      Response response = await dio.get("$server/router-timeout");
      expect(response.data, {'timeout': 10});
    });

    test('/router-timeout-take-effect', () async {
      Response response = await dio.get("$server/router-timeout-take-effect");
      expect(response.data, {'timeout': 5});
    });

    tearDown(() {
      dio = null;
    });
  });
}
