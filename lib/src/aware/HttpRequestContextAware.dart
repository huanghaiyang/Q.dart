import 'dart:io';

import 'package:Q/src/interceptor/HttpRequestInterceptorState.dart';

abstract class HttpRequestContextAware<T> {
  Future<T> createContext(HttpRequest httpRequest, HttpResponse httpResponse, {HttpRequestInterceptorState interceptorState});
}
