import 'package:Q/src/Application.dart';
import 'package:Q/src/Context.dart';
import 'package:Q/src/aware/HttpRequestLifecycleAware.dart';
import 'package:Q/src/delegate/AbstractDelegate.dart';

abstract class HttpRequestLifecycleDelegate extends HttpRequestLifeCycleAware<Context> with AbstractDelegate {
  factory HttpRequestLifecycleDelegate(Application application) => _HttpRequestLifecycleDelegate(application);

  factory HttpRequestLifecycleDelegate.from(Application application) {
    return application.getDelegate(HttpRequestLifecycleDelegate);
  }
}

class _HttpRequestLifecycleDelegate implements HttpRequestLifecycleDelegate {
  final Application application_;

  _HttpRequestLifecycleDelegate(this.application_);

  @override
  Future<dynamic> onBeforeConverter(Context context) {}

  @override
  Future<dynamic> onAfterResolver(Context context) {}

  @override
  Future<dynamic> onBeforeResolver(Context context) {}

  @override
  Future<dynamic> onAfterInterceptorsPOst(Context context) {}

  @override
  Future<dynamic> onAfterInterceptorsBefore(Context context) {}

  @override
  Future<dynamic> onBeforeInterceptorsPost(Context context) {}

  @override
  Future<dynamic> onBeforeInterceptorsBefore(Context context) {}

  @override
  Future<dynamic> onAfterConverter(Context context) {}

  @override
  Future<dynamic> onAfterMiddlewarePost(Context context) {}

  @override
  Future<dynamic> onAfterMiddlewareBefore(Context context) {}

  @override
  Future<dynamic> onBeforeMiddlewarePost(Context context) {}

  @override
  Future<dynamic> onBeforeMiddlewareBefore(Context context) {}

  @override
  Future<dynamic> onMiddleware(Context context) {}

  @override
  Future<dynamic> onMiddlewareError(Context context, dynamic error, {StackTrace stackTrace}) {}
}
