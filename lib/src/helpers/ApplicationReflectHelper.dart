import 'dart:mirrors';

import 'package:Q/src/delegate/Delegate.dart';

class ApplicationReflectHelper {
  static dynamic getDelegate(Type delegateType, Iterable<AbstractDelegate> iterable) {
    for (AbstractDelegate abstractDelegate in iterable) {
      if (delegateType == reflect(abstractDelegate).type.superinterfaces.first.reflectedType) {
        return abstractDelegate;
      }
    }
  }
}
