typedef RequestTimeoutResult = Future<dynamic> Function();

abstract class RequestTimeout {
  int get timeoutValue;

  RequestTimeoutResult get timeoutResult;

  factory RequestTimeout(int timeoutValue, RequestTimeoutResult timeoutResult) => _RequestTimeout(timeoutValue, timeoutResult);
}

class _RequestTimeout implements RequestTimeout {
  final int timeoutValue_;

  final RequestTimeoutResult timeoutResult_;

  _RequestTimeout(this.timeoutValue_, this.timeoutResult_) {
    assert(this.timeoutValue == null, 'timeoutValue must not be null, it should be an integer value.');
    assert(this.timeoutResult == null, 'timeoutResult must not be null, it should be an Function.');
  }

  @override
  RequestTimeoutResult get timeoutResult {
    return this.timeoutResult_;
  }

  @override
  int get timeoutValue {
    return this.timeoutValue_;
  }
}
