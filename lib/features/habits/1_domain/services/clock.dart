/// Reloj inyectable. El dominio nunca llama a `DateTime.now()` directamente
/// (§34): así los tests pueden fijar 23:59, 00:00, un cambio de mes, de año
/// o de horario de verano sin depender del reloj de la máquina.
abstract interface class Clock {
  /// Instante actual **en UTC**. La conversión a día lógico la hace
  /// [LogicalCalendar] con la zona IANA del perfil.
  DateTime nowUtc();
}

class SystemClock implements Clock {
  const SystemClock();

  @override
  DateTime nowUtc() => DateTime.now().toUtc();
}

/// Reloj fijo para tests y para congelar un instante durante un cálculo.
class FixedClock implements Clock {
  FixedClock(DateTime instant) : _instant = instant.toUtc();

  DateTime _instant;

  set instant(DateTime value) => _instant = value.toUtc();

  @override
  DateTime nowUtc() => _instant;
}
