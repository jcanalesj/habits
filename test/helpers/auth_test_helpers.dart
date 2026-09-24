import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:habits/features/auth/0_entity/entity.dart';
import 'package:habits/features/auth/2_presentation/providers/auth_providers.dart';
import 'package:habits/features/auth/3_data/data.dart';
import 'package:habits/features/habits/0_entity/entity.dart';
import 'package:habits/features/habits/1_domain/domain.dart';
import 'package:habits/features/habits/2_presentation/providers/habits_providers.dart';
import 'package:habits/features/habits/3_data/data.dart';
import 'package:habits/localization/gen/app_localizations.dart';
import 'package:habits/theme/app_theme.dart';

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

/// Instante fijo para los tests: viernes 11 de septiembre de 2026, 12:00 en
/// Europe/Madrid. Fijarlo evita que un test pase o falle según la hora real.
final testInstant = DateTime.utc(2026, 9, 11, 10);
const testToday = LogicalDate(2026, 9, 11);
const testTimezone = 'Europe/Madrid';

/// Dependencias en memoria para tests de presentación.
class AuthTestEnv {
  AuthTestEnv({
    AppUser? initialUser,
    bool seededHabits = true,
    WildcardBalance? wildcards,
    Set<LogicalDate>? protectedDays,
  }) : auth = InMemoryAuthRepository(initialUser: initialUser),
       habits = InMemoryHabitsRepository(
         seeded: seededHabits,
         now: (() => testInstant.toLocal()),
         today: testToday,
       ),
       wildcards = InMemoryWildcardsRepository(
         balance: wildcards,
         protectedDays: protectedDays,
       );

  final InMemoryAuthRepository auth;
  final profiles = InMemoryUserProfileRepository();
  final device = const FixedDeviceInfoRepository(timezone: testTimezone);
  final InMemoryHabitsRepository habits;
  final InMemoryWildcardsRepository wildcards;

  List<Override> get overrides => [
    authRepositoryProvider.overrideWithValue(auth),
    userProfileRepositoryProvider.overrideWithValue(profiles),
    deviceInfoRepositoryProvider.overrideWithValue(device),
    habitsRepositoryProvider.overrideWithValue(habits),
    wildcardsRepositoryProvider.overrideWithValue(wildcards),
    // Reloj y zona fijos: el "día lógico" de los tests es determinista.
    clockProvider.overrideWithValue(FixedClock(testInstant)),
    profileTimezoneProvider.overrideWith((ref) => Stream.value(testTimezone)),
  ];
}

/// MaterialApp localizada en español con una página bajo prueba.
Widget localizedApp(
  Widget home, {
  List<Override> overrides = const [],
  ThemeMode themeMode = ThemeMode.light,
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      locale: const Locale('es'),
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: home,
    ),
  );
}
