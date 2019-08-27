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
    return Function.apply(this.applicationErrorCallback, payload);
  }
}
