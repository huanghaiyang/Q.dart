import 'package:Q/src/MimeTypes.dart';
import 'package:Q/src/Router.dart';
import 'package:Q/src/converter/AbstractHttpMessageConverter.dart';
import 'package:Q/src/converter/JSONHttpMessageConverter.dart';

class ResponseEntry {
  // 所属路由
  Router router;

  // 请求经过处理后实际的结果
  dynamic result;

  // 默认json数据转换
  AbstractHttpMessageConverter converter = JSONHttpMessageConverter();

  ResponseEntry({this.result, this.converter, this.router}) {
    if (this.converter == null) {
      if (this.router.mimeType != MimeTypes.JSON) {
        this.converter = this.router.app.converters[this.router.mimeType];
      }
    }
  }

  Future convert() async {
    return this.converter.convert(result);
  }
}
