import 'dart:io';

import 'package:Q/src/configure/AbstractConfigure.dart';

abstract class HttpResponseConfigure extends AbstractConfigure {
  factory HttpResponseConfigure() => _HttpResponseConfigure();

  // 默认返回结果的类型
  ContentType get defaultProducedType;
}

class _HttpResponseConfigure implements HttpResponseConfigure {
  _HttpResponseConfigure();

  ContentType defaultProducedType_ = ContentType.json;

  @override
  ContentType get defaultProducedType {
    return this.defaultProducedType_;
  }

  @override
  Future<dynamic> init() async {}
}
