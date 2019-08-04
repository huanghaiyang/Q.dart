import 'package:Q/src/exception/IllegalArgumentException.dart';
import 'package:Q/src/interceptor/AbstractInterceptor.dart';

class InterceptorHelper {
  static bool canRegistry(Iterable<AbstractInterceptor> interceptors) {
    if (interceptors == null) {
      throw IllegalArgumentException(message: '(Iterable<AbstractInterceptor> interceptors) is emptry.');
    }
    if (!(interceptors is List || interceptors is Set)) {
      throw IllegalArgumentException(
          message:
              '(Iterable<AbstractInterceptor> interceptors) type should be List<AbstractInterceptor> or Set<AbstractInterceptor>');
    }
    return true;
  }
}
