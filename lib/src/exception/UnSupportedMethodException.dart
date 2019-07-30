class UnSupportedMethodException extends Exception {
  factory UnSupportedMethodException({String message, String method}) => _UnSupportedMethodException(message: message, method: method);
}

class _UnSupportedMethodException implements UnSupportedMethodException {
  final String message;
  final String method;

  _UnSupportedMethodException({this.message, this.method});

  String toString() {
    if (message == null) return "Exception: 服务器禁止${method}请求类型访问";
    return "Exception: $message";
  }
}
