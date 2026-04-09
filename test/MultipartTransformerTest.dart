import 'dart:convert';
import 'dart:io';
import 'package:test/test.dart';
import 'package:Q/src/multipart/MultipartTransformer.dart';
import 'package:Q/src/multipart/MultipartValueMap.dart';
import 'package:Q/src/query/MultipartFile.dart';
import 'package:Q/src/query/CommonValue.dart';

void main() {
  group('MultipartTransformer', () {
    test('should parse multipart form data with text fields', () async {
      // 模拟 multipart/form-data 请求
      final boundary = '----WebKitFormBoundary7MA4YWxkTrZu0gW'; // 4个横杠
      final requestData = '------WebKitFormBoundary7MA4YWxkTrZu0gW\r\nContent-Disposition: form-data; name="name"\r\n\r\nJohn Doe\r\n------WebKitFormBoundary7MA4YWxkTrZu0gW\r\nContent-Disposition: form-data; name="age"\r\n\r\n30\r\n------WebKitFormBoundary7MA4YWxkTrZu0gW--'; // 6个横杠 + 6个横杠 + 6个横杠--
      
      final data = utf8.encode(requestData);
      
      // 创建模拟请求
      final mockRequest = MockHttpRequest()
        ..headers.contentType = ContentType.parse('multipart/form-data; boundary=$boundary');
      
      // 转换数据
      final result = await transform(mockRequest, data);
      
      // 验证结果
      expect(result['name'], isNotNull);
      expect(result['name'].length, 1);
      expect((result['name'][0] as CommonValue).value, 'John Doe');
      
      expect(result['age'], isNotNull);
      expect(result['age'].length, 1);
      expect((result['age'][0] as CommonValue).value, '30');
    });

    test('should parse multipart form data with file', () async {
      // 模拟 multipart/form-data 请求（包含文件）
      final boundary = '----WebKitFormBoundary7MA4YWxkTrZu0gW'; // 4个横杠
      final fileContent = 'Hello, World!';
      final fileBytes = utf8.encode(fileContent);
      final base64File = base64.encode(fileBytes);
      
      final requestData = '''------WebKitFormBoundary7MA4YWxkTrZu0gW
Content-Disposition: form-data; name="file"; filename="test.txt"
Content-Type: text/plain

$fileContent
------WebKitFormBoundary7MA4YWxkTrZu0gW--'''; // 6个横杠 + 6个横杠--
      
      final data = utf8.encode(requestData);
      
      // 创建模拟请求
      final mockRequest = MockHttpRequest()
        ..headers.contentType = ContentType.parse('multipart/form-data; boundary=$boundary');
      
      // 转换数据
      final result = await transform(mockRequest, data);
      
      // 验证结果
      expect(result['file'], isNotNull);
      expect(result['file'].length, 1);
      
      final file = result['file'][0] as MultipartFile;
      expect(file.name, 'file');
      expect(file.originalName, 'test.txt');
      expect('${file.contentType}', '${ContentType.parse('text/plain')}');
      expect(utf8.decode(file.bytes), fileContent);
    });

    test('should handle multiple fields with same name', () async {
      // 模拟 multipart/form-data 请求（多个同名字段）
      final boundary = '----WebKitFormBoundary7MA4YWxkTrZu0gW'; // 4个横杠
      final requestData = '''------WebKitFormBoundary7MA4YWxkTrZu0gW
Content-Disposition: form-data; name="hobby"

Reading
------WebKitFormBoundary7MA4YWxkTrZu0gW
Content-Disposition: form-data; name="hobby"

Gaming
------WebKitFormBoundary7MA4YWxkTrZu0gW--'''; // 6个横杠 + 6个横杠 + 6个横杠--
      
      final data = utf8.encode(requestData);
      
      // 创建模拟请求
      final mockRequest = MockHttpRequest()
        ..headers.contentType = ContentType.parse('multipart/form-data; boundary=$boundary');
      
      // 转换数据
      final result = await transform(mockRequest, data);
      
      // 验证结果
      expect(result['hobby'], isNotNull);
      expect(result['hobby'].length, 2);
      expect((result['hobby'][0] as CommonValue).value, 'Reading');
      expect((result['hobby'][1] as CommonValue).value, 'Gaming');
    });

    test('should handle array fields', () async {
      // 模拟 multipart/form-data 请求（数组字段）
      final boundary = '----WebKitFormBoundary7MA4YWxkTrZu0gW'; // 4个横杠
      final requestData = '''------WebKitFormBoundary7MA4YWxkTrZu0gW
Content-Disposition: form-data; name="friends[0]"

Alice
------WebKitFormBoundary7MA4YWxkTrZu0gW
Content-Disposition: form-data; name="friends[1]"

Bob
------WebKitFormBoundary7MA4YWxkTrZu0gW--'''; // 6个横杠 + 6个横杠 + 6个横杠--
      
      final data = utf8.encode(requestData);
      
      // 创建模拟请求
      final mockRequest = MockHttpRequest()
        ..headers.contentType = ContentType.parse('multipart/form-data; boundary=$boundary');
      
      // 转换数据
      final result = await transform(mockRequest, data, fixNameSuffixIfArray: true);
      
      // 验证结果
      expect(result['friends'], isNotNull);
      expect(result['friends'].length, 2);
    });

    test('should handle non-UTF8 data with base64 encoding', () async {
      // 模拟包含非 UTF-8 数据的请求
      final boundary = '----WebKitFormBoundary7MA4YWxkTrZu0gW'; // 4个横杠
      // 创建包含非 UTF-8 字节的数据
      final nonUtf8Data = [0xFF, 0xFE, 0xFD]; // 无效的 UTF-8 序列
      final base64Data = base64.encode(nonUtf8Data);
      
      final requestData = '''------WebKitFormBoundary7MA4YWxkTrZu0gW
Content-Disposition: form-data; name="binary"

''';
      final endPart = '''
------WebKitFormBoundary7MA4YWxkTrZu0gW--'''; // 6个横杠--
      final data = [...utf8.encode(requestData), ...nonUtf8Data, ...utf8.encode(endPart)];
      
      // 创建模拟请求
      final mockRequest = MockHttpRequest()
        ..headers.contentType = ContentType.parse('multipart/form-data; boundary=$boundary');
      
      // 转换数据
      final result = await transform(mockRequest, data);
      
      // 验证结果
      expect(result['binary'], isNotNull);
      expect(result['binary'].length, 1);
      // 非 UTF-8 数据应该被 base64 编码
      expect((result['binary'][0] as CommonValue).value, base64Data);
    });

    test('should return empty map for invalid boundary', () async {
      // 模拟无效的 multipart 数据
      final requestData = 'Invalid multipart data';
      final data = utf8.encode(requestData);
      
      // 创建模拟请求（无 boundary）
      final mockRequest = MockHttpRequest()
        ..headers.contentType = ContentType.parse('multipart/form-data');
      
      // 转换数据
      final result = await transform(mockRequest, data);
      
      // 验证结果
      expect(result.isEmpty, true);
    });
  });
}

// 模拟 HttpRequest 类
class MockHttpRequest implements HttpRequest {
  final HttpHeaders _headers = MockHttpHeaders();
  
  @override
  HttpHeaders get headers => _headers;
  
  // 其他未实现的方法
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

// 模拟 HttpHeaders 类
class MockHttpHeaders implements HttpHeaders {
  ContentType _contentType;
  
  @override
  set contentType(ContentType value) => _contentType = value;
  
  @override
  ContentType get contentType => _contentType;
  
  // 其他未实现的方法
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
