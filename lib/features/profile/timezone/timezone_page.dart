import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habits/features/auth/2_presentation/controllers/auth_controller.dart';
import 'package:habits/features/auth/2_presentation/providers/auth_providers.dart';
import 'package:habits/features/habits/2_presentation/providers/habits_providers.dart';
import 'package:habits/localization/l10n.dart';
import 'package:habits/theme/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:timezone/timezone.dart' as tz;

final timezoneAutomaticProvider = StreamProvider.autoDispose<bool>((ref) {
  final userId = ref.watch(authControllerProvider).value?.id;
  if (userId == null) return Stream.value(true);
  return ref
      .watch(userProfileRepositoryProvider)
      .watchTimezoneAutomatic(userId);
});

typedef _ZoneOption = ({String city, String id, String flag});

const _zones = <_ZoneOption>[
  (city: 'Madrid', id: 'Europe/Madrid', flag: '🇪🇸'),
  (city: 'Londres', id: 'Europe/London', flag: '🇬🇧'),
  (city: 'Nueva York', id: 'America/New_York', flag: '🇺🇸'),
  (city: 'Ciudad de México', id: 'America/Mexico_City', flag: '🇲🇽'),
  (city: 'Bogotá', id: 'America/Bogota', flag: '🇨🇴'),
  (city: 'Buenos Aires', id: 'America/Argentina/Buenos_Aires', flag: '🇦🇷'),
  (city: 'Tokio', id: 'Asia/Tokyo', flag: '🇯🇵'),
  (city: 'UTC', id: 'UTC', flag: '🌍'),
];

class TimezonePage extends ConsumerStatefulWidget {
  const TimezonePage({super.key});

  @override
  ConsumerState<TimezonePage> createState() => _TimezonePageState();
}

class _TimezonePageState extends ConsumerState<TimezonePage> {
  String _query = '';
  String? _timezoneOverride;
  bool? _automaticOverride;
  bool _saving = false;

  String _offset(String timezone) {
    try {
      final duration = tz.TZDateTime.now(
        tz.getLocation(timezone),
      ).timeZoneOffset;
      final sign = duration.isNegative ? '-' : '+';
      final hours = duration.inHours.abs().toString().padLeft(2, '0');
      final minutes = (duration.inMinutes.abs() % 60).toString().padLeft(
        2,
        '0',
      );
      return 'GMT$sign$hours:$minutes';
    } catch (_) {
      return 'GMT+00:00';
    }
  }

  String _time(String timezone) {
    try {
      return DateFormat.Hm().format(
        tz.TZDateTime.now(tz.getLocation(timezone)),
      );
    } catch (_) {
      return DateFormat.Hm().format(DateTime.now().toUtc());
    }
  }

  Future<void> _save({
    required String timezone,
    required bool automatic,
  }) async {
    if (_saving) return;
    setState(() {
      _saving = true;
      _timezoneOverride = timezone;
      _automaticOverride = automatic;
    });
    final userId =
        ref.read(authControllerProvider).value?.id ??
        ref.read(authRepositoryProvider).currentUser?.id;
    try {
      if (userId != null) {
        await ref
            .read(userProfileRepositoryProvider)
            .updateTimezoneSettings(
              userId,
              timezone: timezone,
              automatic: automatic,
            );
        ref.invalidate(profileTimezoneProvider);
        ref.invalidate(timezoneAutomaticProvider);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  /// Cambiar de zona horaria mueve el instante en que empieza un día nuevo,
  /// y con él el cálculo de la racha. Por eso se avisa justo antes de
  /// aplicarlo, en lugar de dejar un texto fijo que nadie lee.
  Future<bool> _confirmChange({required bool automatic}) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: AppColors.textPrimary.withValues(alpha: .48),
      builder: (context) => _TimezoneChangeDialog(automatic: automatic),
    );
    return confirmed ?? false;
  }

  Future<void> _setAutomatic(bool automatic, String current) async {
    if (!await _confirmChange(automatic: automatic)) return;

    var timezone = current;
    if (automatic) {
      timezone = await ref.read(deviceInfoRepositoryProvider).currentTimezone();
      try {
        tz.getLocation(timezone);
      } catch (_) {
        timezone = current;
      }
    }
    await _save(timezone: timezone, automatic: automatic);
  }

  /// Selección manual de una zona concreta. Elegir la que ya está activa no
  /// es un cambio, así que no pregunta nada.
  Future<void> _selectZone(String zone, String current) async {
    if (zone == current) return;
    if (!await _confirmChange(automatic: false)) return;
    await _save(timezone: zone, automatic: false);
  }

  @override
  Widget build(BuildContext context) {
    final storedTimezone =
        ref.watch(profileTimezoneProvider).value ?? 'Europe/Madrid';
    final storedAutomatic = ref.watch(timezoneAutomaticProvider).value ?? true;
    final current = _timezoneOverride ?? storedTimezone;
    final automatic = _automaticOverride ?? storedAutomatic;
    final option = _zones.firstWhere(
      (zone) => zone.id == current,
      orElse: () => (
        city: current.split('/').last.replaceAll('_', ' '),
        id: current,
        flag: '🌍',
      ),
    );
    final query = _query.trim().toLowerCase();
    final filtered = _zones
        .where(
          (zone) =>
              query.isEmpty ||
              zone.city.toLowerCase().contains(query) ||
              zone.id.toLowerCase().contains(query),
        )
        .toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          context.l10n.profileTimezone,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 42),
        children: [
          _Hero(),
          const SizedBox(height: 18),
          _AutomaticCard(
            value: automatic,
            saving: _saving,
            onChanged: (value) => _setAutomatic(value, current),
          ),
          const SizedBox(height: 14),
          _CurrentZoneCard(
            option: option,
            offset: _offset(current),
            time: _time(current),
          ),
          const SizedBox(height: 18),
          _ManualCard(
            enabled: !automatic,
            query: _query,
            zones: filtered,
            current: current,
            offsetFor: _offset,
            onToggle: (manual) => _setAutomatic(!manual, current),
            onQueryChanged: (value) => setState(() => _query = value),
            onSelected: (zone) => _selectZone(zone, current),
          ),
        ],
      ),
    );
  }
}

class _TimezoneChangeDialog extends StatelessWidget {
  const _TimezoneChangeDialog({required this.automatic});

  final bool automatic;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final body = automatic
        ? l10n.timezoneAutomaticConfirmBody
        : l10n.timezoneManualConfirmBody;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Material(
          color: const Color(0xFFFFFCFD),
          elevation: 0,
          borderRadius: BorderRadius.circular(32),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 30, 24, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 82,
                      height: 82,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0EAFF),
                        borderRadius: BorderRadius.circular(26),
                      ),
                      child: Icon(
                        automatic
                            ? PhosphorIconsBold.globe
                            : PhosphorIconsBold.mapPin,
                        color: AppColors.primary,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      l10n.timezoneChangeConfirmTitle,
                      textAlign: TextAlign.center,
                      style: textTheme.headlineSmall?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F4FD),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            PhosphorIconsBold.info,
                            color: AppColors.primary,
                            size: 23,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              body,
                              style: textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                                height: 1.38,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context, false),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: BorderSide(
                                color: AppColors.primary.withValues(alpha: .35),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: Text(
                              l10n.cancel,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () => Navigator.pop(context, true),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            icon: const Icon(PhosphorIconsBold.check, size: 18),
                            label: Text(
                              l10n.timezoneChangeConfirmAction,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  tooltip: l10n.cancel,
                  onPressed: () => Navigator.pop(context, false),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFFF4F1F8),
                  ),
                  icon: const Icon(Icons.close_rounded),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  @override
  // Sin altura fija: el cuerpo ocupa 5-6 líneas en pantallas estrechas y
  // con una caja de 176 px se desbordaba. La fila se adapta al texto y la
  // ilustración mantiene su proporción.
  Widget build(BuildContext context) => IntrinsicHeight(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 3,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.timezoneHeroTitle,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                context.l10n.timezoneHeroBody,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: AspectRatio(
            aspectRatio: 1,
            child: Image.asset(
              'assets/images/zona_horaria.png',
              fit: BoxFit.contain,
              semanticLabel: context.l10n.profileTimezone,
            ),
          ),
        ),
      ],
    ),
  );
}

class _AutomaticCard extends StatelessWidget {
  const _AutomaticCard({
    required this.value,
    required this.saving,
    required this.onChanged,
  });
  final bool value;
  final bool saving;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: _cardDecoration(const Color(0xFFF0EAFF)),
    child: Row(
      children: [
        _IconBox(icon: PhosphorIconsBold.globe, color: AppColors.primary),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.timezoneAutomatic,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
              Text(
                context.l10n.timezoneAutomaticSubtitle,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 3),
              Text(
                context.l10n.timezoneRecommended,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        Switch.adaptive(value: value, onChanged: saving ? null : onChanged),
      ],
    ),
  );
}

class _CurrentZoneCard extends StatelessWidget {
  const _CurrentZoneCard({
    required this.option,
    required this.offset,
    required this.time,
  });
  final _ZoneOption option;
  final String offset;
  final String time;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: _cardDecoration(Colors.white.withValues(alpha: .80)),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.timezoneCurrent,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _FlagBox(option.flag),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.id,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '$offset  ·  ${context.l10n.timezoneCurrentTime(time)}',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.green.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                context.l10n.timezoneActive,
                style: const TextStyle(
                  color: AppColors.green,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class _ManualCard extends StatelessWidget {
  const _ManualCard({
    required this.enabled,
    required this.query,
    required this.zones,
    required this.current,
    required this.offsetFor,
    required this.onToggle,
    required this.onQueryChanged,
    required this.onSelected,
  });
  final bool enabled;
  final String query;
  final List<_ZoneOption> zones;
  final String current;
  final String Function(String) offsetFor;
  final ValueChanged<bool> onToggle;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
    decoration: _cardDecoration(Colors.white.withValues(alpha: .80)),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.timezoneManual,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 17,
                    ),
                  ),
                  Text(
                    context.l10n.timezoneManualSubtitle,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Switch.adaptive(value: enabled, onChanged: onToggle),
          ],
        ),
        const SizedBox(height: 10),
        IgnorePointer(
          ignoring: !enabled,
          child: AnimatedOpacity(
            opacity: enabled ? 1 : .45,
            duration: const Duration(milliseconds: 180),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  onChanged: onQueryChanged,
                  decoration: InputDecoration(
                    hintText: context.l10n.timezoneSearch,
                    prefixIcon: const Icon(
                      PhosphorIconsRegular.magnifyingGlass,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF5F2FC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  context.l10n.timezoneRecent,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 7),
                for (final zone in zones)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: _FlagBox(zone.flag, small: true),
                    title: Text(
                      zone.city,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: Text('${zone.id}  ·  ${offsetFor(zone.id)}'),
                    trailing: zone.id == current
                        ? const Icon(
                            PhosphorIconsFill.checkCircle,
                            color: AppColors.primary,
                          )
                        : const Icon(
                            PhosphorIconsRegular.circle,
                            color: Color(0xFFB9B4C9),
                          ),
                    onTap: () => onSelected(zone.id),
                  ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class _IconBox extends StatelessWidget {
  const _IconBox({required this.icon, required this.color});
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: 48,
    height: 48,
    decoration: BoxDecoration(
      color: color.withValues(alpha: .12),
      borderRadius: BorderRadius.circular(15),
    ),
    child: Icon(icon, color: color, size: 27),
  );
}

class _FlagBox extends StatelessWidget {
  const _FlagBox(this.flag, {this.small = false});
  final String flag;
  final bool small;

  @override
  Widget build(BuildContext context) => Container(
    width: small ? 44 : 54,
    height: small ? 44 : 54,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: const Color(0xFFF0EAFF),
      borderRadius: BorderRadius.circular(15),
    ),
    child: Text(flag, style: TextStyle(fontSize: small ? 23 : 27)),
  );
}

BoxDecoration _cardDecoration(Color color) => BoxDecoration(
  color: color,
  borderRadius: BorderRadius.circular(24),
  border: Border.all(color: Colors.white.withValues(alpha: .85)),
);
