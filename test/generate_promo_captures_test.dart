import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habits/features/habits/1_domain/services/timezone_bootstrap.dart';
import 'package:habits/theme/app_theme.dart';

const _captureSize = Size(540, 960);
const _captureKey = ValueKey('promo-capture-boundary');

void main() {
  setUpAll(() {
    initializeTimezones();
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('00 precarga recursos gráficos', (tester) async {
    _configureView(tester);
    await _renderAndSave(
      tester,
      const _BrandFrame(
        eyebrow: 'CONSTANZA',
        title: 'Constanza',
        accentWord: 'Constanza',
        footer: 'Constanza',
        showCat: true,
      ),
      '.warmup.png',
    );
  });

  testWidgets('01 hook motivación', (tester) async {
    _configureView(tester);
    // Calienta la fuente empaquetada antes de la primera captura del proceso.
    await tester.pumpWidget(
      const MaterialApp(home: Center(child: Text('Constanza'))),
    );
    await tester.pumpAndSettle();
    await _renderAndSave(
      tester,
      const _BrandFrame(
        eyebrow: 'CONSTANZA',
        title: 'No necesitas\nmás motivación.',
        accentWord: 'motivación.',
        footer: 'Los cambios grandes empiezan pequeño.',
        showCat: true,
      ),
      '01_hook_motivacion.png',
    );
  });

  testWidgets('02 hook constancia', (tester) async {
    _configureView(tester);
    await _renderAndSave(
      tester,
      const _BrandFrame(
        eyebrow: 'UN DÍA CADA VEZ',
        title: 'Necesitas\nconstancia.',
        accentWord: 'constancia.',
        footer: 'Empieza pequeño. Un hábito. Un día.',
        showCat: true,
      ),
      '02_hook_constancia.png',
    );
  });

  testWidgets('03 inicio con hábitos', (tester) async {
    _configureView(tester);
    await _renderAndSave(
      tester,
      const _AppScreenFrame(mode: _AppMode.home),
      '03_inicio_habitos.png',
    );
  });

  testWidgets('04 hábito completado', (tester) async {
    _configureView(tester);
    await _renderAndSave(
      tester,
      const _AppScreenFrame(mode: _AppMode.completed),
      '04_habito_completado.png',
    );
  });

  testWidgets('05 progreso de racha', (tester) async {
    _configureView(tester);
    await _renderAndSave(tester, const _ProgressFrame(), '05_racha_4_dias.png');
  });

  testWidgets('06 estadísticas', (tester) async {
    _configureView(tester);
    await _renderAndSave(
      tester,
      const _AppScreenFrame(mode: _AppMode.stats),
      '06_estadisticas.png',
    );
  });

  testWidgets('07 calendario', (tester) async {
    _configureView(tester);
    await _renderAndSave(
      tester,
      const _AppScreenFrame(mode: _AppMode.calendar),
      '07_calendario.png',
    );
  });

  testWidgets('08 cierre y CTA', (tester) async {
    _configureView(tester);
    await _renderAndSave(tester, const _FinalFrame(), '08_cierre_cta.png');
  });
}

void _configureView(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 1920);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<void> _renderAndSave(
  WidgetTester tester,
  Widget child,
  String fileName,
) async {
  await tester.pumpWidget(
    RepaintBoundary(
      key: _captureKey,
      child: SizedBox(
        width: 1080,
        height: 1920,
        child: Align(
          alignment: Alignment.topLeft,
          child: Transform.scale(
            scale: 2,
            alignment: Alignment.topLeft,
            child: SizedBox.fromSize(size: _captureSize, child: child),
          ),
        ),
      ),
    ),
  );
  // Algunas pantallas contienen ilustraciones animadas que, por diseño,
  // nunca se estabilizan. Damos tiempo a streams y assets y congelamos el
  // fotograma en vez de usar pumpAndSettle.
  for (var i = 0; i < 3; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }

  await expectLater(
    find.byKey(_captureKey),
    matchesGoldenFile('../capturas/$fileName'),
  );
}

class _WarmBackdrop extends StatelessWidget {
  const _WarmBackdrop({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Material(
    child: DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFAF5), Color(0xFFF2ECFF), Color(0xFFFFF4EA)],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          const Positioned(
            top: -100,
            right: -90,
            child: _Glow(size: 310, color: Color(0x2E9A7CF3)),
          ),
          const Positioned(
            bottom: 90,
            left: -120,
            child: _Glow(size: 330, color: Color(0x33F4A261)),
          ),
          SafeArea(child: child),
        ],
      ),
    ),
  );
}

class _Glow extends StatelessWidget {
  const _Glow({required this.size, required this.color});
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}

class _BrandFrame extends StatelessWidget {
  const _BrandFrame({
    required this.eyebrow,
    required this.title,
    required this.accentWord,
    required this.footer,
    this.showCat = false,
  });

  final String eyebrow;
  final String title;
  final String accentWord;
  final String footer;
  final bool showCat;

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light,
    home: _WarmBackdrop(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(38, 52, 38, 44),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              eyebrow,
              style: const TextStyle(
                color: Color(0xFF7559C9),
                fontSize: 15,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.2,
              ),
            ),
            if (!showCat)
              Opacity(
                opacity: 0,
                child: Image.asset(
                  'assets/images/cat.png',
                  width: 1,
                  height: 1,
                ),
              ),
            const Spacer(),
            if (showCat) ...[
              Center(
                child: Image.asset(
                  'assets/images/cat.png',
                  width: 260,
                  height: 190,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 42),
            ],
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF2E2936),
                fontSize: 58,
                height: 1.04,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 26),
            Container(
              width: 72,
              height: 7,
              decoration: BoxDecoration(
                color: const Color(0xFFF4A261),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const Spacer(),
            Text(
              footer,
              style: const TextStyle(
                color: Color(0xFF544D64),
                fontSize: 22,
                height: 1.3,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _ProgressFrame extends StatelessWidget {
  const _ProgressFrame();

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light,
    home: _WarmBackdrop(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 54, 32, 48),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'CADA LOGRO CUENTA',
                style: TextStyle(
                  color: Color(0xFF7559C9),
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.1,
                ),
              ),
            ),
            const Spacer(),
            const _ProgressPill(label: 'Hoy', trailing: '✓', active: true),
            const SizedBox(height: 18),
            const Icon(Icons.arrow_downward_rounded, color: Color(0xFFB6A9DC)),
            const SizedBox(height: 18),
            const _ProgressPill(label: 'Mañana', trailing: '✓', active: true),
            const SizedBox(height: 18),
            const Icon(Icons.arrow_downward_rounded, color: Color(0xFFB6A9DC)),
            const SizedBox(height: 18),
            const _ProgressPill(label: 'Tu racha', trailing: '4 días'),
            const Spacer(),
            const Text(
              'Pequeños pasos.\nUn progreso que permanece.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF2E2936),
                fontSize: 31,
                height: 1.15,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _ProgressPill extends StatelessWidget {
  const _ProgressPill({
    required this.label,
    required this.trailing,
    this.active = false,
  });
  final String label;
  final String trailing;
  final bool active;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 25),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .9),
      borderRadius: BorderRadius.circular(28),
      border: Border.all(color: const Color(0xFFE7DEF8)),
      boxShadow: const [
        BoxShadow(
          color: Color(0x147559C9),
          blurRadius: 24,
          offset: Offset(0, 10),
        ),
      ],
    ),
    child: Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: active ? const Color(0xFFDCF5E8) : const Color(0xFFFFE7D5),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              active ? 'OK' : '4×',
              style: TextStyle(
                color: active
                    ? const Color(0xFF2E9B68)
                    : const Color(0xFFEB7B32),
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w800),
          ),
        ),
        Text(
          trailing,
          style: const TextStyle(
            color: Color(0xFF7559C9),
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    ),
  );
}

enum _AppMode { home, completed, stats, calendar }

class _AppScreenFrame extends StatelessWidget {
  const _AppScreenFrame({required this.mode});
  final _AppMode mode;

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light,
    home: Scaffold(
      backgroundColor: const Color(0xFFFFFBF7),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 22),
          child: switch (mode) {
            _AppMode.home || _AppMode.completed => _home(),
            _AppMode.stats => _stats(),
            _AppMode.calendar => _calendar(),
          },
        ),
      ),
    ),
  );

  Widget _header(String title, String subtitle) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          const _LogoMark(),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 31, fontWeight: FontWeight.w900),
            ),
          ),
          Image.asset('assets/images/cat.png', width: 58, height: 48),
        ],
      ),
      const SizedBox(height: 6),
      Text(
        subtitle,
        style: const TextStyle(color: Color(0xFF766F7F), fontSize: 17),
      ),
    ],
  );

  Widget _home() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _header('Buenos días, Alex', 'Hoy cuenta. Hazlo sencillo.'),
      const SizedBox(height: 22),
      _card(
        child: const Row(
          children: [
            Text(
              '4×',
              style: TextStyle(
                fontSize: 34,
                color: Color(0xFFEB7B32),
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Racha general', style: TextStyle(fontSize: 18)),
                Text(
                  '4 días',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 25),
      const Text(
        'Mis hábitos',
        style: TextStyle(fontSize: 27, fontWeight: FontWeight.w900),
      ),
      const SizedBox(height: 14),
      _habit(
        'L',
        'Leer 20 min',
        const Color(0xFFFFE5C8),
        mode == _AppMode.completed,
      ),
      _habit('F', 'Comer fruta', const Color(0xFFDDF3E7), false),
      _habit('Z', 'Dormir 8 h', const Color(0xFFE7E1FA), false),
      _habit('EN', 'Hablar inglés', const Color(0xFFFFDEE8), false),
      if (mode == _AppMode.completed) ...[
        const Spacer(),
        _card(
          color: const Color(0xFF7559C9),
          child: const Row(
            children: [
              Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 31),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  '¡Bien hecho! Cada paso cuenta.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ],
  );

  Widget _habit(String marker, String label, Color color, bool done) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: _card(
      color: color,
      child: Row(
        children: [
          SizedBox(
            width: 38,
            child: Text(
              marker,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                color: Color(0xFF514765),
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
            ),
          ),
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: done ? const Color(0xFF45AD79) : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFD7D0E3), width: 2),
            ),
            child: done
                ? const Center(
                    child: Text(
                      'OK',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  )
                : null,
          ),
        ],
      ),
    ),
  );

  Widget _stats() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _header('Estadísticas', 'Tu progreso esta semana'),
      const SizedBox(height: 24),
      Row(
        children: [
          Expanded(child: _metric('4×', '4', 'Racha actual')),
          const SizedBox(width: 12),
          Expanded(child: _metric('OK', '82%', 'Cumplimiento')),
        ],
      ),
      const SizedBox(height: 20),
      _card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Actividad semanal',
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 220,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  for (final item in const [
                    ('L', .48),
                    ('M', .65),
                    ('X', .58),
                    ('J', .83),
                    ('V', 1.0),
                    ('S', .72),
                    ('D', .9),
                  ])
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: 34,
                          height: 165 * item.$2,
                          decoration: BoxDecoration(
                            color: const Color(0xFF8E72DB),
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        const SizedBox(height: 9),
                        Text(
                          item.$1,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 20),
      _card(
        color: const Color(0xFFE5F5EB),
        child: const Row(
          children: [
            Text(
              '+',
              style: TextStyle(
                color: Color(0xFF31956A),
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(width: 10),
            Text(
              'Vas mejorando. Sigue así.',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    ],
  );

  Widget _calendar() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _header('Tu calendario', 'La constancia se ve así'),
      const SizedBox(height: 25),
      _card(
        child: Column(
          children: [
            const Text(
              'Septiembre',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 24),
            GridView.count(
              crossAxisCount: 7,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 8,
              children: [
                for (var day = 1; day <= 28; day++)
                  Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: day < 23 && day % 6 != 0
                          ? const Color(0xFF8E72DB)
                          : const Color(0xFFF0ECF6),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      '$day',
                      style: TextStyle(
                        color: day < 23 && day % 6 != 0
                            ? Colors.white
                            : const Color(0xFF777080),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 22),
      _card(
        color: const Color(0xFFFFEBD8),
        child: const Row(
          children: [
            SizedBox(
              width: 70,
              height: 58,
              child: Image(image: AssetImage('assets/images/cat.png')),
            ),
            SizedBox(width: 14),
            Expanded(
              child: Text(
                'Mira todo lo que ya has construido.',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
      ),
    ],
  );

  Widget _metric(String marker, String value, String label) => _card(
    child: Column(
      children: [
        Text(
          marker,
          style: const TextStyle(
            fontSize: 24,
            color: Color(0xFF7559C9),
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
        ),
        Text(label, textAlign: TextAlign.center),
      ],
    ),
  );

  Widget _card({required Widget child, Color color = Colors.white}) =>
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(25),
          boxShadow: const [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 18,
              offset: Offset(0, 7),
            ),
          ],
        ),
        child: child,
      );
}

class _LogoMark extends StatelessWidget {
  const _LogoMark();
  @override
  Widget build(BuildContext context) => Container(
    width: 52,
    height: 52,
    alignment: Alignment.center,
    decoration: const BoxDecoration(
      gradient: LinearGradient(colors: [Color(0xFF7559C9), Color(0xFFF4A261)]),
      shape: BoxShape.circle,
    ),
    child: const Text(
      'C',
      style: TextStyle(
        color: Colors.white,
        fontSize: 29,
        fontWeight: FontWeight.w900,
      ),
    ),
  );
}

class _FinalFrame extends StatelessWidget {
  const _FinalFrame();

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light,
    home: _WarmBackdrop(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(38, 40, 38, 42),
        child: Column(
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _LogoMark(),
                SizedBox(width: 8),
                Text(
                  'Constanza',
                  style: TextStyle(
                    color: Color(0xFF7559C9),
                    fontSize: 38,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Image.asset(
              'assets/images/cat.png',
              width: 320,
              height: 230,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 46),
            const Text(
              'No cambies tu vida\nen un día.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF2E2936),
                fontSize: 42,
                height: 1.08,
                fontWeight: FontWeight.w900,
                letterSpacing: -1.4,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Cámbiala un día cada vez.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF7559C9),
                fontSize: 29,
                height: 1.15,
                fontWeight: FontWeight.w900,
              ),
            ),
            const Spacer(),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7559C9), Color(0xFF9679E8)],
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x407559C9),
                    blurRadius: 24,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: const Text(
                'Empieza hoy con Constanza',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
