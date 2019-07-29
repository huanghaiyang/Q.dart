abstract class PathVariablesAware<T> {
  T get pathVariables;

  dynamic getVariable(String name);

  bool contains(String name);
}
