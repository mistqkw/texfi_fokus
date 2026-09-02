import 'package:flutter/material.dart';

import '../../core/constants/app_info.dart';
import '../../core/theme/app_colors_ext.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles_ext.dart';
import '../shared/pixel_background.dart';
import '../shared/pixel_sprite.dart';

/// Титры. Экран, на который нет ни одной ссылки в интерфейсе.
///
/// Открывается только тем, кто зачем-то настойчиво тыкал в название
/// приложения на экране настроек. Ничего не делает, ничего не сохраняет и
/// закрывается любым касанием — в приложении от него не зависит вовсе
/// ничего.
class CreditsScreen extends StatefulWidget {
  const CreditsScreen({super.key});

  @override
  State<CreditsScreen> createState() => _CreditsScreenState();
}

class _CreditsScreenState extends State<CreditsScreen>
    with SingleTickerProviderStateMixin {
  /// Титры ползут снизу вверх и уходят на новый круг — как в играх, где их
  /// оставляли крутиться, пока кто-нибудь не нажмёт кнопку.
  late final AnimationController _roll = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 26),
  )..repeat();

  @override
  void dispose() {
    _roll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return PixelBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.of(context).maybePop(),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final height = constraints.maxHeight;
              return ClipRect(
                child: AnimatedBuilder(
                  animation: _roll,
                  builder: (context, child) => Transform.translate(
                    // От «весь текст ниже экрана» до «весь текст выше него».
                    offset: Offset(0, height * (1 - 2 * _roll.value)),
                    child: child,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      PixelSprite(
                        rows: PixelSprites.moodFace,
                        size: 72,
                        color: colors.accent,
                      ),
                      AppSpacing.gapXl,
                      Text(
                        AppInfo.name,
                        textAlign: TextAlign.center,
                        style: context.text.headline
                            .copyWith(color: colors.accent),
                      ),
                      AppSpacing.gapSm,
                      Text(
                        AppInfo.version,
                        textAlign: TextAlign.center,
                        style: context.text.caption
                            .copyWith(color: colors.textSecondary),
                      ),
                      AppSpacing.gapXxl,
                      Padding(
                        padding: AppSpacing.screen,
                        child: Text(
                          // TODO: m$ta, напиши здесь что хочешь
                          //
                          // Это единственное место во всём приложении, где
                          // текст оставлен незаполненным нарочно. Титры — не
                          // документация и не описание функций: что в них
                          // будет написано, решает автор, а не тот, кто их
                          // собрал. Строка ниже — заглушка, чтобы экран было
                          // на что смотреть, пока она не заменена.
                          _placeholder,
                          textAlign: TextAlign.center,
                          style: context.text.body
                              .copyWith(color: colors.textSecondary),
                        ),
                      ),
                      AppSpacing.gapXxl,
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// Заглушка на месте будущего текста титров. Ни на что не ссылается и
  /// нигде больше не используется — её место в файле именно здесь, рядом с
  /// TODO, чтобы её нельзя было заменить и забыть.
  static const String _placeholder = '* * *';
}
