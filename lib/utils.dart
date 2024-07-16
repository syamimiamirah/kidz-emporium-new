import 'package:intl/intl.dart';

class Utils {
  // Formats DateTime to a string with both date and time in local time
  static String toDateTime(DateTime dateTime) {
    final date = DateFormat.yMMMEd().format(dateTime); // Formats the date part
    final time = DateFormat.Hm().format(dateTime); // Formats the time part
    return '$date $time'; // Combines date and time
  }

  // Formats DateTime to a string with just the date in local time
  static String toDate(DateTime dateTime) {
    final date = DateFormat.yMMMEd().format(dateTime); // Formats the date part
    return '$date'; // Returns the formatted date
  }

  // Formats DateTime to a string with just the time in local time
  static String toTime(DateTime dateTime) {
    final time = DateFormat.Hm().format(dateTime); // Formats the time part
    return '$time'; // Returns the formatted time
  }

  // Removes the time part from DateTime and returns a new DateTime with time set to midnight
  static DateTime removeTime(DateTime dateTime) =>
      DateTime(dateTime.year, dateTime.month, dateTime.day);

  // Converts DateTime to an ISO 8601 string in UTC
  static String formatDateTimeToString(DateTime dateTime) {
    return dateTime.toUtc().toIso8601String();
  }

  // Parses an ISO 8601 string to DateTime, converting from UTC to local time
  static DateTime parseStringToDateTime(String dateString) {
    try {
      // Parses the date string as UTC
      final DateTime parsedDateTime = DateTime.parse(dateString).toUtc();
      // Converts the parsed UTC DateTime to local time
      final DateTime localDateTime = parsedDateTime.toLocal();
      return localDateTime;
    } catch (e) {
      // Prints error message if parsing fails
      print('Error parsing date string: $dateString');
      // Rethrows the exception
      throw e;
    }
  }
}
