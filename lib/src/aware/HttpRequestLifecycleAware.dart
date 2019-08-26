abstract class HttpRequestLifeCycleAware<T> {
  Future<dynamic> onBeforeConverter(T context);

  Future<dynamic> onAfterConverter(T context);

  Future<dynamic> onBeforeInterceptorsBefore(T context);

  Future<dynamic> onBeforeInterceptorsPost(T context);

  Future<dynamic> onAfterInterceptorsBefore(T context);

  Future<dynamic> onAfterInterceptorsPOst(T context);

  Future<dynamic> onBeforeResolver(T context);

  Future<dynamic> onAfterResolver(T context);

  Future<dynamic> onBeforeMiddlewareBefore(T context);

  Future<dynamic> onBeforeMiddlewarePost(T context);

  Future<dynamic> onAfterMiddlewareBefore(T context);

  Future<dynamic> onAfterMiddlewarePost(T context);

  Future<dynamic> onMiddleware(T context);

  Future<dynamic> onMiddlewareError(T context, dynamic error, {StackTrace stackTrace});
}
