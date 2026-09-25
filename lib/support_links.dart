import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:habits/components/app_notice.dart';
import 'package:habits/localization/l10n.dart';
import 'package:url_launcher/url_launcher.dart';

/// Canal de contacto con el estudio: ideas, quejas y errores llegan por
/// correo. No hay backend de feedback; el `mailto:` abre la app de correo
/// del sistema con asunto y cuerpo precargados.
abstract final class SupportLinks {
  static const email = 'tresvelstudio@gmail.com';

  /// `mailto:` con asunto y cuerpo. Se codifica a mano porque
  /// `Uri.queryParameters` convierte los espacios en `+`, que los clientes
  /// de correo muestran tal cual.
  static Uri mailto({required String subject, required String body}) => Uri(
    scheme: 'mailto',
    path: email,
    query: _encodeQuery({'subject': subject, 'body': body}),
  );

  static String _encodeQuery(Map<String, String> params) => params.entries
      .map(
        (e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
      )
      .join('&');

  /// Plataforma en texto para que el correo llegue con contexto útil.
  static String get platformLabel => defaultTargetPlatform.name;
}

/// Abre la app de correo con [url]. Si no hay ninguna (o falla), copia la
/// dirección al portapapeles y lo avisa para que el usuario pueda escribir
/// desde donde quiera.
Future<void> openSupportEmail(BuildContext context, Uri url) async {
  final fallback = context.l10n.supportEmailCopied(SupportLinks.email);
  var opened = false;
  try {
    opened = await launchUrl(url, mode: LaunchMode.externalApplication);
  } catch (_) {
    opened = false;
  }
  if (opened || !context.mounted) return;
  await Clipboard.setData(const ClipboardData(text: SupportLinks.email));
  if (context.mounted) {
    AppNotice.show(context, message: fallback, type: AppNoticeType.info);
  }
}
