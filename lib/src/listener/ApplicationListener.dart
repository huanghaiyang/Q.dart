import 'package:Q/src/listener/ApplicationCloseListener.dart';
import 'package:Q/src/listener/ApplicationErrorListener.dart';
import 'package:Q/src/listener/ApplicationStartUpListener.dart';

abstract class ApplicationListener {
  static close(ApplicationCloseCallback applicationCloseCallback) {
    return ApplicationCloseListener(applicationCloseCallback);
  }

  static error(ApplicationErrorCallback applicationErrorCallback) {
    return ApplicationErrorListener(applicationErrorCallback);
  }

  static startUp(ApplicationStartUpCallback applicationStartUpCallback) {
    return ApplicationStartUpListener(applicationStartUpCallback);
  }
}
