import 'package:Q/src/common/SizeUnitHelper.dart';
import 'package:Q/src/common/SizeUnitType.dart';

final Pattern _SIZE_UNIT_MATCHER = RegExp('^([0-9]+)(([mkgt]b))');

abstract class SizeUnit {
  int get bytes;

  SizeUnitType get type;

  String get originalString;

  factory SizeUnit(int bytes, SizeUnitType type) => _SizeUnit(bytes, type);

  static SizeUnit BYTES(int value) => _SizeUnit.BYTES(value);

  static SizeUnit KB(double value) => _SizeUnit.KB(value);

  static SizeUnit MB(double value) => _SizeUnit.MB(value);

  static SizeUnit GB(double value) => _SizeUnit.GB(value);

  static SizeUnit TB(double value) => _SizeUnit.TB(value);

  static SizeUnit parse(String formattedString) => _SizeUnit.parse(formattedString);
}

class _SizeUnit implements SizeUnit {
  int bytes_;

  SizeUnitType type_;

  String originalString_;

  _SizeUnit(this.bytes_, this.type_);

  static SizeUnit BYTES(int value) {
    return SizeUnit(value, SizeUnitType.BYTES);
  }

  static SizeUnit KB(double value) {
    return SizeUnit((value * (2 ^ 10)).round(), SizeUnitType.KB);
  }

  static SizeUnit MB(double value) {
    return SizeUnit((value * (2 ^ 20)).round(), SizeUnitType.MB);
  }

  static SizeUnit GB(double value) {
    return SizeUnit((value * (2 ^ 30)).round(), SizeUnitType.GB);
  }

  static SizeUnit TB(double value) {
    return SizeUnit((value * (2 ^ 40)).round(), SizeUnitType.TB);
  }

  static SizeUnit parse(String formattedString) {
    formattedString = formattedString.trim();
    Match match = _SIZE_UNIT_MATCHER.matchAsPrefix(formattedString);
    String value = match.group(1);
    String type = match.group(2);
    switch (SizeUnitHelper.toType(type)) {
      case SizeUnitType.KB:
        return SizeUnit.KB(double.parse(value));
      case SizeUnitType.MB:
        return SizeUnit.MB(double.parse(value));
      case SizeUnitType.GB:
        return SizeUnit.GB(double.parse(value));
      case SizeUnitType.TB:
        return SizeUnit.TB(double.parse(value));
      case SizeUnitType.BYTES:
        return SizeUnit.BYTES(int.parse(value));
    }
  }

  @override
  int get bytes {
    return bytes_;
  }

  @override
  SizeUnitType get type {
    return type_;
  }

  @override
  String get originalString {
    return originalString_;
  }

  @override
  String toString() {
    switch (type_) {
      case SizeUnitType.KB:
        return '${bytes_ / (2 ^ 10)}kb';
      case SizeUnitType.MB:
        return '${bytes_ / (2 ^ 20)}mb';
      case SizeUnitType.GB:
        return '${bytes_ / (2 ^ 30)}gb';
      case SizeUnitType.TB:
        return '${bytes_ / (2 ^ 40)}tb';
      case SizeUnitType.BYTES:
        return '${bytes_}bytes';
    }
  }
}
