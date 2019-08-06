import 'package:dio/dio.dart' as dio;
import 'package:test/test.dart';

void main() {
  group('Router', () {
    test('urequest_no_content_typesers', () async {
      dio.Response response = await dio.Dio().post("http://localhost:8081/request_no_content_type");
      expect(response.data, {"contentType": null});
    });

    test('application_json', () async {
      dio.Response response = await dio.Dio().post("http://localhost:8081/application_json");
      expect(response.data, null);
    });

    test('application_json', () async {
      dio.Response response = await dio.Dio().post("http://localhost:8081/application_json", data: {"name": "peter"});
      expect(response.data, {"name": "peter"});
    });

//    test('application_json', () async {
//      bool exception = false;
//      try {
//        await dio.Dio().post("http://localhost:8081/application_json", data: "peter");
//      } catch (error) {
//        exception = true;
//      }
//      expect(exception, true);
//    });

    test('path_params', () async {
      dio.Response response =
          await dio.Dio().get("http://localhost:8081/path_params?age=16&isHero=true&friends=thor&friends=iron man");
      expect(response.data, {
        "age": 16,
        "isHero": true,
        "friends": ["thor", 'iron man']
      });
    });
  });
}
