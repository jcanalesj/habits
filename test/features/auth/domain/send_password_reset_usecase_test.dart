import 'package:flutter_test/flutter_test.dart';
import 'package:habits/features/auth/1_domain/domain.dart';
import 'package:habits/features/auth/3_data/data.dart';

void main() {
  group('SendPasswordResetUsecase', () {
    late InMemoryAuthRepository repository;
    late SendPasswordResetUsecase usecase;

    setUp(() {
      repository = InMemoryAuthRepository();
      usecase = SendPasswordResetUsecase(repository);
    });

    test('rechaza un email inválido sin llamar al proveedor', () async {
      final result = await usecase.execute(email: 'nada');

      expect(result, isA<SendPasswordResetValidationFailed>());
      expect(repository.passwordResetEmailsSent, isEmpty);
    });

    test('envía el enlace con el email recortado', () async {
      final result = await usecase.execute(email: '  alex@example.com ');

      expect(result, isA<SendPasswordResetSuccess>());
      expect(repository.passwordResetEmailsSent, ['alex@example.com']);
    });
  });
}
