import 'dart:io';

abstract class HttpRequestInterceptorChainAware<T> {
  Future<dynamic> applyPreHandle(HttpRequest httpRequest, HttpResponse httpResponse, T interceptorChain);

  Future<dynamic> applyPostHandle(HttpRequest httpRequest, HttpResponse httpResponse, T interceptorChain);
}
