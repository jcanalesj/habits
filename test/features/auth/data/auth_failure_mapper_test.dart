import 'package:flutter_test/flutter_test.dart';
import 'package:habits/features/auth/0_entity/entity.dart';
import 'package:habits/features/auth/3_data/mappers/auth_failure_mapper.dart';

void main() {
  test('authFailureFromCode cubre los códigos de Firebase Auth', () {
    expect(
      authFailureFromCode('invalid-credential'),
      AuthFailure.invalidCredentials,
    );
    expect(
      authFailureFromCode('wrong-password'),
      AuthFailure.invalidCredentials,
    );
    expect(
      authFailureFromCode('user-not-found'),
      AuthFailure.invalidCredentials,
    );
    expect(
      authFailureFromCode('email-already-in-use'),
      AuthFailure.emailAlreadyInUse,
    );
    expect(authFailureFromCode('weak-password'), AuthFailure.weakPassword);
    expect(authFailureFromCode('invalid-email'), AuthFailure.invalidEmail);
    expect(authFailureFromCode('user-disabled'), AuthFailure.userDisabled);
    expect(
      authFailureFromCode('too-many-requests'),
      AuthFailure.tooManyRequests,
    );
    expect(authFailureFromCode('network-request-failed'), AuthFailure.network);
    expect(
      authFailureFromCode('requires-recent-login'),
      AuthFailure.requiresRecentLogin,
    );
    expect(authFailureFromCode('no-current-user'), AuthFailure.noSession);
    expect(authFailureFromCode('algo-nuevo'), AuthFailure.unknown);
  });
}
