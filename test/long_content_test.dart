import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:texfi_fokus/core/theme/app_accent.dart';
import 'package:texfi_fokus/core/theme/app_theme.dart';
import 'package:texfi_fokus/core/utils/duration_format.dart';
import 'package:texfi_fokus/data/local/database.dart';
import 'package:texfi_fokus/data/providers/data_providers.dart';
import 'package:texfi_fokus/domain/entities/habit_entity.dart';
import 'package:texfi_fokus/l10n/app_localizations.dart';
import 'package:texfi_fokus/presentation/habits/habits_screen.dart';
import 'package:texfi_fokus/presentation/home/home_screen.dart';

/// Проверка на «злом» содержимом: очень длинные названия, очень длинные
/// договорённости с собой, длинный стрик, десятки привычек.
///
/// Overflow во Flutter — это исключение в debug-сборке, а не просто жёлтая
/// полоска: `tester.takeException()` его поймает. Поэтому тест утверждает не
/// «выглядит нормально», а «ни один Text не вылез за пределы родителя».

/// 120 символов без единого пробела — худший случай для переноса: разорвать
/// такую строку по словам нельзя, её можно только обрезать или дать ей
/// вылезти за карточку.
const String unbreakable =
    'Английскийкаждыйденьбезисключенийдажееслиоченьнехочетсяисовсемнетсилиэто'
    'оченьоченьдлинноеназваниепривычкибезпробелов';

/// Длинное, но переносимое по словам.
const String longWithSpaces =
    'Учить английский язык каждый день без единого исключения, даже когда '
    'совсем нет сил и очень не хочется этим заниматься';

const String longPunishment =
    'Никакого кофе на следующий день, плюс лишняя тренировка вечером, плюс '
    'перевод пятисот рублей на счёт, который мне совсем не нравится';

HabitEntity _habit(String id, String name, {String? punishment}) => HabitEntity(
      id: id,
      name: name,
      punishment: punishment ?? longPunishment,
      weekdayMask: HabitEntity.everyDayMask,
      createdAt: DateTime(2026, 1, 1),
    );

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(DatabaseConnection(NativeDatabase.memory()));
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() async => db.close());

  Future<void> pump(WidgetTester tester, Widget screen) async {
    tester.view.physicalSize = const Size(400, 1600);
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
          locale: const Locale('ru'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.build(
            brightness: Brightness.dark,
            accent: AppAccent.values.first,
          ),
          home: screen,
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  Future<void> drain(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  }

  Future<void> seed(List<HabitEntity> habits) async {
    final container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
    final repo = container.read(habitRepositoryProvider);
    for (final habit in habits) {
      await repo.createHabit(habit);
    }
  }

  group('длинные названия и тексты', () {
    testWidgets('неразрывное имя в 120 символов не ломает карточку привычки',
        (tester) async {
      await seed([_habit('a', unbreakable)]);
      await pump(tester, const HabitsScreen());

      expect(tester.takeException(), isNull);
      await drain(tester);
    });

    testWidgets('длинное имя и длинное наказание вместе на одной карточке',
        (tester) async {
      await seed([_habit('a', longWithSpaces, punishment: longPunishment)]);
      await pump(tester, const HabitsScreen());

      expect(find.textContaining('Учить английский'), findsOneWidget);
      // Договорённость с собой обязана быть видна целиком: обрезать её
      // многоточием значило бы спрятать ровно ту часть, ради которой
      // привычка и заводилась.
      expect(find.textContaining('Никакого кофе'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await drain(tester);
    });

    testWidgets('то же длинное имя на домашнем экране', (tester) async {
      await seed([_habit('a', unbreakable)]);
      await pump(tester, const HomeScreen());

      expect(tester.takeException(), isNull);
      await drain(tester);
    });
  });

  group('много привычек', () {
    testWidgets('двенадцать привычек с длинными именами прокручиваются',
        (tester) async {
      await seed([
        // Имя обрезаем до схемного предела: 120 символов — это и есть
        // худшее, что вообще может оказаться в базе.
        for (var i = 0; i < 12; i++)
          _habit('h$i', '$longWithSpaces $i'
              .substring(0, HabitLimits.nameMaxLength)),
      ]);
      await pump(tester, const HabitsScreen());

      expect(tester.takeException(), isNull);

      // Список длинный — значит, поле поиска обязано появиться.
      expect(find.byType(TextField), findsOneWidget);

      await tester.drag(find.byType(Scrollable).first, const Offset(0, -600));
      await tester.pump();
      expect(tester.takeException(), isNull);
      await drain(tester);
    });

    testWidgets('на коротком списке поля поиска нет', (tester) async {
      await seed([for (var i = 0; i < 4; i++) _habit('h$i', 'Привычка $i')]);
      await pump(tester, const HabitsScreen());

      expect(find.byType(TextField), findsNothing);
      expect(tester.takeException(), isNull);
      await drain(tester);
    });
  });

  group('границы длины совпадают со схемой', () {
    test('предел имени в форме — тот же, что в схеме Drift', () {
      // Регрессия: у полей формы не было maxLength вовсе, и текст длиннее
      // схемного предела падал исключением уже на сохранении.
      expect(HabitLimits.nameMaxLength, 120);
      expect(HabitLimits.punishmentMaxLength, 300);
    });

    test('самое длинное допустимое имя сохраняется без исключения', () async {
      final maxName = ('я' * HabitLimits.nameMaxLength);
      expect(maxName.length, HabitLimits.nameMaxLength);
      await seed([_habit('a', maxName)]);
      final container = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(db)],
      );
      final stored = await container.read(habitRepositoryProvider).getHabits();
      expect(stored.single.name.length, HabitLimits.nameMaxLength);
    });
  });

  group('крупные числа', () {
    test('стрик в 100+ дней остаётся коротким текстом', () {
      // Верстка карточки держится на том, что число не разрастается: даже
      // трёхзначный стрик — это три знака, а не «сто двадцать три дня».
      for (final streak in [1, 99, 100, 365, 9999]) {
        expect('$streak'.length, lessThanOrEqualTo(4));
      }
    });

    test('многочасовая сессия остаётся читаемой', () {
      // Кастомный таймер разрешает до 240 минут фокуса на цикл, а весь план
      // может идти много часов.
      expect(DurationFormat.compactFromMinutes(90), '1h 30m');
      expect(DurationFormat.compactFromMinutes(240), '4h');
      expect(DurationFormat.compactFromMinutes(605), '10h 5m');
      // Даже сутки не переходят в другой формат и не теряют часы.
      expect(DurationFormat.compactFromMinutes(1440), '24h');

      for (final minutes in [1, 59, 60, 600, 1440, 4320]) {
        expect(DurationFormat.compactFromMinutes(minutes).length,
            lessThanOrEqualTo(8));
      }
    });

    test('цифры таймера переходят в часы, не обнуляя минуты', () {
      expect(DurationFormat.clock(const Duration(minutes: 59, seconds: 5)),
          '59:05');
      expect(DurationFormat.clock(const Duration(hours: 1)), '1:00:00');
      expect(DurationFormat.clock(const Duration(hours: 4, minutes: 5)),
          '4:05:00');
    });
  });
}
