abstract class ApplicationConfigurationResourceFinderAware<T, S, R> {
  Future<R> search(T type, S environment);
}
