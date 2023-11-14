import 'package:intl/intl.dart';

class HomeWeeksProgressDateHelper {
  static String fromDateToDateFormat({
    required DateTime fromDate,
    required DateTime toDate,
    required String localeName,
  }) {
    final fromDateMonthName = DateFormat('MMMM', localeName).format(fromDate);
    final toDateMonthName = DateFormat('MMMM', localeName).format(toDate);

    return '${fromDate.day} $fromDateMonthName -'
        ' ${toDate.day} $toDateMonthName ${toDate.year}';
  }
}
