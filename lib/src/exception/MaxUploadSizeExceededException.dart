class MaxUploadSizeExceededException extends Exception {
  factory MaxUploadSizeExceededException({String message, int maxUploadSize, int uploadSize}) =>
      _MaxUploadSizeExceededException(message: message, maxUploadSize: maxUploadSize, uploadSize: uploadSize);
}

class _MaxUploadSizeExceededException implements MaxUploadSizeExceededException {
  final String message;

  final int maxUploadSize;

  final int uploadSize;

  _MaxUploadSizeExceededException({this.message, this.maxUploadSize, this.uploadSize});

  String toString() {
    if (message == null) {
      return "Exception: Maximum upload size " +
          (maxUploadSize >= 0 ? "of $maxUploadSize bytes " : "") +
          "exceeded, upload size $uploadSize bytes.";
    }
    return "Exception: $message";
  }
}
