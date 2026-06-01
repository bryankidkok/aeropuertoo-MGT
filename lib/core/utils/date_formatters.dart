import 'package:intl/intl.dart';

/// Utilidades de formateo de fechas.
/// NOTA: initializeDateFormatting('es', null) debe llamarse en main() antes
/// de usar cualquier método con locale español.
class DateFormatters {
  DateFormatters._();

  // Formatters SIN locale (seguros de usar como static final)
  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  static final DateFormat _timeFormat = DateFormat('HH:mm');
  static final DateFormat _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');
  static final DateFormat _isoFormat = DateFormat('yyyy-MM-dd');

  // Formatters CON locale 'es' → se crean lazy para evitar
  // LocaleDataException si initializeDateFormatting no se llamó aún.
  static DateFormat get _fullDateFormat =>
      DateFormat("EEEE, d 'de' MMMM yyyy", 'es');
  static DateFormat get _monthDayFormat => DateFormat('d MMM', 'es');

  static String date(DateTime date) => _dateFormat.format(date);
  static String time(DateTime date) => _timeFormat.format(date);
  static String dateTime(DateTime date) => _dateTimeFormat.format(date);
  static String isoDate(DateTime date) => _isoFormat.format(date);

  static String fullDate(DateTime date) {
    try {
      return _fullDateFormat.format(date);
    } catch (_) {
      // Fallback si el locale no está listo todavía
      return _dateFormat.format(date);
    }
  }

  static String monthDay(DateTime date) {
    try {
      return _monthDayFormat.format(date);
    } catch (_) {
      return _dateFormat.format(date);
    }
  }

  static DateTime? parseDate(String date) {
    try {
      return _dateFormat.parse(date);
    } catch (_) {
      return null;
    }
  }

  static String duration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours}h ${minutes}min';
  }
}
