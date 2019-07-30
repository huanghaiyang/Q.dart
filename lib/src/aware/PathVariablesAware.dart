abstract class PathVariablesAware<T> {
  T get pathVariables;

  set pathVariables(T pathVariables);

  dynamic getPathVariable(String name);

  bool containsPathVariable(String name);

  void mergePathVariables(T pathVariables);

  List<String> pathVariableNames();
}
