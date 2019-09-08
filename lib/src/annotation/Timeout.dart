import 'package:Q/src/request/RequestTimeout.dart';

String REQUEST_TIME_OUT_VALUE = 'timeoutValue';
String REQUEST_TIME_OUT_RESULT = 'timeoutResult';

@pragma('vm:entry-point')
class Timeout {
  final int timeoutValue;
  final RequestTimeoutResult timeoutResult;

  @pragma('vm:entry-point')
  const Timeout(this.timeoutValue, {this.timeoutResult});
}
