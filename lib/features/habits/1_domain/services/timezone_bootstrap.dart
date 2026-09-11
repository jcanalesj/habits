// Punto de entrada público para cargar la base de zonas horarias IANA.
//
// La implementación vive junto a [LogicalCalendar], que es quien la usa y
// quien la carga de forma perezosa si nadie lo ha hecho antes.
export 'logical_calendar.dart' show initializeTimezones;
