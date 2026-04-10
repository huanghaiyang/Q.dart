import 'package:Q/src/listener/AbstractListener.dart';

typedef ApplicationContextInitializedCallback = Future<dynamic> Function();

abstract class ApplicationContextInitializedListener extends AbstractListener<List> {
  factory ApplicationContextInitializedListener(ApplicationContextInitializedCallback applicationContextInitializedCallback) =>
      _ApplicationContextInitializedListener(applicationContextInitializedCallback);
}

class _ApplicationContextInitializedListener implements ApplicationContextInitializedListener {
  final ApplicationContextInitializedCallback applicationContextInitializedCallback;

  _ApplicationContextInitializedListener(this.applicationContextInitializedCallback);

  @override
  Future<dynamic> execute(List payload) async {
    return Function.apply(this.applicationContextInitializedCallback, payload);
  }
}
