import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:texfi_fokus/data/local/database.dart';
import 'package:texfi_fokus/data/providers/data_providers.dart';
import 'package:texfi_fokus/main.dart';
import 'package:texfi_fokus/presentation/settings/settings_providers.dart';

/// Поднимает приложение на базе в памяти и на пустых настройках.
///
/// `AppDatabase.forTesting` с [NativeDatabase.memory] не трогает диск, так
/// что тесты не зависят ни друг от друга, ни от машины.
Future<void> _pumpApp(
  WidgetTester tester, {
  bool onboardingDone = true,
}) async {
  SharedPreferences.setMockInitialValues({
    PrefKeys.onboardingDone: onboardingDone,
  });
  final prefs = await SharedPreferences.getInstance();
  final database = AppDatabase.forTesting(NativeDatabase.memory());
  addTearDown(database.close);


  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        databaseProvider.overrideWithValue(database),
      ],
      child: const TexFiFokusApp(),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

/// Снимает дерево и даёт отработать таймерам, которые drift ставит при
/// отмене подписки на запрос (`StreamQueryStore.markAsClosed` — Timer нулевой
/// длительности). Вызывается в конце каждого теста, а не в teardown: биндинг
/// проверяет «нет незакрытых таймеров» ещё до teardown-ов.
Future<void> _drain(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  // Именно с длительностью: pump() без аргумента рисует кадр, но не двигает
  // фейковые часы, и таймер нулевой длительности так и остаётся в очереди.
  await tester.pump(const Duration(milliseconds: 1));
}

void main() {
  setUpAll(() {
    // В тестах шрифты не качаем: иначе google_fonts уходит в сеть и
    // оставляет после себя незакрытые таймеры, на которых падает биндинг.
    GoogleFonts.config.allowRuntimeFetching = false;

    // Плагина уведомлений в тестовом окружении нет, сервис ловит
    // MissingPluginException и пишет её через debugPrint. Стандартный
    // debugPrint throttled — он заводит таймер, и биндинг падает на
    // «A Timer is still pending». Синхронный вывод таймеров не создаёт.
    debugPrint = debugPrintSynchronously;
  });

  testWidgets('Home renders with an empty database', (tester) async {
    await _pumpApp(tester);

    // Каркас с нижней навигацией — минимальный признак того, что тема,
    // локализация и слой данных поднялись вместе.
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);

    await _drain(tester);
  });

  testWidgets('First run shows onboarding instead of the shell',
      (tester) async {
    await _pumpApp(tester, onboardingDone: false);

    expect(find.byType(PageView), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);

    await _drain(tester);
  });
}
