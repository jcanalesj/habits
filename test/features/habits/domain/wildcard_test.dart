import 'package:flutter_test/flutter_test.dart';
import 'package:habits/features/habits/0_entity/entity.dart';
import 'package:habits/features/habits/1_domain/exceptions/habits_exception.dart';
import 'package:habits/features/habits/1_domain/services/wildcard_policy.dart';
import 'package:habits/features/habits/1_domain/usecases/ensure_monthly_wildcard_grant_usecase.dart';
import 'package:habits/features/habits/1_domain/usecases/use_wildcard_usecase.dart';
import 'package:habits/features/habits/3_data/repositories/in_memory_wildcards_repository.dart';

/// Año/mes como entero monótono, igual que en las Security Rules.
int ym(int year, int month) => year * 12 + month;

LogicalDate d(String key) => LogicalDate.parse(key);

void main() {
  group('WildcardPolicy — concesión mensual', () {
    test('un usuario nuevo arranca con 1 comodín del mes en curso', () {
      final balance = WildcardPolicy.initial(ym(2026, 9));

      expect(balance.available, 1);
      expect(balance.lastGrantYearMonth, ym(2026, 9));
      expect(balance.grantedTotal, 1);
    });

    test('acumula 0 → 1 → 2 → 3 mes a mes', () {
      var balance = const WildcardBalance(
        available: 0,
        lastGrantYearMonth: 0,
        grantedTotal: 0,
      ).copyWith(lastGrantYearMonth: ym(2026, 8));

      balance = WildcardPolicy.applyMonthlyGrants(balance, ym(2026, 9));
      expect(balance.available, 1);
      balance = WildcardPolicy.applyMonthlyGrants(balance, ym(2026, 10));
      expect(balance.available, 2);
      balance = WildcardPolicy.applyMonthlyGrants(balance, ym(2026, 11));
      expect(balance.available, 3);
    });

    test('nunca pasa de 3 aunque pase otro mes', () {
      final balance = WildcardPolicy.applyMonthlyGrants(
        WildcardBalance(available: 3, lastGrantYearMonth: ym(2026, 9)),
        ym(2026, 10),
      );

      expect(balance.available, 3);
      expect(balance.grantedTotal, 0, reason: 'no se concedió nada');
    });

    test('tres meses sin abrir la app: 1 → 3, no 4', () {
      final balance = WildcardPolicy.applyMonthlyGrants(
        WildcardBalance(
          available: 1,
          lastGrantYearMonth: ym(2026, 6),
          grantedTotal: 5,
        ),
        ym(2026, 9),
      );

      expect(balance.available, 3);
      expect(balance.lastGrantYearMonth, ym(2026, 9));
      expect(balance.grantedTotal, 7, reason: '5 + los 2 realmente concedidos');
    });

    test('doce meses sin abrir la app siguen topando en 3', () {
      final balance = WildcardPolicy.applyMonthlyGrants(
        WildcardBalance(available: 0, lastGrantYearMonth: ym(2025, 9)),
        ym(2026, 9),
      );

      expect(balance.available, 3);
    });

    test('es idempotente dentro del mismo mes', () {
      var balance = WildcardBalance(
        available: 1,
        lastGrantYearMonth: ym(2026, 9),
      );
      final original = balance;

      for (var i = 0; i < 50; i++) {
        balance = WildcardPolicy.applyMonthlyGrants(balance, ym(2026, 9));
      }

      expect(balance, original, reason: 'abrir la app no concede de más');
    });

    test('no concede hacia atrás si el reloj retrocede', () {
      final balance = WildcardPolicy.applyMonthlyGrants(
        WildcardBalance(available: 1, lastGrantYearMonth: ym(2026, 9)),
        ym(2026, 8),
      );

      expect(balance.available, 1);
      expect(balance.lastGrantYearMonth, ym(2026, 9), reason: 'monótono');
    });

    test('el cambio de año cuenta como un mes más', () {
      expect(ym(2027, 1) - ym(2026, 12), 1);

      final balance = WildcardPolicy.applyMonthlyGrants(
        WildcardBalance(available: 0, lastGrantYearMonth: ym(2026, 12)),
        ym(2027, 1),
      );

      expect(balance.available, 1);
    });
  });

  group('WildcardPolicy — ventana de rescate', () {
    test('solo se puede proteger el día inmediatamente anterior', () {
      expect(
        WildcardPolicy.isWithinRescueWindow(d('2026-09-10'), d('2026-09-11')),
        isTrue,
      );
    });

    test('anteayer ya no se puede proteger', () {
      expect(
        WildcardPolicy.isWithinRescueWindow(d('2026-09-09'), d('2026-09-11')),
        isFalse,
      );
    });

    test('hoy no se protege: se completa', () {
      expect(
        WildcardPolicy.isWithinRescueWindow(d('2026-09-11'), d('2026-09-11')),
        isFalse,
      );
    });

    test('la ventana funciona cruzando mes y año', () {
      expect(
        WildcardPolicy.isWithinRescueWindow(d('2026-08-31'), d('2026-09-01')),
        isTrue,
      );
      expect(
        WildcardPolicy.isWithinRescueWindow(d('2026-12-31'), d('2027-01-01')),
        isTrue,
      );
    });
  });

  group('EnsureMonthlyWildcardGrantUsecase', () {
    test('crea el saldo inicial la primera vez', () async {
      final repo = InMemoryWildcardsRepository();
      final usecase = EnsureMonthlyWildcardGrantUsecase(repo);

      final balance = await usecase.execute(d('2026-09-11'));

      expect(balance!.available, 1);
      addTearDown(repo.dispose);
    });

    test('llamarlo muchas veces el mismo día no concede de más', () async {
      final repo = InMemoryWildcardsRepository();
      final usecase = EnsureMonthlyWildcardGrantUsecase(repo);

      for (var i = 0; i < 10; i++) {
        await usecase.execute(d('2026-09-11'));
      }

      expect((await repo.fetchBalance())!.available, 1);
      addTearDown(repo.dispose);
    });

    test('sin conexión falla en silencio sin bloquear la app', () async {
      final repo = InMemoryWildcardsRepository()..offline = true;
      final usecase = EnsureMonthlyWildcardGrantUsecase(repo);

      expect(await usecase.execute(d('2026-09-11')), isNull);
      addTearDown(repo.dispose);
    });
  });

  group('UseWildcardUsecase', () {
    InMemoryWildcardsRepository repoWith(int available) =>
        InMemoryWildcardsRepository(
          balance: WildcardBalance(
            available: available,
            lastGrantYearMonth: ym(2026, 9),
            grantedTotal: available,
          ),
        );

    test('consume 1 y protege el día: 1 → 0', () async {
      final repo = repoWith(1);
      addTearDown(repo.dispose);

      final result = await UseWildcardUsecase(repo).execute(
        day: d('2026-09-10'),
        today: d('2026-09-11'),
        activityDays: const {},
      );

      expect(result, isA<UseWildcardSuccess>());
      expect((await repo.fetchBalance())!.available, 0);
      expect(await repo.fetchProtectedDays(), {d('2026-09-10')});
    });

    test('con saldo 0 no se puede consumir', () async {
      final repo = repoWith(0);
      addTearDown(repo.dispose);

      final result = await UseWildcardUsecase(repo).execute(
        day: d('2026-09-10'),
        today: d('2026-09-11'),
        activityDays: const {},
      );

      expect(
        (result as UseWildcardFailed).failure,
        WildcardFailure.noneAvailable,
      );
      expect(await repo.fetchProtectedDays(), isEmpty);
    });

    test('no se puede gastar dos veces sobre el mismo día', () async {
      final repo = repoWith(2);
      addTearDown(repo.dispose);
      final usecase = UseWildcardUsecase(repo);

      await usecase.execute(
        day: d('2026-09-10'),
        today: d('2026-09-11'),
        activityDays: const {},
      );
      final second = await usecase.execute(
        day: d('2026-09-10'),
        today: d('2026-09-11'),
        activityDays: const {},
      );

      expect(
        (second as UseWildcardFailed).failure,
        WildcardFailure.dayAlreadyProtected,
      );
      expect(
        (await repo.fetchBalance())!.available,
        1,
        reason: 'el segundo intento no cobra',
      );
    });

    test('el doble tap no gasta dos comodines', () async {
      final repo = repoWith(2);
      addTearDown(repo.dispose);
      final usecase = UseWildcardUsecase(repo);

      final results = await Future.wait([
        usecase.execute(
          day: d('2026-09-10'),
          today: d('2026-09-11'),
          activityDays: const {},
        ),
        usecase.execute(
          day: d('2026-09-10'),
          today: d('2026-09-11'),
          activityDays: const {},
        ),
      ]);

      expect(results.whereType<UseWildcardSuccess>(), hasLength(1));
      expect((await repo.fetchBalance())!.available, 1);
      expect(await repo.fetchProtectedDays(), hasLength(1));
    });

    test('no se puede proteger anteayer: la ventana está cerrada', () async {
      final repo = repoWith(3);
      addTearDown(repo.dispose);

      final result = await UseWildcardUsecase(repo).execute(
        day: d('2026-09-09'),
        today: d('2026-09-11'),
        activityDays: const {},
      );

      expect(
        (result as UseWildcardFailed).failure,
        WildcardFailure.rescueWindowClosed,
      );
      expect(
        (await repo.fetchBalance())!.available,
        3,
        reason: 'tener comodines no reabre el pasado',
      );
    });

    test('no se malgasta un comodín en un día que sí tuvo actividad', () async {
      final repo = repoWith(1);
      addTearDown(repo.dispose);

      final result = await UseWildcardUsecase(repo).execute(
        day: d('2026-09-10'),
        today: d('2026-09-11'),
        activityDays: {d('2026-09-10')},
      );

      expect(
        (result as UseWildcardFailed).failure,
        WildcardFailure.dayHasActivity,
      );
      expect((await repo.fetchBalance())!.available, 1);
    });

    test('sin conexión no se puede gastar un comodín', () async {
      final repo = repoWith(1)..offline = true;
      addTearDown(repo.dispose);

      final result = await UseWildcardUsecase(repo).execute(
        day: d('2026-09-10'),
        today: d('2026-09-11'),
        activityDays: const {},
      );

      expect(
        (result as UseWildcardFailed).failure,
        WildcardFailure.requiresConnection,
      );
      expect((await repo.fetchBalance())!.available, 1);
    });
  });
}
