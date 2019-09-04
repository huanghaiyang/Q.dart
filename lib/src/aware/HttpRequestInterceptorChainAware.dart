import 'dart:io';

abstract class HttpRequestInterceptorChainAware<T> {
  Future<dynamic> applyPreHandle(HttpRequest httpRequest, HttpResponse httpResponse, T InterceptorState);

  Future<dynamic> applyPostHandle(HttpRequest httpRequest, HttpResponse httpResponse, T InterceptorState);

  void onError(Error error, {StackTrace stackTrace});
}
