import 'dart:io';

import 'package:Q/src/ApplicationConfiguration.dart';
import 'package:Q/src/configure/AbstractConfigure.dart';
import 'package:Q/src/configure/ApplicationConfigurationNames.dart';
import 'package:Q/src/utils/ContentTypeUtil.dart';

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
  Future<dynamic> init(ApplicationConfiguration applicationConfiguration) async {
    defaultProducedType_ =
        ContentTypeUtil.reflect(ContentType.parse(applicationConfiguration.get(APPLICATION_RESPONSE_DEFAULT_PRODUCED_TYPE)));
  }
}
