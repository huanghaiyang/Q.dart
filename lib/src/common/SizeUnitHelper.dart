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
      default:
        return null;
    }
  }

  static String toStr(SizeUnitType type) {
    switch (type) {
      case SizeUnitType.KB:
        return 'kb';
      case SizeUnitType.BYTES:
        return 'bytes';
      case SizeUnitType.GB:
        return 'gb';
      case SizeUnitType.MB:
        return 'mb';
      case SizeUnitType.TB:
        return 'tb';
      default:
        return null;
    }
  }
}
