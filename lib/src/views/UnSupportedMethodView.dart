import 'dart:io';

import 'package:Q/src/views/AbstractView.dart';

class UnSupportedMethodView implements AbstractView {
  @override
  String toRaw(HttpRequest req, HttpResponse res, {Map extra}) {
    return '服务器禁止${extra['unSupported']}请求类型访问';
  }
}
