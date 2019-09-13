import 'package:Q/src/interceptor/InterceptorTimeout.dart';

abstract class InterceptorConfigure {
  InterceptorTimeout get timeout;

  factory InterceptorConfigure() => _InterceptorConfigure();
}

class _InterceptorConfigure implements InterceptorConfigure {
  InterceptorTimeout _timeout;

  @override
  InterceptorTimeout get timeout {
    return this._timeout;
  }
}
