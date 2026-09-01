import 'package:flutter_test/flutter_test.dart';
import 'package:texfi_fokus/domain/entities/habit_entity.dart';
import 'package:texfi_fokus/presentation/habits/habits_providers.dart';

HabitEntity _habit(String name, {String punishment = 'штраф', String? reward}) {
  return HabitEntity(
    id: name,
    name: name,
    punishment: punishment,
    reward: reward,
    weekdayMask: HabitEntity.everyDayMask,
    createdAt: DateTime(2026, 1, 1),
  );
}

void main() {
  group('фильтр привычек', () {
    final habits = [
      _habit('Спорт'),
      _habit('Английский', punishment: 'без сериала'),
      _habit('Чтение', reward: 'новая книга'),
      _habit('спортивная ходьба'),
    ];

    test('пустой запрос возвращает список как есть', () {
      expect(filterHabits(habits, ''), same(habits));
      expect(filterHabits(habits, '   '), same(habits));
    });

    test('регистр не важен', () {
      expect(
        filterHabits(habits, 'СПОРТ').map((h) => h.name),
        ['Спорт', 'спортивная ходьба'],
      );
    });

    test('совпадение ищется в любом месте названия, не только в начале', () {
      expect(filterHabits(habits, 'ходьба').map((h) => h.name),
          ['спортивная ходьба']);
    });

    test('ищем и по тексту наказания', () {
      // Формулировку наказания человек пишет своими словами, и вспомнить её
      // бывает проще, чем формальное название.
      expect(
        filterHabits(habits, 'сериал').map((h) => h.name),
        ['Английский'],
      );
    });

    test('ищем и по тексту награды', () {
      expect(filterHabits(habits, 'книга').map((h) => h.name), ['Чтение']);
    });

    test('пробелы по краям запроса не мешают', () {
      expect(filterHabits(habits, '  чтение  ').map((h) => h.name), ['Чтение']);
    });

    test('ничего не найдено — пустой список, а не весь набор', () {
      expect(filterHabits(habits, 'зумба'), isEmpty);
    });

    test('фильтр не меняет исходный список', () {
      final before = List.of(habits);
      filterHabits(habits, 'спорт');
      expect(habits, before);
    });

    test('порог поиска — десяток: короткий список фильтровать нечем', () {
      expect(habitSearchThreshold, 10);
    });
  });
}
