import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_info.dart';
import '../../core/haptics/haptics.dart';
import '../../core/theme/app_colors_ext.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles_ext.dart';

/// Была ли загрузочная заставка уже показана в этом запуске.
///
/// Провайдер, а не глобальная переменная: состояние обязано жить ровно
/// столько же, сколько `ProviderScope`. Так заставка играет один раз за
/// холодный старт, но каждый тест и каждый новый запуск получают её честно
/// сначала.
final bootPlayedProvider = StateProvider<bool>((ref) => false);

/// Экран запуска: пиксельный знак собирается из блоков под нарастающий
/// вибро-отклик и «защёлкивается», после чего растворяется в приложение.
///
/// Заставка не блокирует загрузку, а прикрывает её: [child] строится под
/// ней с первого кадра, поэтому к моменту растворения приложение уже
/// отрисовано. Реальная асинхронная инициализация ([onReady]) идёт
/// параллельно, и переход происходит по позднейшему из двух событий —
/// анимация не обрывается на быстрой машине и не тормозит на медленной.
class BootGate extends ConsumerStatefulWidget {
  const BootGate({super.key, required this.child, this.onReady});

  final Widget child;

  /// Асинхронная инициализация, которую имеет смысл прикрыть заставкой.
  final Future<void> Function()? onReady;

  /// Ключ слоя заставки — по нему тест отличает «играет» от «сыграла».
  static const Key overlayKey = Key('boot-overlay');

  /// Полная длительность заставки — 1.5 с: два акцентных такта плюс
  /// растворение. Собрана из тех же токенов, что и остальная моторика
  /// приложения, а не подобрана отдельным числом. Верхняя граница
  /// «короткого росчерка»: дольше — и запуск ощущается как загрузка.
  static final Duration duration = AppMotion.flourish * 2 + AppMotion.slow;

  @override
  ConsumerState<BootGate> createState() => _BootGateState();
}

class _BootGateState extends ConsumerState<BootGate>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  /// Заставка снята, дерево показывает только приложение.
  bool _done = false;

  /// Такты, на которых уже отработал вибро-отклик. Пороги — доли от полной
  /// длительности, привязанные к тому, что происходит на экране.
  static const List<double> _hapticBeats = [0.0, 0.24, 0.42, 0.60, 0.74];
  final Set<int> _firedBeats = {};

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: BootGate.duration);

    if (ref.read(bootPlayedProvider)) {
      // Уже играли в этом запуске — заставка не для каждого перестроения
      // дерева, а для холодного старта.
      _done = true;
      widget.onReady?.call();
      return;
    }

    _controller.addListener(_fireHaptics);
    _run();
  }

  Future<void> _run() async {
    final ready = widget.onReady?.call() ?? Future<void>.value();

    // Инициализация не должна ронять запуск: если сервис уведомлений не
    // поднялся, пользователю всё равно нужно попасть в приложение.
    await Future.wait<void>([
      _controller.forward(),
      ready.catchError((Object _) {}),
    ]);

    if (!mounted) return;
    ref.read(bootPlayedProvider.notifier).state = true;
    setState(() => _done = true);
  }

  /// Каждый такт отрабатывает ровно один раз и только вперёд по времени —
  /// иначе на подтормаживании кадров вибро посыпалось бы очередью.
  void _fireHaptics() {
    final t = _controller.value;
    for (var i = 0; i < _hapticBeats.length; i++) {
      if (t < _hapticBeats[i] || _firedBeats.contains(i)) continue;
      _firedBeats.add(i);
      switch (i) {
        case 0:
          Haptics.bootPowerOn();
        case 4:
          Haptics.bootLock();
        default:
          Haptics.bootAssemble(i - 1);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_done) return widget.child;

    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        // Заставка не должна перехватывать случайные тапы по интерфейсу,
        // который уже отрисован под ней.
        IgnorePointer(
          key: BootGate.overlayKey,
          child: _BootOverlay(progress: _controller),
        ),
      ],
    );
  }
}

class _BootOverlay extends StatelessWidget {
  const _BootOverlay({required this.progress});

  final Animation<double> progress;

  /// Момент, с которого заставка начинает растворяться в приложение.
  static const double _dissolveFrom = 0.86;

  /// Момент, с которого проявляется название.
  static const double _wordmarkFrom = 0.70;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AnimatedBuilder(
      animation: progress,
      builder: (context, _) {
        final t = progress.value;
        final out = ((t - _dissolveFrom) / (1 - _dissolveFrom)).clamp(0.0, 1.0);
        final wordmark =
            ((t - _wordmarkFrom) / 0.16).clamp(0.0, 1.0) * (1 - out);

        return Stack(
          fit: StackFit.expand,
          children: [
            CustomPaint(
              painter: _BootPainter(
                progress: t,
                dissolve: out,
                accent: colors.accent,
                accentBright: colors.onAccent,
                background: colors.background,
                scanline: colors.scanline,
              ),
            ),
            // Название — обычным виджетом, а не в painter: пиксельный шрифт
            // тянется из темы, и дублировать его метрики на канвасе значило
            // бы держать две правды об одном шрифте.
            Align(
              alignment: const Alignment(0, 0.38),
              child: Opacity(
                opacity: wordmark,
                child: Transform.translate(
                  offset: Offset(0, (1 - wordmark) * 6),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.page,
                    ),
                    child: Text(
                      AppInfo.name,
                      textAlign: TextAlign.center,
                      style: context.text.sectionTitle.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Рисует всю заставку: включение «экрана», сборку знака, вспышку
/// защёлкивания и пиксельное растворение.
///
/// Всё детерминировано хешем координат — как в фоне и переходах между
/// экранами: узор обязан совпадать от кадра к кадру, иначе картинка кипит.
class _BootPainter extends CustomPainter {
  const _BootPainter({
    required this.progress,
    required this.dissolve,
    required this.accent,
    required this.accentBright,
    required this.background,
    required this.scanline,
  });

  /// 0..1 — общий ход заставки.
  final double progress;

  /// 0..1 — растворение заставки в приложение на финальном отрезке.
  final double dissolve;

  final Color accent;
  final Color accentBright;
  final Color background;
  final Color scanline;

  /// Знак «f0» — начало слова f0kus. Ноль перечёркнут: так он читается
  /// именно как знак, а не как буква O.
  static const List<String> _glyph = [
    '..##..###.',
    '.#...#...#',
    '.#...#..##',
    '####.#.#.#',
    '.#...##..#',
    '.#...#...#',
    '.#...#...#',
    '.#....###.',
  ];

  /// Отрезок «включения питания» — до него знака ещё нет.
  static const double _powerOn = 0.18;

  /// Отрезок сборки знака.
  static const double _assembleFrom = 0.16;
  static const double _assembleTo = 0.70;

  /// Момент защёлкивания и длина вспышки.
  static const double _lock = 0.72;
  static const double _flashLength = 0.14;

  static const double _dissolveBlock = 18;
  static const double _scanlineStep = 4;

  double _hash(int x, int y) {
    var h = x * 374761393 + y * 668265263;
    h = (h ^ (h >> 13)) * 1274126177;
    h = h ^ (h >> 16);
    return (h & 0xFFFF) / 0xFFFF;
  }

  @override
  void paint(Canvas canvas, Size size) {
    _paintBackground(canvas, size);
    _paintPowerOn(canvas, size);
    _paintGlyph(canvas, size);
    _paintScanlines(canvas, size);
  }

  /// Фон — сплошной, пока не начнётся растворение; дальше он уходит теми же
  /// пиксельными блоками, что и переходы между экранами.
  void _paintBackground(Canvas canvas, Size size) {
    final paint = Paint()..color = background;
    if (dissolve <= 0) {
      canvas.drawRect(Offset.zero & size, paint);
      return;
    }

    final cols = (size.width / _dissolveBlock).ceil();
    final rows = (size.height / _dissolveBlock).ceil();
    for (var y = 0; y < rows; y++) {
      for (var x = 0; x < cols; x++) {
        // Волна сверху вниз: без неё растворение выглядит статичным шумом.
        final wave = rows == 0 ? 0.0 : y / rows * 0.35;
        final threshold = (_hash(x, y) * 0.65 + wave).clamp(0.0, 1.0);
        if (dissolve < threshold) {
          canvas.drawRect(
            Rect.fromLTWH(
              x * _dissolveBlock,
              y * _dissolveBlock,
              _dissolveBlock,
              _dissolveBlock,
            ),
            paint,
          );
        }
      }
    }
  }

  /// Включение ЭЛТ: тонкая яркая полоса по центру разворачивается в высоту.
  void _paintPowerOn(Canvas canvas, Size size) {
    if (progress >= _powerOn || dissolve > 0) return;
    final p = (progress / _powerOn).clamp(0.0, 1.0);
    final centerY = size.height / 2;

    // Полоса раскрывается быстро, а её яркость гаснет — иначе экран
    // остался бы залит акцентом.
    final height = size.height * p * p;
    final glow = (1 - p) * 0.35;
    if (height > 1 && glow > 0.01) {
      canvas.drawRect(
        Rect.fromLTWH(0, centerY - height / 2, size.width, height),
        Paint()..color = accent.withValues(alpha: glow),
      );
    }

    final line = (1 - p).clamp(0.0, 1.0);
    if (line > 0.01) {
      canvas.drawRect(
        Rect.fromLTWH(0, centerY - 1.5, size.width, 3),
        Paint()..color = accentBright.withValues(alpha: line),
      );
    }
  }

  /// Знак собирается блок за блоком: у каждой ячейки свой порог появления,
  /// поэтому она «прилетает» в своё время, а не вместе со всеми.
  void _paintGlyph(Canvas canvas, Size size) {
    final assemble =
        ((progress - _assembleFrom) / (_assembleTo - _assembleFrom))
            .clamp(0.0, 1.0);
    if (assemble <= 0) return;

    final cols = _glyph.first.length;
    final rows = _glyph.length;

    // Знак занимает половину меньшей стороны — на телефоне и на десктопе
    // он должен выглядеть одинаково крупно относительно экрана.
    final cell =
        ((size.shortestSide * 0.5) / cols).clamp(3.0, 26.0).floorToDouble();
    final originX = ((size.width - cols * cell) / 2).roundToDouble();
    // Знак смещён выше центра ровно настолько, чтобы под ним осталось место
    // на название: на низком окне (десктоп в половину экрана) они иначе
    // наезжают друг на друга.
    final originY =
        ((size.height - rows * cell) / 2 - size.height * 0.10).roundToDouble();

    final flash =
        (1 - ((progress - _lock).abs() / _flashLength)).clamp(0.0, 1.0);
    final baseColor = Color.lerp(accent, accentBright, flash * 0.85)!;
    final fade = 1 - dissolve;
    if (fade <= 0) return;

    for (var y = 0; y < rows; y++) {
      for (var x = 0; x < cols; x++) {
        if (_glyph[y][x] != '#') continue;

        final threshold = _hash(x + 7, y + 13) * 0.9;
        if (assemble < threshold) continue;

        // Собственная короткая анимация ячейки: приезжает по вертикали и
        // проявляется. 0.12 — доля хода сборки, за которую блок «садится».
        final local = ((assemble - threshold) / 0.12).clamp(0.0, 1.0);
        final drop = (1 - local) * cell * 1.2;
        // Направление подлёта чередуется по хешу — сборка выглядит живой,
        // а не как один общий сдвиг.
        final sign = _hash(x + 31, y + 3) > 0.5 ? 1.0 : -1.0;

        canvas.drawRect(
          Rect.fromLTWH(
            originX + x * cell,
            originY + y * cell + drop * sign,
            cell - 1,
            cell - 1,
          ),
          Paint()
            ..color = baseColor.withValues(alpha: local * fade),
        );
      }
    }

    // Вспышка защёлкивания — рамка вокруг знака, ровно один раз.
    if (flash > 0.02) {
      final inset = cell;
      canvas.drawRect(
        Rect.fromLTWH(
          originX - inset,
          originY - inset,
          cols * cell + inset * 2,
          rows * cell + inset * 2,
        ),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = AppRadius.pixelBorder
          ..color = accent.withValues(alpha: flash * 0.9 * fade),
      );
    }
  }

  /// Сканлайны — общая для приложения ретро-подложка. Заметнее всего в
  /// начале и полностью исчезают к растворению.
  void _paintScanlines(Canvas canvas, Size size) {
    final alpha = (1 - dissolve) * (0.9 - progress * 0.35);
    if (alpha <= 0.01) return;
    final paint = Paint()
      ..color = scanline.withValues(alpha: scanline.a * alpha)
      ..strokeWidth = 1;
    for (var y = 0.0; y < size.height; y += _scanlineStep) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_BootPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.dissolve != dissolve ||
      oldDelegate.accent != accent ||
      oldDelegate.background != background;
}
