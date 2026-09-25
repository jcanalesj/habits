import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habits/app_lifecycle.dart';
import 'package:habits/components/app_notice.dart';
import 'package:habits/features/habits/1_domain/domain.dart';
import 'package:habits/features/habits/2_presentation/providers/habits_providers.dart';
import 'package:habits/localization/l10n.dart';

/// Pide el permiso de notificaciones si aún no está concedido.
///
/// Se llama justo cuando el usuario pone una hora de recordatorio: es el
/// momento en que entiende para qué sirve el permiso, y sin él la hora no
/// haría nada. Si lo deniega, se le dice cómo activarlo en lugar de dejarle
/// creer que el aviso va a llegar.
Future<void> ensureReminderPermission(
  BuildContext context,
  WidgetRef ref,
) async {
  final l10n = context.l10n;
  final notifications = ref.read(notificationsRepositoryProvider);
  try {
    var permission = await notifications.currentPermission();
    if (permission == NotificationPermission.denied) {
      permission = await notifications.requestPermission();
    }
    // Permiso o no, el estado del sistema puede haber cambiado: la Home
    // reprograma y los ajustes se refrescan.
    ref.read(systemStateTickProvider.notifier).bump();
    if (!context.mounted) return;
    if (permission == NotificationPermission.denied) {
      AppNotice.show(
        context,
        message: l10n.notificationsDeniedHint,
        type: AppNoticeType.error,
      );
    }
  } catch (_) {
    // El plugin puede no estar disponible (tests, plataformas sin soporte):
    // el hábito ya se ha guardado y eso es lo importante.
  }
}
