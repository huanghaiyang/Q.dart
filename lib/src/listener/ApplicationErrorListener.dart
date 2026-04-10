import 'package:Q/src/listener/AbstractListener.dart';

typedef ApplicationErrorCallback = Future<dynamic> Function(dynamic error, {StackTrace stackTrace});

abstract class ApplicationErrorListener extends AbstractListener<List> {
  factory ApplicationErrorListener(ApplicationErrorCallback applicationErrorCallback) =>
      _ApplicationErrorListener(applicationErrorCallback);
}

class _ApplicationErrorListener implements ApplicationErrorListener {
  final ApplicationErrorCallback applicationErrorCallback;

  _ApplicationErrorListener(this.applicationErrorCallback);

  @override
  Future<dynamic> execute(List payload) async {
    // 直接调用回调函数，不使用 Function.apply
    if (payload.length > 1 && payload[1] is StackTrace) {
      return this.applicationErrorCallback(payload[0], stackTrace: payload[1]);
    } else {
      return this.applicationErrorCallback(payload[0]);
    }
  }
}
