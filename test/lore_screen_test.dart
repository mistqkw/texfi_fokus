import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:texfi_fokus/core/theme/app_accent.dart';
import 'package:texfi_fokus/core/theme/app_theme.dart';
import 'package:texfi_fokus/data/local/database.dart';
import 'package:texfi_fokus/data/providers/data_providers.dart';
import 'package:texfi_fokus/data/repositories/game_repository_impl.dart';
import 'package:texfi_fokus/domain/entities/game_rules.dart';
import 'package:texfi_fokus/l10n/app_localizations.dart';
import 'package:texfi_fokus/l10n/app_localizations_en.dart';
import 'package:texfi_fokus/presentation/game/character_screen.dart';

/// Сквозная нить проверяется здесь по одному-единственному требованию, и оно
/// не про сюжет: история обязана оставаться в стороне от пути к таймеру.
///
/// Отсюда и выбор того, что утверждается. Не «текст красивый» и не «обрывки
/// складываются в историю» — это не проверяется тестом и не должно. А вот
/// «непройденный обрывок не показывает своего текста» и «до первой победы
/// карточка всё равно объясняет себя» — это поведение, и сломать его молча
/// очень легко.
void main() {
  late AppDatabase db;
  final AppLocalizations en = AppLocalizationsEn();

  setUp(() {
    db = AppDatabase.forTesting(DatabaseConnection(NativeDatabase.memory()));
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() async => db.close());

  /// Заводит партию и доводит счётчик побеждённых боссов до [bossKills].
  ///
  /// Пишется прямо в прогресс, а не проигрыванием карты: тест здесь про
  /// экран, а не про то, как боссы побеждаются, — это уже проверено в
  /// `game_repository_test.dart`.
  Future<void> seedBossKills(int bossKills) async {
    final game = GameRepositoryImpl(db);
    await game.setEnabled(true);
    await db.customStatement(
      'UPDATE player_progress SET boss_kills = ?, total_xp = ?',
      [bossKills, 500],
    );
  }

  Future<void> pump(WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final prefs = await SharedPreferences.getInstance();
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
          home: const CharacterScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  /// Снимает экран и добивает то, что на нём осталось тикать.
  ///
  /// На экране персонажа живёт бесконечная анимация аватара, и тест, который
  /// просто заканчивается, оставляет её таймер висеть — прогон встаёт
  /// намертво. Тот же приём, что и в `long_content_test.dart`.
  Future<void> drain(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  }

  testWidgets('до первой победы карточка объясняет себя и молчит о содержании',
      (tester) async {
    await seedBossKills(0);
    await pump(tester);

    expect(find.text(en.loreTitle), findsOneWidget);
    expect(find.text(en.loreEmpty), findsOneWidget);

    // Ни один текст обрывка не должен быть виден заранее — иначе читать их
    // потом уже незачем.
    expect(find.text(en.loreFragment1), findsNothing);
    expect(find.text(en.loreFragment4), findsNothing);

    await drain(tester);
  });

  testWidgets('победа над боссом открывает ровно один обрывок',
      (tester) async {
    await seedBossKills(1);
    await pump(tester);

    expect(find.text(en.loreFragment1), findsOneWidget);
    expect(find.text(en.loreFragment2), findsNothing);

    // Следующий по счёту показан строкой-заглушкой: видно, что впереди
    // что-то есть, но не видно что.
    expect(find.text(en.loreLocked), findsOneWidget);

    await drain(tester);
  });

  testWidgets('последний обрывок ждёт полного прохождения карты',
      (tester) async {
    // Все боссы, кроме последнего.
    await seedBossKills(GameRules.worldCount - 1);
    await pump(tester);
    expect(find.text(en.loreFragment4), findsNothing);

    await drain(tester);
  });

  testWidgets('пройденная карта открывает последний обрывок', (tester) async {
    await seedBossKills(GameRules.worldCount);
    await pump(tester);

    expect(find.text(en.loreFragment4), findsOneWidget);
    // И заглушек больше нет: открывать нечего.
    expect(find.text(en.loreLocked), findsNothing);

    await drain(tester);
  });
}
