abstract class HttpResponseConverterAware<R, T> {
  void addConverter(R type, T converter);

  void replaceConverter(R type, T converter);
}
