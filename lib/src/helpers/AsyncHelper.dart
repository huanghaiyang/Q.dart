import 'dart:async';

class AsyncHelper {
  static Future timeout(Duration duration, Future task, Function onTimeout) async {
    Completer completer = Completer();
    completer.complete(task);
    Future future = completer.future.timeout(duration, onTimeout: onTimeout);
    return future;
  }
}
