import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habits/features/auth/0_entity/entity.dart';
import 'package:habits/features/auth/1_domain/domain.dart';
import 'package:habits/features/auth/3_data/data.dart';

void main() {
  group('FirestoreUserProfileRepository', () {
    late FakeFirebaseFirestore firestore;
    late FirestoreUserProfileRepository repository;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      repository = FirestoreUserProfileRepository(firestore: firestore);
    });

    NewUserProfile profile() => NewUserProfile(
      userId: 'uid-1',
      email: 'alex@example.com',
      displayName: 'Alex',
      timezone: 'Europe/Madrid',
      locale: 'es',
      ambitos: PredefinedAmbitos.forLocale('es'),
    );

    test('exists distingue perfiles creados y ausentes', () async {
      expect(await repository.exists('uid-1'), isFalse);
      await repository.create(profile());
      expect(await repository.exists('uid-1'), isTrue);
    });

    test(
      'create escribe exactamente los campos que aceptan las reglas',
      () async {
        await repository.create(profile());

        final user = await firestore.collection('users').doc('uid-1').get();
        final data = user.data()!;
        expect(data.keys.toSet(), {
          'email',
          'displayName',
          'avatarId',
          'timezone',
          'timezoneAutomatic',
          'welcomeAnimationEnabled',
          'customMotivationMessages',
          'themeMode',
          'locale',
          'subscription',
          'onboardingCompleted',
          'createdAt',
          'updatedAt',
          'lastActiveAt',
        });
        expect(data['email'], 'alex@example.com');
        expect(data['displayName'], 'Alex');
        expect(data['avatarId'], 'traveler');
        expect(data['timezone'], 'Europe/Madrid');
        expect(data['timezoneAutomatic'], isTrue);
        expect(data['welcomeAnimationEnabled'], isTrue);
        expect(data['customMotivationMessages'], isEmpty);
        expect(data['themeMode'], 'light');
        expect(data['locale'], 'es');
        expect(data['subscription'], {'status': 'free'});
        expect(data['onboardingCompleted'], isFalse);
        expect(data['createdAt'], isNotNull);
      },
    );

    test('guarda y emite la preferencia de animación', () async {
      await repository.create(profile());

      await repository.updateWelcomeAnimationEnabled('uid-1', false);

      expect(
        await repository.watchWelcomeAnimationEnabled('uid-1').first,
        isFalse,
      );
    });

    test('guarda y emite los mensajes motivacionales', () async {
      await repository.create(profile());
      const messages = ['Paso a paso', 'Hoy también cuenta'];

      await repository.updateCustomMotivationMessages('uid-1', messages);

      expect(
        await repository.watchCustomMotivationMessages('uid-1').first,
        messages,
      );
    });

    test('create siembra los cinco ámbitos predefinidos', () async {
      await repository.create(profile());

      final ambitos = await firestore
          .collection('users')
          .doc('uid-1')
          .collection('ambitos')
          .orderBy('orden')
          .get();

      expect(ambitos.docs.map((d) => d.id), [
        'general',
        'salud',
        'mente',
        'desarrollo',
        'energia',
      ]);
      final general = ambitos.docs.first.data();
      expect(general.keys.toSet(), {
        'nombre',
        'emoji',
        'colorValue',
        'esPredefinido',
        'orden',
        'createdAt',
        'updatedAt',
      });
      expect(general['esPredefinido'], isTrue);
      expect(general['nombre'], 'General');
    });
  });
}
