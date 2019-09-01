import 'package:Q/src/Application.dart';
import 'package:Q/src/ApplicationStage.dart';
import 'package:Q/src/aware/CloseableAware.dart';
import 'package:Q/src/delegate/AbstractDelegate.dart';
import 'package:Q/src/delegate/ApplicationHttpServerDelegate.dart';
import 'package:Q/src/delegate/ApplicationLifecycleDelegate.dart';

abstract class ApplicationClosableDelegate extends CloseableAware with AbstractDelegate {
  factory ApplicationClosableDelegate(Application application) => _ApplicationClosableDelegate(application);

  factory ApplicationClosableDelegate.from(Application application) {
    return application.getDelegate(ApplicationClosableDelegate);
  }
}

class _ApplicationClosableDelegate implements ApplicationClosableDelegate {
  final Application application;

  _ApplicationClosableDelegate(this.application);

  @override
  Future<dynamic> close() async {
    this.application.applicationContext.currentStage = ApplicationStage.STOPPING;
    dynamic prevCloseableResult = await ApplicationHttpServerDelegate.from(application).close();
    ApplicationLifecycleDelegate applicationLifecycleDelegate = ApplicationLifecycleDelegate.from(this.application);
    await applicationLifecycleDelegate.onClose(prevCloseableResult);
    this.application.applicationContext.currentStage = ApplicationStage.STOPPED;
    return prevCloseableResult;
  }
}
