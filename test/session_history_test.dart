import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:texfi_fokus/core/theme/app_accent.dart';
import 'package:texfi_fokus/core/theme/app_theme.dart';
import 'package:texfi_fokus/data/local/database.dart';
import 'package:texfi_fokus/data/providers/data_providers.dart';
import 'package:texfi_fokus/domain/entities/focus_technique.dart';
import 'package:texfi_fokus/domain/entities/mood.dart';
import 'package:texfi_fokus/domain/entities/session_entity.dart';
import 'package:texfi_fokus/domain/entities/task_category.dart';
import 'package:texfi_fokus/l10n/app_localizations.dart';
import 'package:texfi_fokus/presentation/shared/session_photo.dart';
import 'package:texfi_fokus/presentation/statistics/statistics_screen.dart';

/// Лента истории — единственное место, где прикреплённое фото вообще видно
/// после сессии. Проверяется именно она: что превью появляется у сессии с
/// фото и не появляется у сессии без него.
///
/// На Linux системного выбора фото нет вовсе, поэтому пройти этот путь руками
/// на машине сборки невозможно. Тест здесь не дополняет ручную проверку, а
/// заменяет её.
SessionEntity _session(
  String id, {
  required String title,
  String? photoPath,
}) =>
    SessionEntity(
      id: id,
      taskTitle: title,
      category: TaskCategory.study,
      difficulty: TaskDifficulty.medium,
      mood: Mood.good,
      technique: FocusTechnique.values.first,
      plannedFocusMinutes: 25,
      plannedBreakMinutes: 5,
      plannedCycles: 1,
      actualFocusSeconds: 1500,
      outcome: SessionOutcome.completed,
      startedAt: DateTime.now().subtract(const Duration(hours: 2)),
      endedAt: DateTime.now().subtract(const Duration(hours: 1)),
      contextKey: 'good|study|medium|morning|7',
      photoPath: photoPath,
    );

void main() {
  setUpAll(() {
    // Тот же приём, что и в widget_test: throttled debugPrint заводит таймер,
    // на котором биндинг падает с «A Timer is still pending».
    debugPrint = debugPrintSynchronously;
  });

  late AppDatabase db;
  late Directory temp;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    temp = await Directory.systemTemp.createTemp('texfi_history_test');
  });

  tearDown(() async {
    await db.close();
    if (await temp.exists()) await temp.delete(recursive: true);
  });

  Future<void> pumpStatistics(WidgetTester tester) async {
    // Экран читает настройку начала недели (её использует heatmap), поэтому
    // без SharedPreferences он теперь не поднимается.
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    // Экран статистики длинный, а лента истории — в самом низу. Вместо
    // прокрутки даём тесту высокое «окно»: на экране со статистикой живут
    // несколько вложенных прокручиваемых областей (графики, heatmap), и
    // докручивать сквозь них — лишний источник хрупкости в тесте, который
    // проверяет совсем не прокрутку.
    tester.view.physicalSize = const Size(1200, 6000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.build(
            brightness: Brightness.dark,
            accent: AppAccent.values.first,
          ),
          home: const StatisticsScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  /// Снимает дерево и даёт отработать таймерам drift.
  Future<void> drain(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  }

  testWidgets('a session with a photo shows a preview next to its title',
      (tester) async {
    final photo = File(p.join(temp.path, 'desk.png'))..writeAsBytesSync([1, 2]);
    await SessionRepositoryImplHelper(db).add(
      _session('s1', title: 'Thesis', photoPath: photo.path),
    );

    await pumpStatistics(tester);

    expect(find.text('Recent sessions'), findsOneWidget);
    expect(find.text('Thesis'), findsOneWidget);
    expect(find.byType(SessionPhotoThumbnail), findsOneWidget);

    await drain(tester);
  });

  testWidgets('a session without a photo shows no preview at all',
      (tester) async {
    await SessionRepositoryImplHelper(db).add(
      _session('s1', title: 'Thesis'),
    );

    await pumpStatistics(tester);

    expect(find.text('Thesis'), findsOneWidget);
    // Ровно требование «фото не добавлено — ничего не меняется в UI».
    expect(find.byType(SessionPhotoThumbnail), findsNothing);

    await drain(tester);
  });

  testWidgets('an empty range says so instead of showing a blank block',
      (tester) async {
    await pumpStatistics(tester);

    expect(find.text('Recent sessions'), findsOneWidget);
    expect(find.text('Nothing in this range yet.'), findsOneWidget);

    await drain(tester);
  });
}

/// Тонкая обёртка, чтобы тест не тащил в себя весь репозиторий ради одной
/// вставки.
class SessionRepositoryImplHelper {
  SessionRepositoryImplHelper(this._db);

  final AppDatabase _db;

  Future<void> add(SessionEntity session) async {
    await ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(_db)],
    ).read(sessionRepositoryProvider).addSession(session);
  }
}
