abstract class HttpRequestHandlerAware<T, R> {
  void replaceHandler(T httpStatus, R handlerAdapter);

  void addHandler(T httpStatus, R handlerAdapter);
}
