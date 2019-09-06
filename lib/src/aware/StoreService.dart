abstract class StoreService<T, R> {
  dynamic setState(T key, R state);

  dynamic getState(T key);
}
