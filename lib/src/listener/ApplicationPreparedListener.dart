import 'package:Q/src/listener/AbstractListener.dart';

typedef ApplicationPreparedCallback = Future<dynamic> Function();

abstract class ApplicationPreparedListener extends AbstractListener<List> {
  factory ApplicationPreparedListener(ApplicationPreparedCallback applicationPreparedCallback) =>
      _ApplicationPreparedListener(applicationPreparedCallback);
}

class _ApplicationPreparedListener implements ApplicationPreparedListener {
  final ApplicationPreparedCallback applicationPreparedCallback;

  _ApplicationPreparedListener(this.applicationPreparedCallback);

  @override
  Future<dynamic> execute(List payload) async {
    return Function.apply(this.applicationPreparedCallback, payload);
  }
}
