class RouterNotFoundOfRouterChain extends Exception {
  factory RouterNotFoundOfRouterChain({String message, int index}) => _RouterNotFoundOfRouterChain(message: message, index: index);
}

class _RouterNotFoundOfRouterChain implements RouterNotFoundOfRouterChain {
  final message;

  final int index;

  _RouterNotFoundOfRouterChain({this.message, this.index});

  String toString() {
    if (message == null) return "Exception: Can not found Router by index '${this.index.toString()}' of a [RouterChain]";
    return "Exception: $message";
  }
}
