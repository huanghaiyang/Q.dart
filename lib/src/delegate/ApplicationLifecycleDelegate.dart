import 'package:Q/src/Application.dart';
import 'package:Q/src/aware/ApplicationLifecycleAware.dart';

abstract class ApplicationDelegate extends ApplicationLifecycle {
  factory ApplicationDelegate(Application application) => _ApplicationDelegate(application);
}

class _ApplicationDelegate implements ApplicationDelegate {
  final Application application_;

  _ApplicationDelegate(this.application_);

  // 错误处理
  @override
  Future<dynamic> onError(dynamic error, {StackTrace stackTrace}) async {
    print("Q.dart server occured error:" + error.toString());
    if (stackTrace != null) {
      print('Q.dart.server stacktrace:' + stackTrace.toString());
    }
  }

  @override
  Future<dynamic> onConfigure() async {}

  @override
  Future<dynamic> onClose(dynamic prevCloseableResult) async {}

  @override
  Future<dynamic> onStartup() async {}
}
