typedef RequestTimeoutResult = Future<dynamic> Function();

abstract class RequestTimeout {
  factory RequestTimeout(int timeoutValue, RequestTimeoutResult timeoutResult) => _RequestTimeout(timeoutValue, timeoutResult);
}

class _RequestTimeout implements RequestTimeout {
  final int timeoutValue;
  final RequestTimeoutResult timeoutResult;

  _RequestTimeout(this.timeoutValue, this.timeoutResult) {
    assert(this.timeoutValue == null, 'timeoutValue must not be null, it should be an integer value.');
    assert(this.timeoutResult == null, 'timeoutResult must not be null, it should be an Function.');
  }
}
