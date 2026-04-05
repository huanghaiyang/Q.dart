import 'dart:io';

import 'package:Q/src/Request.dart';
import 'package:Q/src/exception/UnExpectedRequestXmlException.dart';
import 'package:Q/src/resolver/AbstractResolver.dart';
import 'package:Q/src/utils/RequestUtil.dart';

class XmlResolver implements AbstractResolver {
  XmlResolver._();

  static XmlResolver _instance;

  static XmlResolver instance() {
    return _instance ?? (_instance = XmlResolver._());
  }

  @override
  Future<bool> match(HttpRequest req) async {
    ContentType contentType = req.headers.contentType;
    if (contentType == null) return false;
    return contentType.mimeType.toLowerCase().startsWith(RegExp('application/xml'));
  }

  @override
  Future<Request> resolve(HttpRequest req) async {
    String xmlText = await RequestUtil.getRequestBodyString(req);
    try {
      // 这里可以添加XML解析逻辑
      // 暂时只保存原始XML文本
      Request request = Request(data: {'xml': xmlText});
      return request;
    } catch (error) {
      throw UnExpectedRequestXmlException(xml: xmlText, originalException: error as Exception);
    }
  }
}
