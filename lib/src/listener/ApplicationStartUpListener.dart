import 'package:Q/src/listener/AbstractListener.dart';

typedef ApplicationStartUpCallback = Future<dynamic> Function();

abstract class ApplicationStartUpListener extends AbstractListener<List> {
  factory ApplicationStartUpListener(ApplicationStartUpCallback applicationStartUpCallback) =>
      _ApplicationStartUpListener(applicationStartUpCallback);
}

class _ApplicationStartUpListener implements ApplicationStartUpListener {
  final ApplicationStartUpCallback applicationStartUpCallback;

  _ApplicationStartUpListener(this.applicationStartUpCallback);

  @override
  Future<dynamic> execute(List payload) async {
    return Function.apply(this.applicationStartUpCallback, payload);
  }
}
