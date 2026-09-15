import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/screen/focus_screen_mode.dart';
import '../../core/theme/app_l10n_ext.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles_ext.dart';
import '../settings/settings_providers.dart';

/// Отдельный экран-часы — тот же приглушённый монохромный вид, что и «тихий
/// режим» на экране сессии ([FocusScreenMode]), но без сессии: открывается
/// из настроек в любой момент, а не только во время фокуса.
///
/// Названо в интерфейсе честно — «Экран-часы», а не «AOD»: настоящий
/// Always-On Display рисует система при выключенном экране, и обычному
/// приложению это недоступно ни на одном пути. Здесь — полноэкранные часы
/// с погашенной яркостью и, если это разрешено настройкой
/// [hideStatusBarInAodProvider], без чужих значков сверху — то немногое, что
/// приложение может честно предложить для «положил телефон на стол, пока
/// работаю» без системных прав на настоящий AOD.
class AlwaysOnClockScreen extends ConsumerStatefulWidget {
  const AlwaysOnClockScreen({super.key});

  @override
  ConsumerState<AlwaysOnClockScreen> createState() =>
      _AlwaysOnClockScreenState();
}

class _AlwaysOnClockScreenState extends ConsumerState<AlwaysOnClockScreen> {
  /// Тот же механизм, что держит экран сессии: не гаснуть, приглушить
  /// яркость, спрятать статус-бар. Полем — снятие обязано отработать в
  /// `dispose()`.
  final FocusScreenMode _screen = FocusScreenMode();

  Timer? _ticker;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _enter();
    // Секунда — частота перерисовки, не что-то, что здесь вообще важно
    // считать: часы показывают часы и минуты, а не секунды с точностью до
    // кадра.
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  Future<void> _enter() async {
    await _screen.enter();
    await _screen.setQuiet(
      true,
      hideStatusBar: ref.read(hideStatusBarInAodProvider),
    );
  }

  @override
  void dispose() {
    _ticker?.cancel();
    // Единственный путь снятия — отрабатывает при любом способе ухода:
    // тапом, жестом «назад», системной кнопкой.
    _screen.release();
    super.dispose();
  }

  static String _twoDigits(int value) => value.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    // Цвета заданы прямо здесь, мимо темы, — тем же способом и по той же
    // причине, что и в `QuietTimerView`: смысл экрана в том, чтобы ничего
    // не привлекало взгляд ярче, чем сами часы.
    const foreground = Color(0xFFBFBFBF);
    const dim = Color(0xFF4A4A4A);
    final time = '${_twoDigits(_now.hour)}:${_twoDigits(_now.minute)}';

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.of(context).maybePop(),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.page,
                    ),
                    child: Text(
                      time,
                      style: context.text.sectionTitle.copyWith(
                        color: foreground,
                        fontSize: 64,
                        height: 1.2,
                      ),
                    ),
                  ),
                ),
                AppSpacing.gapXl,
                Text(
                  l10n.timerQuietModeHint,
                  textAlign: TextAlign.center,
                  style: context.text.caption.copyWith(color: dim),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
