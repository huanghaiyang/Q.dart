abstract class ApplicationLifecycle<T> {
  Future<dynamic> onConfigure();

  Future<dynamic> onStartup();

  Future<dynamic> onError(dynamic error, {StackTrace stackTrace});

  Future<dynamic> onClose(dynamic prevCloseableResult);
}
