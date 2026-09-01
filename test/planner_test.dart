import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:texfi_fokus/core/notifications/notification_service.dart';
import 'package:texfi_fokus/data/local/database.dart';
import 'package:texfi_fokus/data/repositories/planner_repository_impl.dart';
import 'package:texfi_fokus/data/repositories/task_repository_impl.dart';
import 'package:texfi_fokus/domain/entities/day_plan_entity.dart';
import 'package:texfi_fokus/domain/entities/task_category.dart';
import 'package:texfi_fokus/domain/entities/task_entity.dart';

NotificationCopy _copy() => NotificationCopy(
      channelName: 'habits',
      channelDescription: 'habits',
      habitTitle: (habit) => habit,
      habitBody: (punishment) => punishment,
      dailyTitle: 'End of the day',
      dailyBody: (count) => 'pending:$count',
      dailyProductiveBody: (sessions, minutes, mood) =>
          'done:$sessions/$minutes/$mood',
      dailyAllDoneBody: 'all clear',
    );

void main() {
  group('day plan', () {
    late AppDatabase db;
    late PlannerRepositoryImpl planner;
    late TaskRepositoryImpl tasks;

    final today = DateTime(2026, 4, 6);

    setUp(() async {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      planner = PlannerRepositoryImpl(db);
      tasks = TaskRepositoryImpl(db);

      for (var i = 1; i <= 3; i++) {
        await tasks.createTask(TaskEntity(
          id: 't$i',
          title: 'Задача $i',
          category: TaskCategory.work,
          difficulty: TaskDifficulty.medium,
          createdAt: DateTime(2026, 4, 1),
        ));
      }
    });

    tearDown(() => db.close());

    test('entries keep the order they were added in', () async {
      await planner.addToPlan(day: today, taskId: 't2');
      await planner.addToPlan(day: today, taskId: 't1');
      await planner.addToPlan(day: today, taskId: 't3');

      final plan = await planner.planForDay(today);
      expect(plan.map((e) => e.task.id), ['t2', 't1', 't3']);
    });

    test('the same task is not planned twice for one day', () async {
      await planner.addToPlan(day: today, taskId: 't1');
      await planner.addToPlan(day: today, taskId: 't1');

      expect(await planner.planForDay(today), hasLength(1));
    });

    test("today's plan does not leak into another day", () async {
      await planner.addToPlan(day: today, taskId: 't1');
      // Время внутри дня не должно ничего менять — день нормализуется.
      await planner.addToPlan(
        day: DateTime(2026, 4, 6, 23, 40),
        taskId: 't2',
      );

      expect(await planner.planForDay(today), hasLength(2));
      expect(
        await planner.planForDay(DateTime(2026, 4, 7)),
        isEmpty,
      );
    });

    test('reordering rewrites the positions', () async {
      await planner.addToPlan(day: today, taskId: 't1');
      await planner.addToPlan(day: today, taskId: 't2');
      final plan = await planner.planForDay(today);

      await planner.reorderPlan([plan[1].id, plan[0].id]);

      final reordered = await planner.planForDay(today);
      expect(reordered.map((e) => e.task.id), ['t2', 't1']);
    });

    test('removing an entry leaves the task itself alone', () async {
      await planner.addToPlan(day: today, taskId: 't1');
      final entry = (await planner.planForDay(today)).single;

      await planner.removeFromPlan(entry.id);

      expect(await planner.planForDay(today), isEmpty);
      expect(await tasks.getTaskById('t1'), isNotNull);
    });

    test('done state survives a reload', () async {
      await planner.addToPlan(day: today, taskId: 't1');
      final entry = (await planner.planForDay(today)).single;

      await planner.setPlanEntryDone(entry.id, true);

      expect((await planner.planForDay(today)).single.done, isTrue);
    });
  });

  group('subtasks', () {
    late AppDatabase db;
    late PlannerRepositoryImpl planner;

    setUp(() async {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      planner = PlannerRepositoryImpl(db);
      await TaskRepositoryImpl(db).createTask(TaskEntity(
        id: 't1',
        title: 'Диплом',
        category: TaskCategory.study,
        difficulty: TaskDifficulty.hard,
        createdAt: DateTime(2026, 4, 1),
      ));
    });

    tearDown(() => db.close());

    test('the per-task limit is enforced in the repository', () async {
      for (var i = 0; i < SubtaskEntity.maxPerTask + 3; i++) {
        await planner.addSubtask(taskId: 't1', title: 'Шаг $i');
      }
      expect(
        await planner.subtasksOf('t1'),
        hasLength(SubtaskEntity.maxPerTask),
      );
    });

    test('blank titles are ignored', () async {
      await planner.addSubtask(taskId: 't1', title: '   ');
      expect(await planner.subtasksOf('t1'), isEmpty);
    });

    test('ticking a step persists it', () async {
      await planner.addSubtask(taskId: 't1', title: 'Первый шаг');
      final subtask = (await planner.subtasksOf('t1')).single;

      await planner.setSubtaskDone(subtask.id, true);

      expect((await planner.subtasksOf('t1')).single.done, isTrue);
    });
  });

  group('daily digest text', () {
    final service = NotificationService();

    // Приватный сборщик текста дёргаем через публичный путь: важен именно
    // результат, который увидит пользователь в 21:00.
    String body(DailyDigest digest) =>
        service.debugDailyBody(digest, _copy());

    test('a productive day leads with the good news', () {
      final text = body(const DailyDigest(
        pendingHabits: 2,
        sessions: 3,
        focusMinutes: 95,
        dominantMood: 'full f0kus',
      ));
      expect(text, startsWith('done:3/95/full f0kus'));
      expect(text, contains('pending:2'));
    });

    test('a single short session is not a summary worth sending', () {
      final text = body(const DailyDigest(
        pendingHabits: 1,
        sessions: 1,
        focusMinutes: 12,
        dominantMood: 'neutral',
      ));
      expect(text, 'pending:1');
    });

    test('nothing pending and nothing done still says something kind', () {
      expect(body(const DailyDigest(pendingHabits: 0)), 'all clear');
    });

    test('a productive day with everything closed drops the nagging', () {
      final text = body(const DailyDigest(
        pendingHabits: 0,
        sessions: 4,
        focusMinutes: 120,
        dominantMood: 'good',
      ));
      expect(text, 'done:4/120/good');
    });
  });
}
