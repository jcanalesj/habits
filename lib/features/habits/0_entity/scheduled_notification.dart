/// Una notificación local puntual de una herramienta (tarea con hora, fin
/// de un pomodoro). A diferencia de [HabitReminder] no es una ocurrencia
/// calculada: es un instante concreto ya resuelto.
class ScheduledNotification {
  const ScheduledNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.whenUtc,
    required this.payload,
    this.silent = false,
  });

  /// Id estable para el sistema (ver [HabitReminder.stableNotificationId]).
  final int id;
  final String title;
  final String body;

  /// Instante en UTC. La zona ya se ha aplicado al calcularlo.
  final DateTime whenUtc;

  /// Identificador propio (p. ej. el id de la tarea). El repositorio lo
  /// etiqueta con el prefijo de su herramienta para distinguirlo de los
  /// recordatorios de hábitos.
  final String payload;

  /// Sin sonido (el usuario lo ha desactivado en la herramienta).
  final bool silent;

  @override
  bool operator ==(Object other) =>
      other is ScheduledNotification &&
      other.id == id &&
      other.title == title &&
      other.body == body &&
      other.whenUtc == whenUtc &&
      other.payload == payload &&
      other.silent == silent;

  @override
  int get hashCode => Object.hash(id, title, body, whenUtc, payload, silent);
}
