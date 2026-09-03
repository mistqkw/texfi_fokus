import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_page_transitions.dart';
import '../game/battle_screen.dart';
import '../game/game_providers.dart';
import 'session_guard_dialog.dart';
import 'timer_screen.dart';

/// Экран, который должен вести следующую сессию.
///
/// Развилка ровно одна и ровно в одну проверку: в игровом режиме сессия идёт
/// против конкретного противника, и показывать её должен экран боя; во всех
/// остальных случаях — обычный таймер. Сам таймер, движок и запись сессии от
/// этого не зависят — обе ветки ведут одну и ту же сессию одним и тем же
/// контроллером.
///
/// Функция общая, а не три одинаковых тернарника по экранам, потому что
/// узел здесь обязан быть **свежим**. Экран боя получает свой узел снимком —
/// это правильно на время одной сессии, но следующей сессии нужен снимок
/// заново: к её началу по узлу уже нанесён урон, а то и вовсе побеждён, и
/// текущим стал следующий. Повторное использование прежнего снимка
/// показывало бы бой с только что убитым противником на полной полоске.
Widget nextSessionScreen(WidgetRef ref) {
  final node =
      ref.read(gameModeOnProvider) ? ref.read(currentNodeProvider) : null;
  return node == null ? const TimerScreen() : BattleScreen(node: node);
}

/// Запускает следующую сессию тем же составом: та же задача, настроение и
/// категория, новый противник.
///
/// Через ту же мягкую паузу, что и обычный старт. «Ещё одну такую же» — это
/// всё-таки старт новой сессии, и обходить защиту от выгорания он не должен:
/// иначе три оборванных подряд, набранные именно повторами, никогда не
/// доходят до разговора, ради которого эта защита и написана. Отказ здесь
/// означает «не сейчас» — экран просто закрывается.
///
/// Возвращает `false`, если старт не состоялся: вызывающий тогда уходит с
/// экрана обычным путём.
Future<bool> restartSession(BuildContext context, WidgetRef ref) async {
  if (!await confirmSessionStart(context, ref)) return false;
  if (!context.mounted) return false;

  Navigator.of(context).pushReplacement(
    pixelDissolveRoute<void>(nextSessionScreen(ref)),
  );
  return true;
}
