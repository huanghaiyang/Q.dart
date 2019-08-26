import 'package:Q/src/Application.dart';
import 'package:Q/src/ApplicationStage.dart';
import 'package:Q/src/aware/CloseableAware.dart';
import 'package:Q/src/delegate/AbstractDelegate.dart';
import 'package:Q/src/delegate/ApplicationLifecycleDelegate.dart';

abstract class ApplicationClosableDelegate extends CloseableAware with AbstractDelegate {
  factory ApplicationClosableDelegate(Application application) => _ApplicationClosableDelegate(application);
}

class _ApplicationClosableDelegate implements ApplicationClosableDelegate {
  final Application application_;

  _ApplicationClosableDelegate(this.application_);

  @override
  Future<dynamic> close() async {
    this.application_.applicationContext.currentStage = ApplicationStage.STOPPING;
    dynamic prevCloseableResult = await this.application_.closeServer();
    await this.application_.getDelegate(ApplicationLifecycleDelegate).onError(prevCloseableResult);
    this.application_.applicationContext.currentStage = ApplicationStage.STOPPED;
    return prevCloseableResult;
  }
}
