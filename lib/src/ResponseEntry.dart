class ResponseEntry {
  // 请求经过处理后实际的结果
  dynamic result;

  // 通过converter转换后的结果
  dynamic convertedResult;

  ResponseEntry([this.result]);
}
