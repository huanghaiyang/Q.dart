import 'dart:io';

class Router {
  String path;
  Function dispatcher;
  Map params;
  String method;

  Router(this.path, this.method, this.dispatcher, [this.params]);

  Future<bool> match(HttpRequest request) async {
    return true;
  }

  static get(String path, Function dispatcher, [Map params]) {
    return new Router(path, 'get', dispatcher, params);
  }

  static post(String path, Function dispatcher, [Map params]) {
    return new Router(path, 'post', dispatcher, params);
  }

  static put(String path, Function dispatcher, [Map params]) {
    return new Router(path, 'put', dispatcher, params);
  }

  static delete(String path, Function dispatcher, [Map params]) {
    return new Router(path, 'delete', dispatcher, params);
  }
}
