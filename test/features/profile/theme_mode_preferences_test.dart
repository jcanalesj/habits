import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habits/features/profile/appearance/theme_mode_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('ThemeModeCodec', () {
    test('codifica y decodifica los dos modos disponibles', () {
      for (final mode in [ThemeMode.light, ThemeMode.dark]) {
        expect(ThemeModeCodec.decode(ThemeModeCodec.encode(mode)), mode);
      }
    });

    test('migra el antiguo modo sistema a claro', () {
      expect(ThemeModeCodec.decode('system'), ThemeMode.light);
      expect(ThemeModeCodec.encode(ThemeMode.system), 'light');
    });

    test('devuelve null ante valores desconocidos', () {
      expect(ThemeModeCodec.decode(null), isNull);
      expect(ThemeModeCodec.decode('sepia'), isNull);
    });
  });

  group('SharedThemeModePreferences', () {
    test('usa el tema claro por defecto y persiste el cambio', () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final storage = SharedThemeModePreferences(preferences);

      expect(storage.mode, ThemeMode.light);
      await storage.setMode(ThemeMode.dark);
      expect(storage.mode, ThemeMode.dark);
      expect(preferences.getString(SharedThemeModePreferences.key), 'dark');
    });

    test('ignora un valor corrupto', () async {
      SharedPreferences.setMockInitialValues({
        SharedThemeModePreferences.key: 'sepia',
      });
      final preferences = await SharedPreferences.getInstance();
      expect(SharedThemeModePreferences(preferences).mode, ThemeMode.light);
    });
  });
}
