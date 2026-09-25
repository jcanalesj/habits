import 'package:flutter/widgets.dart';
import 'package:habits/components/app_notice.dart';
import 'package:habits/env.dart';
import 'package:habits/localization/l10n.dart';
import 'package:url_launcher/url_launcher.dart';

/// Páginas legales publicadas en Firebase Hosting (`public/`).
abstract final class LegalLinks {
  static Uri get privacyPolicy => Uri.parse('${Env.publicSiteUrl}/privacy');
  static Uri get terms => Uri.parse('${Env.publicSiteUrl}/terms');
  static Uri get deleteAccount =>
      Uri.parse('${Env.publicSiteUrl}/delete-account');
}

/// Abre [url] en el navegador del sistema y avisa si no se puede.
Future<void> openExternalLink(BuildContext context, Uri url) async {
  final message = context.l10n.linkOpenFailed;
  var opened = false;
  try {
    opened = await launchUrl(url, mode: LaunchMode.externalApplication);
  } catch (_) {
    opened = false;
  }
  if (!opened && context.mounted) {
    AppNotice.show(context, message: message, type: AppNoticeType.error);
  }
}
