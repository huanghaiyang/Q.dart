import 'dart:io';

abstract class HttpRequestResolverAware<T, R> {
  Future<T> matchResolver(HttpRequest req);

  Future<R> resolveRequest(HttpRequest req);
}
