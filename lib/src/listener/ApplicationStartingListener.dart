import 'package:Q/src/listener/AbstractListener.dart';

typedef ApplicationStartingCallback = Future<dynamic> Function();

abstract class ApplicationStartingListener extends AbstractListener<List> {
  factory ApplicationStartingListener(ApplicationStartingCallback applicationStartingCallback) =>
      _ApplicationStartingListener(applicationStartingCallback);
}

class _ApplicationStartingListener implements ApplicationStartingListener {
  final ApplicationStartingCallback applicationStartingCallback;

  _ApplicationStartingListener(this.applicationStartingCallback);

  @override
  Future<dynamic> execute(List payload) async {
    return Function.apply(this.applicationStartingCallback, payload);
  }
}
