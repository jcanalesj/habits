import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Marca que el usuario acaba de crear su cuenta en esta sesión, para
/// llevarlo a la pantalla de bienvenida antes que a la home.
///
/// Lo fija el controlador de registro ANTES de navegar y lo consume la
/// pantalla de bienvenida: así el `redirect` del router puede anclarlo ahí
/// aunque llegue antes que la propia página.
class JustRegisteredController extends Notifier<bool> {
  @override
  bool build() => false;

  void markRegistered() => state = true;

  void clear() => state = false;
}

final justRegisteredProvider = NotifierProvider<JustRegisteredController, bool>(
  JustRegisteredController.new,
);
