import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/haptics/haptics.dart';
import '../../core/theme/app_colors_ext.dart';
import '../../core/theme/app_l10n_ext.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles_ext.dart';
import '../../domain/entities/session_entity.dart';
import '../shared/enum_labels.dart';
import '../shared/pixel_button.dart';
import '../shared/pixel_sprite.dart';

/// То, что пользователь рассказал о закончившейся сессии. Все поля
/// необязательные — лист можно закрыть, не ответив ни на один вопрос.
class SessionWrapUp {
  const SessionWrapUp({
    this.rating,
    this.reason,
    this.note,
    this.restart = false,
  });

  final int? rating;
  final InterruptionReason? reason;
  final String? note;

  /// Пользователь просит сразу такую же сессию — без повторного check-in.
  final bool restart;
}

/// Итог сессии: оценка, причина прерывания и короткая заметка.
///
/// Три вопроса в одном листе, а не три экрана подряд: после оборванной
/// сессии человек и так не в лучшем настроении, и цепочка модалок отсюда
/// просто выталкивает. Всё видно сразу, ответить можно на что угодно —
/// или ни на что.
class SessionWrapUpSheet extends StatefulWidget {
  const SessionWrapUpSheet({
    super.key,
    required this.title,
    required this.askInterruptionReason,
  });

  final String title;

  /// Спрашивать ли причину — только у прерванной сессии.
  final bool askInterruptionReason;

  /// Ограничение заметки. Короткое сознательно: это подпись к сессии, а не
  /// дневник, и длинное поле превратило бы быстрый вопрос в обязанность.
  static const int noteMaxLength = 60;

  /// Небольшой набор «пиксельных стикеров»: один тап вместо набора текста.
  static const List<String> stickers = ['🔥', '🙂', '😐', '😵', '💡', '🐢'];

  @override
  State<SessionWrapUpSheet> createState() => _SessionWrapUpSheetState();
}

class _SessionWrapUpSheetState extends State<SessionWrapUpSheet> {
  final _noteController = TextEditingController();
  int? _rating;
  InterruptionReason? _reason;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _appendSticker(String sticker) {
    final next = '${_noteController.text}$sticker';
    if (next.characters.length > SessionWrapUpSheet.noteMaxLength) {
      Haptics.warning();
      return;
    }
    Haptics.tap();
    _noteController.text = next;
    _noteController.selection =
        TextSelection.collapsed(offset: _noteController.text.length);
  }

  void _submit({bool restart = false}) {
    Haptics.success();
    Navigator.of(context).pop(
      SessionWrapUp(
        rating: _rating,
        reason: _reason,
        note: _noteController.text,
        restart: restart,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return SafeArea(
      child: Padding(
        // Отступ под клавиатуру: поле заметки иначе оказывается под ней.
        padding: EdgeInsets.only(
          left: AppSpacing.page,
          right: AppSpacing.page,
          top: AppSpacing.page,
          bottom: AppSpacing.page + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(widget.title, style: context.text.headline),
              AppSpacing.gapLg,
              Text(l10n.timerRateQuestion, style: context.text.body),
              AppSpacing.gapMd,
              _RatingRow(
                value: _rating,
                onChanged: (value) {
                  Haptics.success();
                  setState(() => _rating = value);
                },
              ),
              if (widget.askInterruptionReason) ...[
                AppSpacing.gapXl,
                Text(l10n.interruptionQuestion, style: context.text.body),
                AppSpacing.gapSm,
                Text(l10n.interruptionOptional, style: context.text.caption),
                AppSpacing.gapMd,
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    for (final reason in InterruptionReason.values)
                      _PixelChip(
                        label: reason.label(l10n),
                        selected: _reason == reason,
                        onTap: () {
                          Haptics.tap();
                          setState(
                            () => _reason = _reason == reason ? null : reason,
                          );
                        },
                      ),
                  ],
                ),
              ],
              AppSpacing.gapXl,
              Text(l10n.sessionNoteQuestion, style: context.text.body),
              AppSpacing.gapMd,
              TextField(
                controller: _noteController,
                maxLength: SessionWrapUpSheet.noteMaxLength,
                textInputAction: TextInputAction.done,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(
                    SessionWrapUpSheet.noteMaxLength,
                  ),
                ],
                decoration: InputDecoration(hintText: l10n.sessionNoteHint),
                onSubmitted: (_) => _submit(),
              ),
              AppSpacing.gapSm,
              Wrap(
                spacing: AppSpacing.sm,
                children: [
                  for (final sticker in SessionWrapUpSheet.stickers)
                    _PixelChip(
                      label: sticker,
                      selected: false,
                      onTap: () => _appendSticker(sticker),
                    ),
                ],
              ),
              AppSpacing.gapXl,
              PixelButton(label: l10n.commonSave, onPressed: () => _submit()),
              AppSpacing.gapMd,
              // «Ещё одну такую же» стоит рядом с «готово», а не вместо
              // него: инерцию после удачной сессии грех терять на повторный
              // check-in, где всё равно будут те же ответы.
              PixelButton(
                label: l10n.timerRepeat,
                primary: false,
                sprite: PixelSprites.play,
                onPressed: () => _submit(restart: true),
              ),
              AppSpacing.gapMd,
              PixelButton(
                label: l10n.commonSkip,
                primary: false,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Оценка продуктивности 1–5 — второй, более честный сигнал для обучения:
/// «досидел» и «поработал» это не одно и то же.
class _RatingRow extends StatelessWidget {
  const _RatingRow({required this.value, required this.onChanged});

  final int? value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: [
        for (var rating = 1; rating <= 5; rating++)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: GestureDetector(
                onTap: () => onChanged(rating),
                child: Container(
                  height: 56,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: value == rating
                        ? colors.accent.withValues(alpha: 0.2)
                        : colors.surfaceVariant,
                    border: Border.all(
                      color: value == rating ? colors.accent : colors.divider,
                      width: AppRadius.pixelBorder,
                    ),
                  ),
                  child: Text(
                    '$rating',
                    style: context.text.counterMedium.copyWith(
                      color: value == rating ? colors.accent : null,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Прямоугольная выбираемая плашка: тот же язык, что у остальных пиксельных
/// элементов — рамка в 2px, без скруглений и заливок-«таблеток».
class _PixelChip extends StatelessWidget {
  const _PixelChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: selected
              ? colors.accent.withValues(alpha: 0.2)
              : colors.surfaceVariant,
          border: Border.all(
            color: selected ? colors.accent : colors.divider,
            width: AppRadius.pixelBorder,
          ),
        ),
        child: Text(
          label,
          style: context.text.body.copyWith(
            color: selected ? colors.accent : colors.textSecondary,
          ),
        ),
      ),
    );
  }
}
