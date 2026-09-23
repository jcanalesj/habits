import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habits/features/profile/avatar/avatar_picker_page.dart';
import 'package:habits/features/profile/avatar/avatar_providers.dart';

import '../../helpers/auth_test_helpers.dart';

void main() {
  testWidgets('permite cuatro avatares y muestra Premium en los demás', (
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

    await tester.tap(find.text('Licorice'));
    await tester.pumpAndSettle();
    expect(env.profiles.avatarIds[verifiedUser.id], 'friendly');

    await tester.ensureVisible(find.text('Pearl'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pearl'));
    await tester.pumpAndSettle();
    expect(env.profiles.avatarIds[verifiedUser.id], 'magic');

    await tester.scrollUntilVisible(
      find.text('Snowball'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Snowball'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('premium-avatar-dialog')), findsOneWidget);
    expect(find.text('Personaliza tu perfil con Premium'), findsOneWidget);
    expect(find.text('Personalizaciones exclusivas'), findsOneWidget);
  });
}
