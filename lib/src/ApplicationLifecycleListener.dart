import 'dart:mirrors';

import 'package:Q/src/Application.dart';
import 'package:Q/src/aware/ApplicationListenerAware.dart';
import 'package:Q/src/listener/AbstractListener.dart';
import 'package:Q/src/listener/ApplicationCloseListener.dart';
import 'package:Q/src/listener/ApplicationErrorListener.dart';
import 'package:Q/src/listener/ApplicationListenerType.dart';
import 'package:Q/src/listener/ApplicationStartUpListener.dart';
import 'package:Q/src/listener/ApplicationStartingListener.dart';
import 'package:Q/src/listener/ApplicationEnvironmentPreparedListener.dart';
import 'package:Q/src/listener/ApplicationContextInitializedListener.dart';
import 'package:Q/src/listener/ApplicationPreparedListener.dart';
import 'package:Q/src/listener/ApplicationReadyListener.dart';
import 'package:Q/src/listener/ApplicationFailedListener.dart';

abstract class ApplicationLifecycleListener extends ApplicationListenerAware<AbstractListener, ApplicationListenerType, List> {
  factory ApplicationLifecycleListener(Application application) => _ApplicationLifecycleListener(application);
}

class _ApplicationLifecycleListener implements ApplicationLifecycleListener {
  final Application application;

  Set<ApplicationStartingListener> startingListeners = Set();
  Set<ApplicationEnvironmentPreparedListener> environmentPreparedListeners = Set();
  Set<ApplicationContextInitializedListener> contextInitializedListeners = Set();
  Set<ApplicationPreparedListener> preparedListeners = Set();
  Set<ApplicationStartUpListener> startUpListeners = Set();
  Set<ApplicationReadyListener> readyListeners = Set();
  Set<ApplicationFailedListener> failedListeners = Set();
  Set<ApplicationCloseListener> closeListeners = Set();
  Set<ApplicationErrorListener> errorListeners = Set();

  _ApplicationLifecycleListener(this.application);

  @override
  void addListener(AbstractListener listener) {
    // 遍历所有可能的监听器类型
    if (listener is ApplicationStartingListener) {
      startingListeners.add(listener);
      print('Added ApplicationStartingListener');
    } else if (listener is ApplicationEnvironmentPreparedListener) {
      environmentPreparedListeners.add(listener);
      print('Added ApplicationEnvironmentPreparedListener');
    } else if (listener is ApplicationContextInitializedListener) {
      contextInitializedListeners.add(listener);
      print('Added ApplicationContextInitializedListener');
    } else if (listener is ApplicationPreparedListener) {
      preparedListeners.add(listener);
      print('Added ApplicationPreparedListener');
    } else if (listener is ApplicationStartUpListener) {
      startUpListeners.add(listener);
      print('Added ApplicationStartUpListener');
    } else if (listener is ApplicationReadyListener) {
      readyListeners.add(listener);
      print('Added ApplicationReadyListener');
    } else if (listener is ApplicationFailedListener) {
      failedListeners.add(listener);
      print('Added ApplicationFailedListener');
    } else if (listener is ApplicationCloseListener) {
      closeListeners.add(listener);
      print('Added ApplicationCloseListener');
    } else if (listener is ApplicationErrorListener) {
      errorListeners.add(listener);
      print('Added ApplicationErrorListener');
    } else {
      // 尝试使用反射来检查监听器类型
      print('Unknown listener type: ${listener.runtimeType}');
      print('Listener superinterfaces: ${reflect(listener).type.superinterfaces}');
    }
  }

  @override
  void trigger(ApplicationListenerType type, List payload) {
    print('Triggering event: $type, payload: $payload');
    switch (type) {
      case ApplicationListenerType.STARTING:
        print('Starting listeners count: ${this.startingListeners.length}');
        this.startingListeners.forEach((ApplicationStartingListener listener) {
          listener.execute(payload);
        });
        break;
      case ApplicationListenerType.ENVIRONMENT_PREPARED:
        print('Environment prepared listeners count: ${this.environmentPreparedListeners.length}');
        this.environmentPreparedListeners.forEach((ApplicationEnvironmentPreparedListener listener) {
          listener.execute(payload);
        });
        break;
      case ApplicationListenerType.CONTEXT_INITIALIZED:
        print('Context initialized listeners count: ${this.contextInitializedListeners.length}');
        this.contextInitializedListeners.forEach((ApplicationContextInitializedListener listener) {
          listener.execute(payload);
        });
        break;
      case ApplicationListenerType.PREPARED:
        print('Prepared listeners count: ${this.preparedListeners.length}');
        this.preparedListeners.forEach((ApplicationPreparedListener listener) {
          listener.execute(payload);
        });
        break;
      case ApplicationListenerType.STARTUP:
        print('Startup listeners count: ${this.startUpListeners.length}');
        this.startUpListeners.forEach((ApplicationStartUpListener listener) {
          listener.execute(payload);
        });
        break;
      case ApplicationListenerType.READY:
        print('Ready listeners count: ${this.readyListeners.length}');
        this.readyListeners.forEach((ApplicationReadyListener listener) {
          listener.execute(payload);
        });
        break;
      case ApplicationListenerType.FAILED:
        print('Failed listeners count: ${this.failedListeners.length}');
        this.failedListeners.forEach((ApplicationFailedListener listener) {
          listener.execute(payload);
        });
        break;
      case ApplicationListenerType.CLOSE:
        print('Close listeners count: ${this.closeListeners.length}');
        this.closeListeners.forEach((ApplicationCloseListener listener) {
          listener.execute(payload);
        });
        break;
      case ApplicationListenerType.ERROR:
        print('Error listeners count: ${this.errorListeners.length}');
        this.errorListeners.forEach((ApplicationErrorListener listener) {
          print('Executing error listener: $listener');
          listener.execute(payload);
        });
        break;
      default:
        break;
    }
  }
}
