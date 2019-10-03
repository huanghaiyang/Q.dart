import 'dart:math';

import 'package:Q/src/common/SizeUnitHelper.dart';
import 'package:Q/src/common/SizeUnitType.dart';
import 'package:Q/src/exception/SizeUnitParseException.dart';

final Pattern _SIZE_UNIT_MATCHER = RegExp('^([0-9]+)(([mkgt]b))');

abstract class SizeUnit {
  int get bytes;

  SizeUnitType get type;

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

  _SizeUnit(this.bytes_, this.type_);

  static SizeUnit BYTES(int value) {
    return SizeUnit(value, SizeUnitType.BYTES);
  }

  static SizeUnit KB(double value) {
    return SizeUnit((value * (pow(2, 10))).round(), SizeUnitType.KB);
  }

  static SizeUnit MB(double value) {
    return SizeUnit((value * (pow(2, 20))).round(), SizeUnitType.MB);
  }

  static SizeUnit GB(double value) {
    return SizeUnit((value * (pow(2, 30))).round(), SizeUnitType.GB);
  }

  static SizeUnit TB(double value) {
    return SizeUnit((value * (pow(2, 40))).round(), SizeUnitType.TB);
  }

  static SizeUnit parse(String formattedString) {
    formattedString = formattedString.trim();
    Match match = _SIZE_UNIT_MATCHER.matchAsPrefix(formattedString);
    if (match == null) {
      throw SizeUnitParseException(formattedString: formattedString);
    }
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
      default:
        return null;
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
  String toString() {
    String suffix = SizeUnitHelper.toStr(this.type_);
    switch (type_) {
      case SizeUnitType.KB:
        return '${bytes_ / (pow(2, 10))}${suffix}';
      case SizeUnitType.MB:
        return '${bytes_ / (pow(2, 20))}${suffix}';
      case SizeUnitType.GB:
        return '${bytes_ / (pow(2, 30))}${suffix}';
      case SizeUnitType.TB:
        return '${bytes_ / (pow(2, 40))}${suffix}';
      case SizeUnitType.BYTES:
        return '${bytes_}${suffix}';
      default:
        return this.bytes_.toString();
    }
  }
}
