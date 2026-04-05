import 'dart:io';
import 'dart:typed_data';

import 'package:Q/src/utils/ListUtil.dart';

class RequestUtil {
  /// 获取请求体的字节数据
  static Future<Uint8List> getRequestBodyBytes(HttpRequest req) async {
    List<List<int>> byteArrays = await req.toList();
    List<int> concatenated = concat(byteArrays);
    return Uint8List.fromList(concatenated);
  }

  /// 获取请求体的字符串数据
  static Future<String> getRequestBodyString(HttpRequest req) async {
    Uint8List bytes = await getRequestBodyBytes(req);
    return String.fromCharCodes(bytes);
  }
}
