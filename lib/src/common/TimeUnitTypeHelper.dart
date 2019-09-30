import 'package:Q/src/common/TimeUnitType.dart';

class TimeUnitTypeHelper {
  static TimeUnitType toType(String type) {
    switch (type) {
      case 'm':
        return TimeUnitType.MINUTES;
      case 's':
        return TimeUnitType.SECONDS;
      case 'ms':
        return TimeUnitType.MICROSECONDS;
      case 'us':
        return TimeUnitType.MILLISECONDS;
      case 'h':
        return TimeUnitType.HOURS;
      case 'd':
        return TimeUnitType.DAYS;
      default:
        return null;
    }
  }

  static String toStr(TimeUnitType type) {
    switch (type) {
      case TimeUnitType.DAYS:
        return 'd';
      case TimeUnitType.MICROSECONDS:
        return 'ms';
      case TimeUnitType.MILLISECONDS:
        return 'us';
      case TimeUnitType.MINUTES:
        return 'm';
      case TimeUnitType.HOURS:
        return 'h';
      case TimeUnitType.SECONDS:
        return 's';
      default:
        return null;
    }
  }
}
