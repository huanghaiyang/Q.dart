/// 超时异常
class TimeoutException implements Exception {
  final String message;
  
  TimeoutException(this.message);
  
  @override
  String toString() => 'TimeoutException: $message';
}
