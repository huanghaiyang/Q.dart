import 'dart:io';

abstract class HttpRequestContextAware<T> {
  Future<T> createContext(HttpRequest httpRequest, HttpResponse httpResponse);
}
