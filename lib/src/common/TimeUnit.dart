import 'package:Q/src/common/TimeUnitType.dart';
import 'package:Q/src/common/TimeUnitTypeHelper.dart';
import 'package:Q/src/exception/TimeUnitParseException.dart';

final Pattern _TIME_UNIT_MATCHER = RegExp('^([0-9]+)((us|ms|s|m|d|h))');

abstract class TimeUnit {
  factory TimeUnit(int value, TimeUnitType type) => _TimeUnit(value, type);

  static TimeUnit parse(String formattedString) => _TimeUnit.parse(formattedString);

  static TimeUnit Days(int value) => _TimeUnit.Days(value);

  static TimeUnit Minutes(int value) => _TimeUnit.Minutes(value);

  static TimeUnit Milliseconds(int value) => _TimeUnit.Milliseconds(value);

  static TimeUnit Microseconds(int value) => _TimeUnit.Microseconds(value);

  static TimeUnit Seconds(int value) => _TimeUnit.Seconds(value);

  static TimeUnit Hours(int value) => _TimeUnit.Hours(value);

  Duration get duration;

  int get value;

  TimeUnitType get type;
}

class _TimeUnit implements TimeUnit {
  static TimeUnit Days(int value) {
    return TimeUnit(value, TimeUnitType.DAYS);
  }

  static TimeUnit Minutes(int value) {
    return TimeUnit(value, TimeUnitType.MINUTES);
  }

  static TimeUnit Milliseconds(int value) {
    return TimeUnit(value, TimeUnitType.MILLISECONDS);
  }

  static TimeUnit Microseconds(int value) {
    return TimeUnit(value, TimeUnitType.MICROSECONDS);
  }

  static TimeUnit Seconds(int value) {
    return TimeUnit(value, TimeUnitType.SECONDS);
  }

  static TimeUnit Hours(int value) {
    return TimeUnit(value, TimeUnitType.HOURS);
  }

  static TimeUnit parse(String formattedString) {
    formattedString = formattedString.trim();
    Match match = _TIME_UNIT_MATCHER.matchAsPrefix(formattedString);
    if (match == null) {
      throw TimeUnitParseException(formattedString: formattedString);
    }
    String value = match.group(1);
    String type = match.group(2);
    switch (TimeUnitTypeHelper.toType(type)) {
      case TimeUnitType.DAYS:
        return TimeUnit.Days(int.parse(value));
      case TimeUnitType.MINUTES:
        return TimeUnit.Minutes(int.parse(value));
      case TimeUnitType.SECONDS:
        return TimeUnit.Seconds(int.parse(value));
      case TimeUnitType.MICROSECONDS:
        return TimeUnit.Microseconds(int.parse(value));
      case TimeUnitType.MILLISECONDS:
        return TimeUnit.Milliseconds(int.parse(value));
      case TimeUnitType.HOURS:
        return TimeUnit.Hours(int.parse(value));
      default:
        return null;
    }
  }

  int value_;

  Duration duration_;

  TimeUnitType type_;

  _TimeUnit(this.value_, this.type_) {
    switch (this.type_) {
      case TimeUnitType.DAYS:
        this.duration_ = Duration(days: this.value_);
        break;
      case TimeUnitType.MINUTES:
        this.duration_ = Duration(minutes: this.value_);
        break;
      case TimeUnitType.MILLISECONDS:
        this.duration_ = Duration(milliseconds: this.value_);
        break;
      case TimeUnitType.MICROSECONDS:
        this.duration_ = Duration(microseconds: this.value_);
        break;
      case TimeUnitType.HOURS:
        this.duration_ = Duration(hours: this.value_);
        break;
      default:
        break;
    }
  }

  @override
  TimeUnitType get type {
    return type_;
  }

  @override
  int get value {
    return value_;
  }

  @override
  Duration get duration {
    return duration_;
  }

  @override
  String toString() {
    return '${this.value_}${TimeUnitTypeHelper.toStr(this.type_)}';
  }
}
