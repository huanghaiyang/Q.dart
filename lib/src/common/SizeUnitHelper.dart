import 'package:Q/src/common/SizeUnitType.dart';

class SizeUnitHelper {
  static SizeUnitType toType(String type) {
    switch (type) {
      case 'kb':
        return SizeUnitType.KB;
      case 'mb':
        return SizeUnitType.MB;
      case 'gb':
        return SizeUnitType.GB;
      case 'tb':
        return SizeUnitType.TB;
    }
  }
}
