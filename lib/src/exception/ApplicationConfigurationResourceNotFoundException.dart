class ApplicationConfigurationResourceNotFoundException extends Exception {
  factory ApplicationConfigurationResourceNotFoundException({String message, dynamic filename}) =>
      _ApplicationConfigurationResourceNotFoundException(message: message, filename: filename);
}

class _ApplicationConfigurationResourceNotFoundException implements ApplicationConfigurationResourceNotFoundException {
  final message;

  final dynamic filename;

  _ApplicationConfigurationResourceNotFoundException({this.message, this.filename});

  String toString() {
    if (message == null) return "Exception: Application bootstrap configuration file '${this.filename.toString()}' not exsist.";
    return "Exception: $message";
  }
}
