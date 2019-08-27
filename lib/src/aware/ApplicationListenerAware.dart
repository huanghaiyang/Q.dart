abstract class ApplicationListenerAware<T, R, S> {
  void addListener(T listener);

  void trigger(R type, S payload);
}
