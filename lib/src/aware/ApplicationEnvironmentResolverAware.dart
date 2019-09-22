abstract class ApplicationEnvironmentResolverAware<T, R> {
  Future<R> resolve(T bootstrapArguments);

  Future<R> get();
}
