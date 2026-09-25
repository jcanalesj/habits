import 'package:flutter_test/flutter_test.dart';
import 'package:habits/support_links.dart';

void main() {
  test('el mailto apunta al estudio con asunto y cuerpo legibles', () {
    final uri = SupportLinks.mailto(
      subject: 'Idea para Constanza',
      body: 'Hola equipo\n\nLo que echo de menos:',
    );

    expect(uri.scheme, 'mailto');
    expect(uri.path, 'tresvelstudio@gmail.com');
    expect(uri.queryParameters['subject'], 'Idea para Constanza');
    expect(uri.queryParameters['body'], 'Hola equipo\n\nLo que echo de menos:');
    // Los espacios van como %20, no como "+": los clientes de correo
    // mostrarían el "+" literal.
    expect(uri.toString(), isNot(contains('+')));
    expect(uri.toString(), contains('Idea%20para%20Constanza'));
  });
}
