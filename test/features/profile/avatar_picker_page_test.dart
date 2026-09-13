import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habits/features/profile/avatar/avatar_picker_page.dart';
import 'package:habits/features/profile/avatar/avatar_providers.dart';

import '../../helpers/auth_test_helpers.dart';

void main() {
  testWidgets('selecciona un avatar disponible y bloquea los próximos', (
    tester,
  ) async {
    final env = AuthTestEnv(initialUser: verifiedUser);
    await tester.pumpWidget(
      localizedApp(
        const AvatarPickerPage(),
        overrides: [
          ...env.overrides,
          selectedAvatarIdProvider.overrideWith(
            (ref) => Stream.value('traveler'),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Elige tu avatar'), findsOneWidget);
    expect(find.text('Seleccionado'), findsOneWidget);

    await tester.tap(find.text('Gato curioso'));
    await tester.pumpAndSettle();
    expect(env.profiles.avatarIds[verifiedUser.id], 'friendly');

    await tester.drag(find.byType(GridView), const Offset(0, -500));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Gato mágico'));
    await tester.pumpAndSettle();
    expect(find.text('Avatar bloqueado 🔒'), findsOneWidget);
    expect(find.text('Entendido'), findsOneWidget);
  });
}
