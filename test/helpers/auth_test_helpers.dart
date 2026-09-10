import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:habits/features/auth/0_entity/entity.dart';
import 'package:habits/features/auth/2_presentation/providers/auth_providers.dart';
import 'package:habits/features/auth/3_data/data.dart';
import 'package:habits/features/habits/2_presentation/providers/habits_providers.dart';
import 'package:habits/features/habits/3_data/data.dart';
import 'package:habits/localization/gen/app_localizations.dart';

/// Usuario verificado de ejemplo.
const verifiedUser = AppUser(
  id: 'user-verified',
  email: 'alex@example.com',
  displayName: 'Alex',
  emailVerified: true,
);

/// Usuario recién registrado, sin verificar.
const unverifiedUser = AppUser(
  id: 'user-unverified',
  email: 'nuevo@example.com',
  displayName: 'Nuevo',
);

/// Dependencias de auth en memoria para tests de presentación.
class AuthTestEnv {
  AuthTestEnv({AppUser? initialUser, bool seededHabits = true})
    : auth = InMemoryAuthRepository(initialUser: initialUser),
      habits = InMemoryHabitsRepository(seeded: seededHabits);

  final InMemoryAuthRepository auth;
  final profiles = InMemoryUserProfileRepository();
  final device = const FixedDeviceInfoRepository(timezone: 'Europe/Madrid');
  final InMemoryHabitsRepository habits;

  List<Override> get overrides => [
    authRepositoryProvider.overrideWithValue(auth),
    userProfileRepositoryProvider.overrideWithValue(profiles),
    deviceInfoRepositoryProvider.overrideWithValue(device),
    habitsRepositoryProvider.overrideWithValue(habits),
  ];
}

/// MaterialApp localizada en español con una página bajo prueba.
Widget localizedApp(Widget home, {List<Override> overrides = const []}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      locale: const Locale('es'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: home,
    ),
  );
}
