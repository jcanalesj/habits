/// Validación sintáctica de email compartida por los usecases de auth.
abstract final class EmailValidator {
  static final _regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static bool isValid(String email) => _regex.hasMatch(email.trim());
}
