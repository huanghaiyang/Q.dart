abstract class InterceptorContext<T, R> {
  dynamic setState(T key, R state);

  dynamic getState(T key);
}
