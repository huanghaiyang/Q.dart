import 'dart:io';

List<int> CR = '\r'.codeUnits;

List<int> LF = '\n'.codeUnits;

List<int> HYPHEN = '-'.codeUnits;

List<int> FIRST_BOUNDARY_PREFIX = List()..addAll(HYPHEN)..addAll(HYPHEN);

String HEADER_SEPARATOR = "\r\n";

// 从请求头的请求类型中读取boundary
List<int> boundary(HttpRequest req) {
  ContentType contentType = req.headers.contentType;
  if (contentType != null) {
    String boundary = contentType.parameters['boundary'];
    if (boundary != null) {
      return boundary.codeUnits;
    }
  }
  return null;
}

// 数据组合
List<int> concat(List<List<int>> byteArrays) {
  int length = 0;
  for (List<int> byteArray in byteArrays) {
    length += byteArray.length;
  }
  List<int> result = List(length);
  length = 0;
  for (List<int> byteArray in byteArrays) {
    result.setRange(length, length + byteArray.length, byteArray);
    length += byteArray.length;
  }
  return result;
}
