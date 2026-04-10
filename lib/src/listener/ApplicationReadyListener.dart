import 'package:Q/src/listener/AbstractListener.dart';

typedef ApplicationReadyCallback = Future<dynamic> Function();

abstract class ApplicationReadyListener extends AbstractListener<List> {
  factory ApplicationReadyListener(ApplicationReadyCallback applicationReadyCallback) =>
      _ApplicationReadyListener(applicationReadyCallback);
}

class _ApplicationReadyListener implements ApplicationReadyListener {
  final ApplicationReadyCallback applicationReadyCallback;

  _ApplicationReadyListener(this.applicationReadyCallback);

  @override
  Future<dynamic> execute(List payload) async {
    return Function.apply(this.applicationReadyCallback, payload);
  }
}
