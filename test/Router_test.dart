import 'dart:io';

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
      dio.Response response = await dio.Dio()
          .get("http://localhost:8081/path_params?age=16&isHero=true&friends=thor&friends=iron man&grandpa");
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
      dio.Response response = await dio.Dio()
          .post("http://localhost:8081/x-www-form-urlencoded?age=16&isHero=true&friends=thor&friends=iron man&grandpa",
              data: {
                'actors': ["Tobey Maguire", "I dont care"]
              },
              options: dio.Options(contentType: ContentType.parse('application/x-www-form-urlencoded')));
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
}
