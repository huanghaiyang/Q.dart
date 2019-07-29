abstract class ResponseEntry {
  // 请求经过处理后实际的结果
  set result(dynamic result);

  // 通过converter转换后的结果
  set convertedResult(dynamic convertedResult);

  set lastConvertedTime(DateTime lastConvertedTime);

  dynamic get result;

  dynamic get convertedResult;

  DateTime get lastConvertedTime;

  factory ResponseEntry([dynamic result]) => _ResponseEntry(result);

  factory ResponseEntry.from(dynamic entry) = _ResponseEntry.from;
}

class _ResponseEntry implements ResponseEntry {
  dynamic result_;

  dynamic convertedResult_;

  DateTime _lastConvertedTime;

  _ResponseEntry([this.result_]);

  factory _ResponseEntry.from(dynamic entry) {
    ResponseEntry responseEntry;
    // 如果执行的结果不是一个ResponseEntry,则将结果封装
    if (!(entry is ResponseEntry)) {
      responseEntry = ResponseEntry(entry);
    } else {
      responseEntry = entry;
    }
    return responseEntry;
  }

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

  @override
  DateTime get lastConvertedTime {
    return this._lastConvertedTime;
  }

  @override
  set lastConvertedTime(DateTime lastConvertedTime) {
    this._lastConvertedTime = lastConvertedTime;
  }
}
