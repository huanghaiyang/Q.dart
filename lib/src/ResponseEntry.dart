abstract class ResponseEntry {
  // 请求经过处理后实际的结果
  set result(dynamic result);

  // 通过converter转换后的结果
  set convertedResult(dynamic convertedResult);

  get result;

  get convertedResult;

  factory ResponseEntry([dynamic result]) => _ResponseEntry(result);
}

class _ResponseEntry implements ResponseEntry {
  dynamic result_;

  dynamic convertedResult_;

  _ResponseEntry([this.result_]);

  @override
  set convertedResult(dynamic convertedResult) {
    this.convertedResult_ = convertedResult;
  }

  @override
  set result(dynamic result) {
    this.result_ = result;
  }

  @override
  get convertedResult {
    return this.convertedResult_;
  }

  @override
  get result {
    return this.result_;
  }
}
