abstract class ApplicationBootstrapArgsResolverAware<S, R> {
  Future<dynamic> resolve();

  Future<S> define(S argParser, R configurationMapper);

  Future<dynamic> get(String key);
}
