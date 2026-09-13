import 'package:habits/features/habits/0_entity/logical_date.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Traduce instantes a días lógicos en una zona horaria **IANA** concreta
/// (la del perfil del usuario: `Europe/Madrid`, `America/New_York`…).
///
/// Es la única pieza del dominio que conoce zonas horarias. El resto del
/// motor trabaja ya con [LogicalDate], que no tiene zona (§12).
///
/// Reglas que implementa:
///  - el día termina a las 00:00 de la zona del perfil: 23:59 pertenece al
///    día actual, 00:00 al siguiente (§12);
///  - los límites de semana/mes/año se calculan en esa zona (§9);
///  - funciona con DST porque nunca asume que un día dura 24 horas: la
///    aritmética de días se hace sobre [LogicalDate], no sobre instantes
///    (§35).
///
/// La base de datos IANA se carga sola la primera vez que hace falta. Aun
/// así, conviene llamar a [initializeTimezones] al arrancar la app para que
/// esa carga no caiga en el primer frame.
class LogicalCalendar {
  LogicalCalendar(this.timezoneName);

  /// Zona usada cuando el perfil todavía no tiene una o guarda una inválida.
  static const fallbackTimezone = 'UTC';

  final String timezoneName;

  /// Se resuelve de forma perezosa: así construir un calendario (por ejemplo
  /// desde un provider) no obliga a que la base IANA ya esté cargada.
  late final tz.Location _location = TimezoneDatabase.locationOf(timezoneName);

  /// Día lógico al que pertenece [instant] en esta zona.
  LogicalDate dateOf(DateTime instant) {
    final local = tz.TZDateTime.from(instant.toUtc(), _location);
    return LogicalDate(local.year, local.month, local.day);
  }

  /// Instante exacto en que empieza [date] en esta zona. Con DST puede no
  /// existir la medianoche (salto de primavera en algunas zonas); en ese
  /// caso `TZDateTime` devuelve el instante inmediatamente posterior, que es
  /// el comienzo real del día.
  DateTime startOfDayUtc(LogicalDate date) =>
      tz.TZDateTime(_location, date.year, date.month, date.day).toUtc();

  /// Instante exacto de [date] a las [hour]:[minute] en esta zona.
  ///
  /// Es lo que necesitan los recordatorios: "las 21:00" significa las 21:00
  /// de la zona del perfil, no las del dispositivo. Devuelve el
  /// [tz.TZDateTime] para poder programarlo tal cual.
  tz.TZDateTime instantAt(LogicalDate date, int hour, int minute) =>
      tz.TZDateTime(_location, date.year, date.month, date.day, hour, minute);

  /// Lunes de la semana de [date]. La semana va de lunes 00:00 a domingo
  /// 23:59:59 en la zona del perfil (§9).
  LogicalDate startOfWeek(LogicalDate date) =>
      date.addDays(-(date.weekday - DateTime.monday));

  LogicalDate endOfWeek(LogicalDate date) => startOfWeek(date).addDays(6);

  LogicalDate startOfMonth(LogicalDate date) =>
      LogicalDate(date.year, date.month, 1);

  LogicalDate endOfMonth(LogicalDate date) =>
      LogicalDate.normalized(date.year, date.month + 1, 1).previous;

  LogicalDate startOfYear(LogicalDate date) => LogicalDate(date.year, 1, 1);

  LogicalDate endOfYear(LogicalDate date) => LogicalDate(date.year, 12, 31);
}

/// Carga la base de datos IANA embebida en `package:timezone`.
///
/// Es Dart puro (no depende de Flutter), así que vale igual para la app, para
/// los tests de dominio y para los de integración. Idempotente: llamarla
/// varias veces no tiene coste ni efectos.
///
/// No hace falta llamarla explícitamente —[LogicalCalendar] la invoca cuando
/// la necesita—, pero conviene hacerlo al arrancar la app para que la carga
/// no caiga en el primer frame.
void initializeTimezones() {
  if (TimezoneDatabase.isInitialized) return;
  tzdata.initializeTimeZones();
  // `local` se deja en UTC a propósito: el día lógico SIEMPRE se resuelve
  // con la zona del perfil, nunca con la del dispositivo (§12/§13).
  tz.setLocalLocation(tz.getLocation('UTC'));
  TimezoneDatabase._initialized = true;
}

/// Acceso a las zonas IANA, con carga perezosa.
abstract final class TimezoneDatabase {
  static bool _initialized = false;

  static bool get isInitialized => _initialized;

  /// [tz.Location] de un nombre IANA, con degradación a UTC si el nombre no
  /// existe en la base (perfil corrupto, zona retirada del tzdb…). Nunca
  /// lanza: un nombre inválido no debe impedir usar la app.
  static tz.Location locationOf(String name) {
    initializeTimezones();
    try {
      return tz.getLocation(name);
    } catch (_) {
      return tz.getLocation(LogicalCalendar.fallbackTimezone);
    }
  }
}
