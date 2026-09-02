import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_l10n_ext.dart';
import '../../domain/entities/game_entities.dart';
import '../../domain/entities/game_rules.dart';
import '../game/game_providers.dart';
import '../mood_checkin/mood_checkin_providers.dart';
import '../shared/notification_sync.dart';
import 'session_wrap_up_sheet.dart';
import 'timer_providers.dart';

/// Что осталось от завершившейся сессии: ответы пользователя и итог игрового
/// захода.
class SessionFinishOutcome {
  const SessionFinishOutcome({required this.wrapUp, required this.encounter});

  final SessionWrapUp? wrapUp;

  /// Итог игрового слоя. В обычном режиме — всегда «ничего не произошло».
  final EncounterResult encounter;

  /// Пользователь попросил повторить такую же сессию.
  bool get restart => wrapUp?.restart ?? false;
}

/// Общий финал сессии: спросить, сохранить, скормить движку, начислить
/// игровое, пересобрать уведомления.
///
/// Вынесено из экрана таймера, потому что экранов, на которых сессия
/// заканчивается, стало два: обычный таймер и экран боя. Дублировать эту
/// последовательность значило бы завести второй способ сохранять сессию — и
/// однажды обнаружить, что в одном из них забыли, например, обучить движок.
///
/// Порядок внутри неизменен и важен: сначала сохраняется сама сессия и
/// обучается движок рекомендаций, и только потом трогается игровой слой. Игра
/// — надстройка, и её сбой не должен утащить с собой основную запись.
///
/// Возвращает null, если экран закрыли посреди процесса: продолжать
/// навигацию по мёртвому контексту нельзя.
Future<SessionFinishOutcome?> finishSession(
  BuildContext context,
  WidgetRef ref,
  TimerState state,
) async {
  final l10n = context.l10n;

  final wrapUp = await showModalBottomSheet<SessionWrapUp>(
    context: context,
    isDismissible: true,
    isScrollControlled: true,
    builder: (context) => SessionWrapUpSheet(
      title: state.completedFully ? l10n.timerDoneTitle : l10n.timerAbortedTitle,
      askInterruptionReason: !state.completedFully,
    ),
  );

  await ref.read(saveSessionProvider)(
    state: state,
    rating: wrapUp?.rating,
    interruptionReason: wrapUp?.reason,
    note: wrapUp?.note,
  );

  // Черновик ещё жив — из него берутся сложность и настроение, с которыми
  // сессия начиналась.
  final draft = ref.read(sessionDraftProvider);
  final encounter = await ref.read(gameSessionRecorderProvider)(
    focusSeconds: state.focusSeconds,
    difficulty: draft.difficulty,
    mood: draft.mood,
    completedFully: state.completedFully,
    // Категория — оттуда же, из черновика. Игровой слой смотрит на неё
    // только ради переклички мира с тем, чем человек занят; в записи сессии
    // и в весах движка рекомендаций от этого не меняется ничего.
    category: draft.category,
    // Редкий отклик переключателя настроения — разовая надбавка поверх уже
    // посчитанного опыта. В самой записи сессии его нет: там обычный
    // full f0kus, и движок рекомендаций учится ровно на нём.
    bonusXp: draft.unstoppable ? GameRules.unstoppableBonusXp : 0,
  );

  if (!context.mounted) return null;

  // Вечерняя сводка собирается в момент планирования уведомления, поэтому
  // после каждой сессии её пересобираем: иначе «сегодня две сессии» так и
  // осталось бы вчерашним текстом.
  await syncNotifications(ref, l10n);
  if (!context.mounted) return null;

  return SessionFinishOutcome(wrapUp: wrapUp, encounter: encounter);
}
