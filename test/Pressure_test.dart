import 'dart:io';

import 'package:dio/dio.dart';
import 'package:test/test.dart';
import 'package:Q/src/utils/AsyncUtil.dart';

const server = 'http://localhost:8081';

void main() {
  group('Pressure tests', () {
    test('1000 * 100 multipart request ', () async {
      List times = List<int>.from(AsyncUtil.range(0, 1000 * 100));
      times.forEach((index) async {
        print('pressure task ${index}');
        File file = File(Directory.current.path + "/test/example/20180902193200.jpg");
        FormData formData = FormData();
        formData.fields.add(MapEntry("name", "peter_${index}"));
        formData.fields.add(MapEntry("friends", "thor"));
        formData.fields.add(MapEntry("friends", "iron man"));
        formData.fields.add(MapEntry("age", "17"));
        formData.files.add(MapEntry("file", await MultipartFile.fromFile(file.path, filename: "20180902193200.jpg")));
        Response response = await Dio().post('$server/multipart-form-data', data: formData);
        expect(response.data, {
          "name": "peter_${index}",
          "friends": ["thor", 'iron man'],
          "file_length": 1,
          "file_bytes_length": await file.length(),
          "age": 17
        });
      });
    });
  });
}
