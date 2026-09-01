import 'package:flutter/material.dart';

import '../../core/haptics/haptics.dart';
import '../../core/theme/app_colors_ext.dart';
import '../../core/theme/app_l10n_ext.dart';

/// Короткое «сделано — отменить» после действия, которое легко сделать
/// случайно.
///
/// Именно snackbar, а не диалог с подтверждением: подтверждать каждую отметку
/// привычки значило бы удваивать число нажатий ради ошибки, которая случается
/// раз в месяц. Snackbar не стоит пользователю ничего, пока не понадобился.
///
/// Отдельная функция, а не вызов `showSnackBar` на месте, по двум причинам:
/// подпись действия должна быть одна на всё приложение, и предыдущий
/// snackbar надо гасить — иначе быстрая серия отметок выстраивает очередь
/// плашек, и «Отменить» в ней относится уже не к тому, что человек видит.
void showUndoSnackBar(
  BuildContext context, {
  required String message,
  required VoidCallback onUndo,
  Duration duration = const Duration(seconds: 4),
}) {
  final messenger = ScaffoldMessenger.of(context);
  final l10n = context.l10n;
  final colors = context.colors;

  messenger.clearSnackBars();
  messenger.showSnackBar(
    SnackBar(
      content: Text(message),
      duration: duration,
      action: SnackBarAction(
        label: l10n.commonUndo,
        textColor: colors.accent,
        onPressed: () {
          Haptics.tap();
          onUndo();
        },
      ),
    ),
  );
}
