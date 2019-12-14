class SideEffectModelReflectFunctionParameterNotMatchClassFieldException extends Exception {
  factory SideEffectModelReflectFunctionParameterNotMatchClassFieldException({String message, String name}) =>
      _SideEffectModelReflectFunctionParameterNotMatchClassFieldException(message: message, name: name);
}

class _SideEffectModelReflectFunctionParameterNotMatchClassFieldException
    implements SideEffectModelReflectFunctionParameterNotMatchClassFieldException {
  final message;

  final String name;

  _SideEffectModelReflectFunctionParameterNotMatchClassFieldException({this.message, this.name});

  String toString() {
    if (message == null) return "Exception: The field named: '${this.name}' not found.";
    return "Exception: $message";
  }
}
