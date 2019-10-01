class RouterNotFoundOfRouterChainException extends Exception {
  factory RouterNotFoundOfRouterChainException({String message, int index}) =>
      _RouterNotFoundOfRouterChainException(message: message, index: index);
}

class _RouterNotFoundOfRouterChainException implements RouterNotFoundOfRouterChainException {
  final message;

  final int index;

  _RouterNotFoundOfRouterChainException({this.message, this.index});

  String toString() {
    if (message == null) return "Exception: Can not found Router by index '${this.index.toString()}' of a [RouterChain]";
    return "Exception: $message";
  }
}
