import 'package:Q/src/ApplicationConfiguration.dart';
import 'package:Q/src/common/TimeUnit.dart';
import 'package:Q/src/configure/AbstractConfigure.dart';
import 'package:Q/src/configure/ApplicationConfigurationNames.dart';
import 'package:Q/src/interceptor/InterceptorTimeout.dart';

abstract class InterceptorConfigure extends AbstractConfigure {
  InterceptorTimeout get timeout;

  factory InterceptorConfigure() => _InterceptorConfigure();
}

class _InterceptorConfigure implements InterceptorConfigure {
  InterceptorTimeout _timeout;

  @override
  InterceptorTimeout get timeout {
    return this._timeout;
  }

  @override
  Future<dynamic> init(ApplicationConfiguration applicationConfiguration) async {
    _timeout = InterceptorTimeout((applicationConfiguration.get(APPLICATION_INTERCEPTOR_TIMEOUT) as TimeUnit).duration, () {
      return Future.value("bad request with interceptor timeout.");
    });
  }
}
