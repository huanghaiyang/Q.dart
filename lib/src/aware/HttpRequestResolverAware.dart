import 'dart:io';

abstract class HttpRequestResolverAware<T, R, O> {
  Future<T> matchResolver(HttpRequest req);

  Future<R> resolveRequest(HttpRequest req);

  void addResolver(O type, T resolver);
}
