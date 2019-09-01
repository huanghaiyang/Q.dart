import 'dart:io';

import 'package:Q/src/Application.dart';
import 'package:Q/src/aware/HttpResponseConverterAware.dart';
import 'package:Q/src/converter/AbstractHttpMessageConverter.dart';
import 'package:Q/src/delegate/AbstractDelegate.dart';

abstract class HttpResponseConverterDelegate extends HttpResponseConverterAware<ContentType, AbstractHttpMessageConverter>
    with AbstractDelegate {
  factory HttpResponseConverterDelegate(Application application) => _HttpResponseConverterDelegate(application);

  factory HttpResponseConverterDelegate.from(Application application) {
    return application.getDelegate(HttpResponseConverterDelegate);
  }
}

class _HttpResponseConverterDelegate implements HttpResponseConverterDelegate {
  final Application application;

  _HttpResponseConverterDelegate(this.application);

  // 替换内置转换器
  @override
  void replaceConverter(ContentType type, AbstractHttpMessageConverter converter) {
    if (this.application.converters.containsKey(type)) {
      this.application.converters[type] = converter;
    }
  }

  @override
  void addConverter(ContentType type, AbstractHttpMessageConverter converter) {
    this.application.converters[type] = converter;
  }
}
