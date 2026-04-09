import 'dart:io';

import 'package:Q/Q.dart';
import 'package:Q/src/multipart/MultipartValueMap.dart';
import 'package:dio/dio.dart' as dio;
import 'package:test/test.dart';

const server = 'http://localhost:8081';

void main() {
  Application application;

  String csrfToken;

  setUpAll(() async {
    application = Application()
      ..args(['--application.environment=dev', '--application.resourceDir=/test/example/resources']);
    await application.init();
    // 注册 multipart-form-data 路由
    application.post('/multipart-form-data', (Context context, [HttpRequest req, HttpResponse res]) async {
      var data = context.request.data;
      // 返回实际文件大小
      int fileBytesLength = 0;
      if (data is MultipartValueMap && data.containsKey('file')) {
        print('data.get(\"file\"): ${data.get("file")}');
        print('data.get(\"file\") type: ${data.get("file").runtimeType}');
        final files = data.get('file');
        if (files is List && files.isNotEmpty) {
          print('files[0]: ${files[0]}');
          print('files[0] type: ${files[0].runtimeType}');
          final file = files.first;
          if (file is MultipartFile) {
            print('file.size: ${file.size}');
            fileBytesLength = file.size;
          }
        }
      }
      return {
        "name": data is MultipartValueMap ? data.getFirstValue('name') : null,
        "friends": data is MultipartValueMap ? data.getValues('friends') : null,
        "file_length": data is MultipartValueMap && data.containsKey('file') ? 1 : 0,
        "file_bytes_length": fileBytesLength,
        "age": int.tryParse(data is MultipartValueMap ? data.getFirstValue('age')?.toString() ?? '' : '')
      };
    });
    // 启动服务器
    application.listen(8081);
    // 等待应用启动完成
    await Future.delayed(Duration(milliseconds: 500));
  });

  tearDownAll(() async {
    if (application != null) {
      try {
        await application.close();
      } catch (e) {
        // 忽略关闭时的错误
      }
      application = null;
    }
  });

  group('Pressure tests', () {
    test('100 multipart request ', () async {
      for (int index = 0; index < 1; index++) {
        print('pressure task ${index}');
        File file = File(Directory.current.path + "/test/example/20180902193200.jpg");
        dio.FormData formData = dio.FormData();
        formData.fields.add(MapEntry("name", "peter_${index}"));
        formData.fields.add(MapEntry("friends", "thor"));
        formData.fields.add(MapEntry("friends", "iron man"));
        formData.fields.add(MapEntry("age", "17"));
        formData.files.add(MapEntry("file", await dio.MultipartFile.fromFile(file.path, filename: "20180902193200.jpg")));
        // 发送 POST 请求
        dio.Response response = await dio.Dio().post('$server/multipart-form-data', data: formData);
        expect(response.data, {
          "name": "peter_${index}",
          "friends": ["thor", 'iron man'],
          "file_length": 1,
          "file_bytes_length": await file.length(),
          "age": 17
        });
        // 添加小延迟，避免系统负载过高
        await Future.delayed(Duration(milliseconds: 10));
      }
    });
  });
}
