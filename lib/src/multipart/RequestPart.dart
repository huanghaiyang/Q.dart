abstract class RequestPart {
  List<int> get bytes;

  factory RequestPart(List<int> bytes) => _RequestPart(bytes);
}

class _RequestPart implements RequestPart {
  List<int> bytes_;

  _RequestPart(this.bytes_);

  @override
  List<int> get bytes {
    return this.bytes_;
  }
}
