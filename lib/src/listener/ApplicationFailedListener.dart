import 'package:Q/src/listener/AbstractListener.dart';

typedef ApplicationFailedCallback = Future<dynamic> Function(dynamic error, {StackTrace stackTrace});

abstract class ApplicationFailedListener extends AbstractListener<List> {
  factory ApplicationFailedListener(ApplicationFailedCallback applicationFailedCallback) =>
      _ApplicationFailedListener(applicationFailedCallback);
}

class _ApplicationFailedListener implements ApplicationFailedListener {
  final ApplicationFailedCallback applicationFailedCallback;

  _ApplicationFailedListener(this.applicationFailedCallback);

  @override
  Future<dynamic> execute(List payload) async {
    // 处理命名参数
    if (payload.length > 1 && payload[1] is StackTrace) {
      return Function.apply(this.applicationFailedCallback, [payload[0]], {#stackTrace: payload[1]});
    } else {
      return Function.apply(this.applicationFailedCallback, [payload[0]]);
    }
  }
}
