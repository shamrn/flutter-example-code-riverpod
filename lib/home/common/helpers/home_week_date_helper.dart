import 'package:intl/intl.dart';

class HomeWeekDateHelper {
  static DateFormat serverDateFormat = DateFormat('yyyy-MM-dd');

  static String dateToServerDate(DateTime date) {
    return serverDateFormat.format(date);
  }

  static DateTime subtractOneWeek(DateTime date) {
    return date.subtract(const Duration(days: DateTime.daysPerWeek));
  }

  static DateTime addOneWeek(DateTime date) {
    return date.add(const Duration(days: DateTime.daysPerWeek));
  }

  static DateTime getStartWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  static DateTime getEndWeek(DateTime date) {
    return date.add(Duration(
      days: DateTime.daysPerWeek - date.weekday,
    ));
  }
}
