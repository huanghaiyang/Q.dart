import 'package:Q/src/listener/AbstractListener.dart';

typedef ApplicationEnvironmentPreparedCallback = Future<dynamic> Function(dynamic environment);

abstract class ApplicationEnvironmentPreparedListener extends AbstractListener<List> {
  factory ApplicationEnvironmentPreparedListener(ApplicationEnvironmentPreparedCallback applicationEnvironmentPreparedCallback) =>
      _ApplicationEnvironmentPreparedListener(applicationEnvironmentPreparedCallback);
}

class _ApplicationEnvironmentPreparedListener implements ApplicationEnvironmentPreparedListener {
  final ApplicationEnvironmentPreparedCallback applicationEnvironmentPreparedCallback;

  _ApplicationEnvironmentPreparedListener(this.applicationEnvironmentPreparedCallback);

  @override
  Future<dynamic> execute(List payload) async {
    return Function.apply(this.applicationEnvironmentPreparedCallback, payload);
  }
}
