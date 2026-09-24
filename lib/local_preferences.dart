import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Preferencias locales del dispositivo, cargadas en `main` antes del primer
/// frame. Es `null` en tests o si el plugin no está disponible: en ese caso
/// los valores viven solo en memoria.
final sharedPreferencesProvider = Provider<SharedPreferences?>((ref) => null);
