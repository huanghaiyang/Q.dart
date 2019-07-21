import 'dart:io';

import 'package:Q/src/views/AbstractView.dart';

class UnSupportedContentTypeView implements AbstractView {
  @override
  String toRaw(HttpRequest req, HttpResponse res, {Map extra}) {
    return '服务器禁止${extra['unSupported']}类型数据访问';
  }
}
