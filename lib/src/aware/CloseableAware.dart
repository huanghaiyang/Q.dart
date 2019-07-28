abstract class CloseableAware<T, F> {
  Future<dynamic> close(T t);

  Future<dynamic> onClose(F f);
}
