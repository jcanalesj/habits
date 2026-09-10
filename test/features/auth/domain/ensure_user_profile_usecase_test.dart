import 'package:flutter_test/flutter_test.dart';
import 'package:habits/features/auth/0_entity/entity.dart';
import 'package:habits/features/auth/1_domain/domain.dart';
import 'package:habits/features/auth/3_data/data.dart';

void main() {
  group('EnsureUserProfileUsecase', () {
    late InMemoryUserProfileRepository profiles;
    late EnsureUserProfileUsecase usecase;

    const verified = AppUser(
      id: 'u1',
      email: 'alex@example.com',
      displayName: 'Alex',
      emailVerified: true,
    );

    setUp(() {
      profiles = InMemoryUserProfileRepository();
      usecase = EnsureUserProfileUsecase(
        profiles,
        const FixedDeviceInfoRepository(timezone: 'Europe/Madrid'),
      );
    });

    test('no crea nada si el email no está verificado', () async {
      final result = await usecase.execute(
        user: verified.copyWith(emailVerified: false),
        locale: 'es',
      );

      expect(result, isA<EnsureUserProfileNotVerified>());
      expect(profiles.profiles, isEmpty);
    });

    test(
      'crea el perfil con los ámbitos predefinidos en el idioma del usuario',
      () async {
        final result = await usecase.execute(user: verified, locale: 'en_US');

        expect(result, isA<EnsureUserProfileCreated>());
        final profile = profiles.profiles['u1']!;
        expect(profile.email, 'alex@example.com');
        expect(profile.displayName, 'Alex');
        expect(profile.timezone, 'Europe/Madrid');
        expect(profile.locale, 'en');
        expect(profile.ambitos.map((a) => a.id), [
          'general',
          'salud',
          'mente',
          'desarrollo',
          'energia',
        ]);
        expect(profile.ambitos[1].name, 'Health');
      },
    );

    test('normaliza cualquier otro idioma a español', () async {
      await usecase.execute(user: verified, locale: 'fr');

      expect(profiles.profiles['u1']!.locale, 'es');
      expect(profiles.profiles['u1']!.ambitos[1].name, 'Salud');
    });

    test('es idempotente', () async {
      await usecase.execute(user: verified, locale: 'es');
      final result = await usecase.execute(user: verified, locale: 'es');

      expect(result, isA<EnsureUserProfileAlreadyExists>());
      expect(profiles.profiles, hasLength(1));
    });
  });
}
