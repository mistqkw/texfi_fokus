import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles_ext.dart';
import '../../core/utils/duration_format.dart';

/// Тихий режим: тот же таймер, с которого снято всё остальное.
///
/// Специально не называется AOD ни здесь, ни в интерфейсе. Настоящий
/// Always-On Display рисует система при выключенном экране, и обычному
/// приложению такое недоступно — обещать это названием значило бы обещать
/// то, чего не будет.
///
/// Монохром — не стилизация: цветной пиксель-арт с подсвеченным спрайтом
/// врага и оранжевым HP-баром на приглушённой яркости остаётся ровно тем же
/// раздражителем, от которого этот режим и уводит.
class QuietTimerView extends StatelessWidget {
  const QuietTimerView({
    super.key,
    required this.remaining,
    required this.hint,
    required this.onExit,
  });

  final Duration remaining;
  final String hint;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    // Цвета заданы прямо здесь, мимо темы и акцента: в этом и смысл режима.
    // Тема остаётся собой — на неё этот экран не влияет.
    const foreground = Color(0xFFBFBFBF);
    const dim = Color(0xFF4A4A4A);

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onExit,
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
                      DurationFormat.clock(remaining),
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
                  hint,
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
