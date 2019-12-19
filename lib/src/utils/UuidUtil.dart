import 'package:uuid/uuid.dart';

String uuid4() {
  return Uuid().v4().toString();
}
