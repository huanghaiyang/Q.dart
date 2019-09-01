import 'package:Q/src/Application.dart';
import 'package:Q/src/aware/HttpRequestHandlerAware.dart';
import 'package:Q/src/delegate/AbstractDelegate.dart';
import 'package:Q/src/handler/HandlerAdapter.dart';

abstract class HttpRequestHandlerDelegate extends HttpRequestHandlerAware<int, HandlerAdapter> with AbstractDelegate {
  factory HttpRequestHandlerDelegate(Application application) => _HttpRequestHandlerDelegate(application);

  factory HttpRequestHandlerDelegate.from(Application application) {
    return application.getDelegate(HttpRequestHandlerDelegate);
  }
}

class _HttpRequestHandlerDelegate implements HttpRequestHandlerDelegate {
  final Application application;

  _HttpRequestHandlerDelegate(this.application);

  @override
  void addHandler(int httpStatus, HandlerAdapter handlerAdapter) {
    this.application.handlers[httpStatus] = handlerAdapter;
  }

  // 替换内置默认的handler
  @override
  void replaceHandler(int httpStatus, HandlerAdapter handlerAdapter) {
    if (this.application.handlers.containsKey(httpStatus)) {
      this.application.handlers[httpStatus] = handlerAdapter;
    }
  }
}
