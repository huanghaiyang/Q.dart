import 'package:Q/src/Application.dart';
import 'package:Q/src/aware/ApplicationLifecycleAware.dart';
import 'package:Q/src/delegate/AbstractDelegate.dart';

abstract class ApplicationLifecycleDelegate extends ApplicationLifecycle with AbstractDelegate {
  factory ApplicationLifecycleDelegate(Application application) => _ApplicationLifecycleDelegate(application);
}

class _ApplicationLifecycleDelegate implements ApplicationLifecycleDelegate {
  final Application application_;

  _ApplicationLifecycleDelegate(this.application_);

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
