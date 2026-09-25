import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habits/components/app_notice.dart';
import 'package:habits/features/habits/2_presentation/welcome/cold_start_welcome.dart';
import 'package:habits/features/premium/0_entity/premium_plan.dart';
import 'package:habits/features/premium/2_presentation/premium_providers.dart';
import 'package:habits/legal_links.dart';
import 'package:habits/localization/l10n.dart';
import 'package:habits/theme/app_theme.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

/// Planes disponibles en la tienda.
final premiumPlansProvider = FutureProvider.autoDispose<List<PremiumPlan>>((
  ref,
) {
  final purchases = ref.watch(purchasesRepositoryProvider);
  if (!purchases.isAvailable) return const [];
  return purchases.loadPlans();
});

/// Abre la pantalla de planes. Devuelve true si al cerrarla el usuario ya
/// tiene Premium.
Future<bool> showPaywall(BuildContext context) async {
  final purchased = await Navigator.of(context).push<bool>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => const PaywallPage(),
    ),
  );
  return purchased ?? false;
}

/// Pantalla de planes Premium.
///
/// Cumple lo que piden las tiendas para suscripciones: precio y periodo
/// claros, aviso de renovación automática, restaurar compras y enlaces a
/// los términos y a la política de privacidad.
class PaywallPage extends ConsumerStatefulWidget {
  const PaywallPage({super.key});

  @override
  ConsumerState<PaywallPage> createState() => _PaywallPageState();
}

class _PaywallPageState extends ConsumerState<PaywallPage> {
  String? _selectedId;
  bool _busy = false;

  Future<void> _purchase(PremiumPlan plan) async {
    final l10n = context.l10n;
    setState(() => _busy = true);
    final outcome = await ref.read(purchasesRepositoryProvider).purchase(plan);
    if (!mounted) return;
    setState(() => _busy = false);
    switch (outcome) {
      case PurchaseOutcome.purchased:
        AppNotice.show(context, message: l10n.paywallWelcome);
        Navigator.pop(context, true);
      case PurchaseOutcome.cancelled:
        break;
      case PurchaseOutcome.unavailable:
        _error(l10n.paywallUnavailable);
      case PurchaseOutcome.failed:
        _error(l10n.paywallPurchaseFailed);
    }
  }

  Future<void> _restore() async {
    final l10n = context.l10n;
    setState(() => _busy = true);
    bool restored;
    try {
      restored = await ref.read(purchasesRepositoryProvider).restore();
    } catch (_) {
      restored = false;
    }
    if (!mounted) return;
    setState(() => _busy = false);
    if (restored) {
      AppNotice.show(context, message: l10n.paywallWelcome);
      Navigator.pop(context, true);
    } else {
      _error(l10n.paywallRestoreNothing);
    }
  }

  Future<void> _manage() async {
    final url = await ref.read(purchasesRepositoryProvider).managementUrl();
    if (!mounted || url == null) return;
    await openExternalLink(context, url);
  }

  void _error(String message) =>
      AppNotice.show(context, message: message, type: AppNoticeType.error);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;
    final subscribed = ref.watch(premiumSubscribedProvider);
    final plansAsync = ref.watch(premiumPlansProvider);

    return Scaffold(
      key: const ValueKey('paywall-page'),
      backgroundColor: palette.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context, subscribed),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 0, 22, 32),
          children: [
            Image.asset(
              'assets/images/premium.png',
              height: 170,
              fit: BoxFit.contain,
              semanticLabel: l10n.premiumCatImageLabel,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.paywallTitle,
              textAlign: TextAlign.center,
              style: textTheme.headlineSmall?.copyWith(
                color: palette.authHeading,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.paywallSubtitle,
              textAlign: TextAlign.center,
              style: textTheme.bodyLarge?.copyWith(
                color: palette.authSecondary,
              ),
            ),
            const SizedBox(height: 20),
            _Benefit(
              icon: PhosphorIconsBold.infinity,
              title: l10n.premiumUnlimitedHabits,
              subtitle: l10n.premiumUnlimitedHabitsBody,
            ),
            _Benefit(
              icon: PhosphorIconsBold.palette,
              title: l10n.premiumCustomization,
              subtitle: l10n.premiumCustomizationBody,
            ),
            _Benefit(
              icon: PhosphorIconsBold.star,
              title: l10n.premiumNewFeatures,
              subtitle: l10n.premiumNewFeaturesBody,
            ),
            const SizedBox(height: 20),
            if (subscribed) ...[
              Text(
                l10n.paywallActive,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                key: const ValueKey('paywall-manage'),
                onPressed: _manage,
                child: Text(l10n.paywallManage),
              ),
            ] else
              ...switch (plansAsync) {
                AsyncData(:final value) when value.isNotEmpty => _plans(value),
                AsyncLoading() => [
                  const Center(child: CircularProgressIndicator()),
                ],
                _ => [
                  Text(
                    l10n.paywallUnavailable,
                    key: const ValueKey('paywall-unavailable'),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: palette.textSecondary),
                  ),
                ],
              },
            const SizedBox(height: 8),
            TextButton(
              key: const ValueKey('paywall-restore'),
              onPressed: _busy ? null : _restore,
              child: Text(l10n.paywallRestore),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.paywallLegal,
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(
                color: palette.textSecondary,
              ),
            ),
            Wrap(
              alignment: WrapAlignment.center,
              children: [
                TextButton(
                  onPressed: () => openExternalLink(context, LegalLinks.terms),
                  child: Text(l10n.profileTerms),
                ),
                TextButton(
                  onPressed: () =>
                      openExternalLink(context, LegalLinks.privacyPolicy),
                  child: Text(l10n.profilePrivacyPolicy),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _plans(List<PremiumPlan> plans) {
    final l10n = context.l10n;
    // Por defecto, el anual (suele ser el más ventajoso) o el primero.
    final selectedId =
        _selectedId ??
        (plans.where((p) => p.period == PremiumPlanPeriod.annual).firstOrNull ??
                plans.first)
            .id;
    final selected = plans.firstWhere(
      (p) => p.id == selectedId,
      orElse: () => plans.first,
    );
    return [
      for (final plan in plans)
        _PlanTile(
          plan: plan,
          selected: plan.id == selected.id,
          onTap: _busy ? null : () => setState(() => _selectedId = plan.id),
        ),
      const SizedBox(height: 12),
      FilledButton(
        key: const ValueKey('paywall-continue'),
        onPressed: _busy ? null : () => _purchase(selected),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: const StadiumBorder(),
        ),
        child: _busy
            ? const SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(l10n.paywallContinue),
      ),
    ];
  }
}

class _PlanTile extends StatelessWidget {
  const _PlanTile({
    required this.plan,
    required this.selected,
    required this.onTap,
  });

  final PremiumPlan plan;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final title = switch (plan.period) {
      PremiumPlanPeriod.monthly => l10n.paywallMonthly,
      PremiumPlanPeriod.annual => l10n.paywallAnnual,
      PremiumPlanPeriod.lifetime => l10n.paywallLifetime,
      PremiumPlanPeriod.other => l10n.paywallOtherPlan,
    };
    final price = switch (plan.period) {
      PremiumPlanPeriod.monthly => l10n.paywallPerMonth(plan.priceLabel),
      PremiumPlanPeriod.annual => l10n.paywallPerYear(plan.priceLabel),
      PremiumPlanPeriod.lifetime => l10n.paywallOneTime(plan.priceLabel),
      PremiumPlanPeriod.other => plan.priceLabel,
    };
    final trial = !plan.hasTrial
        ? null
        : switch (plan.trialUnit!) {
            TrialUnit.day => l10n.paywallTrialDays(plan.trialLength!),
            TrialUnit.week => l10n.paywallTrialWeeks(plan.trialLength!),
            TrialUnit.month => l10n.paywallTrialMonths(plan.trialLength!),
            TrialUnit.year => l10n.paywallTrialYears(plan.trialLength!),
          };
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: selected ? palette.tint(palette.primary, .10) : palette.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: selected ? palette.primary : palette.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: ListTile(
          key: ValueKey('paywall-plan-${plan.id}'),
          onTap: onTap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          leading: Icon(
            selected
                ? Icons.radio_button_checked_rounded
                : Icons.radio_button_off_rounded,
            color: palette.primary,
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          subtitle: Text(trial == null ? price : '$trial · $price'),
        ),
      ),
    );
  }
}

class _Benefit extends StatelessWidget {
  const _Benefit({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: palette.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
      subtitle: Text(subtitle),
    );
  }
}
