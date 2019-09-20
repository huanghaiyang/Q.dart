abstract class ApplicationBootstrapArgsResolverAware<S, R, T> {
  Future<dynamic> resolve();

  Future<S> define(S argParser, R configurationMapper);

  Future<dynamic> get(String key);

  Map<String, dynamic> get transformedResult;

  T get parsedResult;
}
