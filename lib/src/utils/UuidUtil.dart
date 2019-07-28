import 'package:Q/src/Sign.dart';
import 'package:uuid/uuid.dart';

String get uuid5 {
  return Uuid().v5(Uuid.NAMESPACE_URL, APPLICATION_MARK).toString();
}
