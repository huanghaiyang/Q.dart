abstract class ApplicationArgumentsParsedAware<T, R> {
  void args(T arguments);

  T get arguments;

  R get parsedArguments;
}
