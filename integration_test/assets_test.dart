// Comprueba que los assets declarados llegan al bundle REAL del dispositivo.
//
// Los tests de widget usan el bundle del host y pueden pasar mientras la app
// falla en el móvil con "Unable to load asset". Esto se ejecuta sobre el
// binario de verdad, así que detecta un pubspec mal declarado.
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Lista completa de assets del proyecto. Si añades uno y olvidas
  // declararlo en pubspec.yaml, este test falla antes que la app.
  const assets = [
    'assets/backgrounds/login_background.png',
    'assets/backgrounds/registro_background.png',
    'assets/backgrounds/splash_background.png',
    'assets/icons/edit.png',
    'assets/icons/progress/constanza_brush.png',
    'assets/icons/progress/constanza_cepillo_gris_vacio.png',
    'assets/icons/progress/constanza_dog_paw_empty_v2.svg',
    'assets/icons/progress/constanza_dog_paw_v2.svg',
    'assets/icons/progress/constanza_fruit_apple.svg',
    'assets/icons/progress/constanza_fruit_apple_empty.svg',
    'assets/icons/progress/constanza_pill.svg',
    'assets/icons/progress/constanza_pill_empty.svg',
    'assets/icons/progress/constanza_star.svg',
    'assets/icons/progress/constanza_star_empty.svg',
    'assets/icons/progress/constanza_water_drop_empty.svg',
    'assets/icons/progress/constanza_water_drop_thin.svg',
    'assets/icons/protector.png',
    'assets/images/cards/card1.png',
    'assets/images/cat-avatar-atlas.png',
    'assets/images/empty_habits.png',
    'assets/images/zona_horaria.png',
    'assets/logo/image copy.png',
    'assets/logo/logo.png',
  ];

  for (final asset in assets) {
    testWidgets('$asset está en el bundle', (tester) async {
      await tester.runAsync(() async {
        final data = await rootBundle.load(asset);
        expect(data.lengthInBytes, greaterThan(0), reason: asset);
      });
    });
  }
}
