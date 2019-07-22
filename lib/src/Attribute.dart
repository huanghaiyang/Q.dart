abstract class Attribute {
  factory Attribute(String name, dynamic value) => _Attribute(name, value);

  String get name;

  dynamic get value;
}

class _Attribute implements Attribute {
  final String name;
  final dynamic value;
  
  _Attribute(this.name, this.value);
}
