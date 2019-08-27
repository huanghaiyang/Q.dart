import 'package:Q/src/listener/AbstractListener.dart';

typedef ApplicationCloseCallback = Future<dynamic> Function(Future<dynamic> prevCloseableResult);

abstract class ApplicationCloseListener extends AbstractListener<List> {
  factory ApplicationCloseListener(ApplicationCloseCallback applicationCloseCallback) =>
      _ApplicationCloseListener(applicationCloseCallback);
}

class _ApplicationCloseListener implements ApplicationCloseListener {
  final ApplicationCloseCallback applicationCloseCallback;

  _ApplicationCloseListener(this.applicationCloseCallback);

  @override
  Future<dynamic> execute(List payload) async {
    return Function.apply(this.applicationCloseCallback, payload);
  }
}
