mixin ApplicationConfigurationResourceValidatorAware<T, R> {
  Future<R> check(T resources);
}
