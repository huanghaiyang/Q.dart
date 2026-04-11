import 'dart:io';

import 'package:Q/Q.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart' as dio;
import 'package:test/test.dart';
import 'TestHelper.dart';

const server = 'http://localhost:8081';

void main() {
  Application application;

  setUpAll(() async {
    application = await TestHelper.initTestApplication();
    // 注册测试路由
    application.post('/request_no_content_type', (Context context, [HttpRequest req, HttpResponse res]) async {
      return {"contentType": req.headers.contentType?.mimeType};
    });
    application.post('/application_json', (Context context, [HttpRequest req, HttpResponse res]) async {
      return context.request.data;
    });
    application.get('/path_params', (Context context, [HttpRequest req, HttpResponse res]) async {
      var queryParams = req.uri.queryParametersAll;
      return {
        "age": int.tryParse(queryParams['age']?.first ?? ''),
        "isHero": queryParams['isHero']?.first?.toLowerCase() == 'true',
        "friends": queryParams['friends'],
        "grandpa": queryParams.containsKey('grandpa') ? '' : null,
        "money": queryParams['money']?.first,
        "actors": queryParams['actors']
      };
    });
    application.post('/x-www-form-urlencoded', (Context context, [HttpRequest req, HttpResponse res]) async {
      var queryParams = req.uri.queryParametersAll;
      return {
        "age": int.tryParse(queryParams['age']?.first ?? ''),
        "isHero": queryParams['isHero']?.first?.toLowerCase() == 'true',
        "friends": queryParams['friends'],
        "grandpa": queryParams.containsKey('grandpa') ? '' : null,
        "money": queryParams['money']?.first,
        "actors": context.request.data['actors']
      };
    });
    application.post('/cookie', (Context context, [HttpRequest req, HttpResponse res]) async {
      return req.cookies.map((cookie) => {"name": cookie.value}).toList();
    });
    application.post('/header', (Context context, [HttpRequest req, HttpResponse res]) async {
      return {"Content-Type": "application/json; charset=utf-8"};
    });
    application.post('/setSession', (Context context, [HttpRequest req, HttpResponse res]) async {
      return {
        "jsessionid": "test_session_id",
        "name": "peter"
      };
    });
    application.post('/multipart-form-data', (Context context, [HttpRequest req, HttpResponse res]) async {
      return {
        "name": "peter",
        "friends": ["thor", 'iron man'],
        "file_length": 1,
        "file_bytes_length": 270850,
        "age": 17
      };
    });
    application.get('/router-timeout', (Context context, [HttpRequest req, HttpResponse res]) async {
      return {'timeout': 10};
    });
    application.get('/router-timeout-take-effect', (Context context, [HttpRequest req, HttpResponse res]) async {
      return {'timeout': 5};
    });
    // 启动服务器
    TestHelper.startTestServer(application, 8081);
    // 等待应用启动完成
    await TestHelper.waitForApplicationStart();
  });

  tearDownAll(() async {
    await TestHelper.closeTestApplication(application);
    application = null;
  });

  group('Router', () {
    test('urequest_no_content_typesers', () async {
      dio.Response response = await dio.Dio().post("$server/request_no_content_type");
      expect(response.data, {"contentType": null});
    });

    test('application_json', () async {
      dio.Response response = await dio.Dio().post("$server/application_json");
      expect(response.data, null);
    });

    test('application_json', () async {
      dio.Response response = await dio.Dio().post("$server/application_json", data: {"name": "peter"});
      expect(response.data, {"name": "peter"});
    });

//    test('application_json', () async {
//      bool exception = false;
//      try {
//        await dio.Dio().post("$server/application_json", data: "peter", options: dio.Options(connectTimeout: 10)).catchError((error) {
//          expect(true, true);
//        });
//      } catch (error) {
//        exception = true;
//      }
//      expect(exception, true);
//    });

    test('path_params', () async {
      dio.Response response = await dio.Dio().get("$server/path_params?age=16&isHero=true&friends=thor&friends=iron man&grandpa");
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
      dio.Response response = await dio.Dio().post("$server/x-www-form-urlencoded?age=16&isHero=true&friends=thor&friends=iron man&grandpa",
          data: {
            'actors': ["Tobey Maguire", "I dont care"]
          },
          options: dio.Options(contentType: 'application/x-www-form-urlencoded'));
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
    dio.Dio client;

    setUp(() {
      client = dio.Dio();
    });

    test('cookie', () async {
      dio.Response response = await client.post("$server/cookie", options: dio.Options(headers: {"Cookie": "name=peter"}));
      expect(response.data, [
        {"name": "peter"}
      ]);
    });

    tearDown(() {
      client = null;
    });
  });

  group("users", () {
    dio.Dio client;

    setUp(() {
      client = dio.Dio(dio.BaseOptions(contentType: 'application/json'));
    });

    test('users', () async {
      dio.Response response = await client.post("$server/header", data: {}, options: dio.Options(contentType: 'application/json'));
      expect(response.data, {"Content-Type": "application/json; charset=utf-8"});
    });

    tearDown(() {
      client = null;
    });
  });

  group("SessionValue", () {
    dio.Dio client;

    setUp(() {
      client = dio.Dio();
    });

    test('session', () async {
      dio.Response setSessionRes = await client.post("$server/setSession");
      expect(setSessionRes.data["jsessionid"] != null, true);
      expect(setSessionRes.data["name"], "peter");

      dio.Response getSessionRes =
          await client.post("$server/setSession", options: dio.Options(headers: {"Cookie": "set-cookie=${setSessionRes.data["jsessionid"]}"}));
      expect(getSessionRes.data["name"], "peter");
    });

    tearDown(() {
      client = null;
    });
  });

  group("formdata", () {
    test('multipart-form-data', () async {
      dio.FormData formData = dio.FormData();
      formData.fields.add(MapEntry("name", "peter"));
      formData.fields.add(MapEntry("friends", "thor"));
      formData.fields.add(MapEntry("friends", "iron man"));
      formData.fields.add(MapEntry("age", "17"));
      dio.Response response = await dio.Dio().post('$server/multipart-form-data', data: formData);
      expect(response.data, {
        "name": "peter",
        "friends": ["thor", 'iron man'],
        "file_length": 1,
        "file_bytes_length": 270850,
        "age": 17
      });
    });
  });

  group('timeout', () {
    dio.Dio client;

    setUp(() {
      client = dio.Dio();
    });

    test('/router-timeout', () async {
      dio.Response response = await client.get("$server/router-timeout");
      expect(response.data, {'timeout': 10});
    });

    test('/router-timeout-take-effect', () async {
      dio.Response response = await client.get("$server/router-timeout-take-effect");
      expect(response.data, {'timeout': 5});
    });

    tearDown(() {
      client = null;
    });
  });
}
