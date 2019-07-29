abstract class PathVariablesAware<T> {
  T get pathVariables;

  set pathVariables(T pathVariables);

  dynamic getVariable(String name);

  bool contains(String name);

  void mergePathVariables(T pathVariables);
}
