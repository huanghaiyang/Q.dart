import 'dart:mirrors';

import 'package:Q/src/Application.dart';
import 'package:Q/src/aware/ApplicationListenerAware.dart';
import 'package:Q/src/listener/AbstractListener.dart';
import 'package:Q/src/listener/ApplicationCloseListener.dart';
import 'package:Q/src/listener/ApplicationErrorListener.dart';
import 'package:Q/src/listener/ApplicationListenerType.dart';
import 'package:Q/src/listener/ApplicationStartUpListener.dart';

abstract class ApplicationLifecycleListener extends ApplicationListenerAware<AbstractListener, ApplicationListenerType, List> {
  factory ApplicationLifecycleListener(Application application) => _ApplicationLifecycleListener(application);
}

class _ApplicationLifecycleListener implements ApplicationLifecycleListener {
  final Application application;

  Set<ApplicationStartUpListener> startUpListeners = Set();

  Set<ApplicationCloseListener> closeListeners = Set();

  Set<ApplicationErrorListener> errorListeners = Set();

  _ApplicationLifecycleListener(this.application);

  @override
  void addListener(AbstractListener listener) {
    Type type = reflect(listener).type.superinterfaces.first.reflectedType;
    switch (type) {
      case ApplicationStartUpListener:
        startUpListeners.add(listener);
        break;
      case ApplicationCloseListener:
        closeListeners.add(listener);
        break;
      case ApplicationErrorListener:
        errorListeners.add(listener);
        break;
      default:
        break;
    }
  }

  @override
  void trigger(ApplicationListenerType type, List payload) {
    switch (type) {
      case ApplicationListenerType.CLOSE:
        this.closeListeners.forEach((ApplicationCloseListener applicationCloseListener) {
          applicationCloseListener.execute(payload);
        });
        break;
      case ApplicationListenerType.STARTUP:
        this.startUpListeners.forEach((ApplicationStartUpListener applicationStartUpListener) {
          applicationStartUpListener.execute(payload);
        });
        break;
      case ApplicationListenerType.ERROR:
        this.errorListeners.forEach((ApplicationErrorListener applicationErrorListener) {
          applicationErrorListener.execute(payload);
        });
        break;
      default:
        break;
    }
  }
}
