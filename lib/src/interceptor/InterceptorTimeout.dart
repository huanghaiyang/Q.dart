typedef InterceptorTimeoutResult = Future<dynamic> Function();

abstract class InterceptorTimeout {
  Duration get timeoutValue;

  InterceptorTimeoutResult get timeoutResult;

  factory InterceptorTimeout(Duration timeoutValue, InterceptorTimeoutResult timeoutResult) =>
      _InterceptorTimeout(timeoutValue, timeoutResult);
}

class _InterceptorTimeout implements InterceptorTimeout {
  final Duration timeoutValue_;

  final InterceptorTimeoutResult timeoutResult_;

  _InterceptorTimeout(this.timeoutValue_, this.timeoutResult_) {
    assert(this.timeoutValue != null, 'timeoutValue must not be null, it should be an [Duration].');
    assert(this.timeoutResult != null, 'timeoutResult must not be null, it should be an [Function].');
  }

  @override
  InterceptorTimeoutResult get timeoutResult {
    return this.timeoutResult_;
  }

  @override
  Duration get timeoutValue {
    return this.timeoutValue_;
  }
}
