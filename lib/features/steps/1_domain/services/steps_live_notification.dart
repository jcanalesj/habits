/// Textos de la notificación, ya localizados por la app. Los que llevan
/// `{n}` son plantillas: el lado nativo sustituye el número al vuelo.
class StepsLiveNotificationLabels {
  const StepsLiveNotificationLabels({
    required this.title,
    required this.kcal,
    required this.km,
    required this.goal,
    required this.goalReached,
    required this.channelName,
    required this.channelDescription,
  });

  /// «{n} pasos».
  final String title;

  /// «{n} kcal».
  final String kcal;

  /// «{n} km».
  final String km;

  /// «Objetivo {n}».
  final String goal;
  final String goalReached;
  final String channelName;
  final String channelDescription;

  Map<String, Object?> toMap() => {
    'title': title,
    'kcal': kcal,
    'km': km,
    'goal': goal,
    'goalReached': goalReached,
    'channelName': channelName,
    'channelDescription': channelDescription,
  };
}

/// Todo lo que el servicio nativo necesita para contar y pintar por su
/// cuenta: a quién pertenece el libro de pasos, el objetivo, la zancada y
/// el peso para las estimaciones, la zona del día lógico y el idioma.
class StepsLiveNotificationConfig {
  const StepsLiveNotificationConfig({
    required this.userId,
    required this.goal,
    required this.strideMeters,
    required this.weightKg,
    required this.timezone,
    required this.locale,
    required this.labels,
  });

  final String userId;
  final int goal;
  final double strideMeters;
  final double weightKg;
  final String timezone;
  final String locale;
  final StepsLiveNotificationLabels labels;

  Map<String, Object?> toMap() => {
    'userId': userId,
    'goal': goal,
    'strideMeters': strideMeters,
    'weightKg': weightKg,
    'timezone': timezone,
    'locale': locale,
    'labels': labels.toMap(),
  };
}

enum StepsLiveNotificationResult {
  started,

  /// El sistema no deja mostrar notificaciones de la app.
  notificationsDenied,

  /// Sin permiso de actividad física no hay nada que contar.
  activityDenied,

  /// Plataforma sin esta función (iOS, web, escritorio).
  unsupported,
}

/// Notificación fija con los pasos de hoy ("pasos en directo"). Solo
/// Android: es un servicio en primer plano que sigue leyendo el sensor con
/// la app cerrada y comparte el libro de pasos con [StepLedger].
abstract class StepsLiveNotification {
  Future<bool> isSupported();
  Future<bool> isEnabled();
  Future<StepsLiveNotificationResult> start(StepsLiveNotificationConfig config);

  /// Objetivo, perfil o idioma nuevos. No arranca nada si está apagada.
  Future<void> update(StepsLiveNotificationConfig config);
  Future<void> stop();
}
