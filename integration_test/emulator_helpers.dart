import 'dart:convert';
import 'dart:io';

import 'package:habits/env.dart';

/// Utilidades REST de la Firebase Emulator Suite para los integration tests.
/// Solo funcionan contra los emuladores locales (nunca contra el proyecto
/// real): usan los endpoints `emulator/v1` que la nube no expone.
abstract final class EmulatorHelpers {
  static const projectId = 'constanza-dev';

  static Uri _auth(String path) => Uri.parse(
    'http://${Env.firebaseEmulatorHost}:${Env.authEmulatorPort}$path',
  );

  static Uri _firestore(String path) => Uri.parse(
    'http://${Env.firebaseEmulatorHost}:${Env.firestoreEmulatorPort}$path',
  );

  static Future<(int, String)> _request(
    String method,
    Uri uri, {
    Object? body,
  }) async {
    final client = HttpClient();
    try {
      final request = await client.openUrl(method, uri);
      if (body != null) {
        request.headers.contentType = ContentType.json;
        request.write(jsonEncode(body));
      }
      final response = await request.close();
      final text = await response.transform(utf8.decoder).join();
      return (response.statusCode, text);
    } finally {
      client.close();
    }
  }

  /// Borra todas las cuentas y todos los documentos de los emuladores.
  static Future<void> clearAll() async {
    final (authStatus, _) = await _request(
      'DELETE',
      _auth('/emulator/v1/projects/$projectId/accounts'),
    );
    final (dbStatus, _) = await _request(
      'DELETE',
      _firestore(
        '/emulator/v1/projects/$projectId/databases/(default)/documents',
      ),
    );
    if (authStatus != 200 || dbStatus != 200) {
      throw StateError(
        'No se pudieron limpiar los emuladores (auth=$authStatus, db=$dbStatus)',
      );
    }
  }

  /// Último código fuera de banda (OOB) emitido para [email] del tipo
  /// indicado (`VERIFY_EMAIL` o `PASSWORD_RESET`).
  static Future<Map<String, dynamic>?> latestOobCode(
    String email, {
    required String requestType,
  }) async {
    final (status, body) = await _request(
      'GET',
      _auth('/emulator/v1/projects/$projectId/oobCodes'),
    );
    if (status != 200) throw StateError('oobCodes devolvió $status');
    final codes = (jsonDecode(body) as Map<String, dynamic>)['oobCodes'];
    final matches = (codes as List)
        .cast<Map<String, dynamic>>()
        .where((c) => c['email'] == email && c['requestType'] == requestType)
        .toList();
    return matches.isEmpty ? null : matches.last;
  }

  /// Simula que el usuario abre el enlace de verificación del correo.
  static Future<void> openLink(String link) async {
    final (status, body) = await _request('GET', Uri.parse(link));
    if (status != 200) {
      throw StateError('El enlace devolvió $status: $body');
    }
  }

  /// Simula que el usuario fija una contraseña nueva desde el enlace de
  /// restablecimiento (lo que hace la página web de Firebase).
  static Future<void> resetPassword({
    required String oobCode,
    required String newPassword,
  }) async {
    final (status, body) = await _request(
      'POST',
      _auth(
        '/identitytoolkit.googleapis.com/v1/accounts:resetPassword?key=fake-api-key',
      ),
      body: {'oobCode': oobCode, 'newPassword': newPassword},
    );
    if (status != 200) {
      throw StateError('resetPassword devolvió $status: $body');
    }
  }
}
