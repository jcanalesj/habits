import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habits/features/habits/2_presentation/welcome/cold_start_welcome.dart';
import 'package:habits/features/profile/appearance/app_icon.dart';
import 'package:habits/local_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/auth_test_helpers.dart';

class _FakeAppIconService implements AppIconService {
  _FakeAppIconService(this.icon);

  AppIconOption icon;
  final changes = <AppIconOption>[];

  @override
  Future<AppIconOption> current() async => icon;

  @override
  Future<void> set(AppIconOption icon) async {
    this.icon = icon;
    changes.add(icon);
  }
}

class _EnabledPreview extends PremiumPreviewController {
  @override
  bool build() => true;
}

/// Igual que la raíz de la app: solo mantiene vivo el controlador.
class _Host extends ConsumerWidget {
  const _Host();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(appIconProvider);
    return const SizedBox();
  }
}

void main() {
  Future<_FakeAppIconService> pumpHost(
    WidgetTester tester, {
    required bool subscribed,
    bool preview = false,
    AppIconOption system = AppIconOption.crown,
    SharedPreferences? preferences,
  }) async {
    final env = AuthTestEnv(initialUser: verifiedUser);
    env.profiles.premium[verifiedUser.id] = subscribed;
    final service = _FakeAppIconService(system);
    await tester.pumpWidget(
      localizedApp(
        const _Host(),
        overrides: [
          ...env.overrides,
          appIconServiceProvider.overrideWithValue(service),
          if (preferences != null)
            sharedPreferencesProvider.overrideWithValue(preferences),
          if (preview)
            premiumPreviewEnabledProvider.overrideWith(_EnabledPreview.new),
        ],
      ),
    );
    await tester.pumpAndSettle();
    return service;
  }

  testWidgets('sin Premium un icono Premium vuelve al clásico', (tester) async {
    final service = await pumpHost(tester, subscribed: false);
    expect(service.icon, AppIconOption.classic);
  });

  testWidgets('con suscripción Premium se conserva el icono elegido', (
    tester,
  ) async {
    final service = await pumpHost(tester, subscribed: true);
    expect(service.icon, AppIconOption.crown);
  });

  testWidgets('el acceso de prueba también lo conserva', (tester) async {
    final service = await pumpHost(tester, subscribed: false, preview: true);
    expect(service.icon, AppIconOption.crown);
  });

  testWidgets('el acceso de prueba guardado sobrevive a reabrir la app', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      PremiumPreviewController.key: true,
    });
    final service = await pumpHost(
      tester,
      subscribed: false,
      preferences: await SharedPreferences.getInstance(),
    );
    expect(service.icon, AppIconOption.crown);
  });

  testWidgets(
    'el icono guardado se vuelve a pedir si el sistema no lo aplicó',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        PremiumPreviewController.key: true,
        'app_icon': 'yarn',
      });
      final service = await pumpHost(
        tester,
        subscribed: false,
        system: AppIconOption.classic,
        preferences: await SharedPreferences.getInstance(),
      );
      expect(service.changes, [AppIconOption.yarn]);
    },
  );
}
