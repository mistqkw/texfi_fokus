import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:texfi_fokus/core/photos/session_photo_store.dart';
import 'package:texfi_fokus/data/local/database.dart';
import 'package:texfi_fokus/data/local/export_service.dart';
import 'package:texfi_fokus/data/repositories/session_repository_impl.dart';
import 'package:texfi_fokus/domain/entities/focus_technique.dart';
import 'package:texfi_fokus/domain/entities/mood.dart';
import 'package:texfi_fokus/domain/entities/session_entity.dart';
import 'package:texfi_fokus/domain/entities/task_category.dart';

/// Хранилище-подделка: помнит, что у него просили удалить.
///
/// Смысл проверки — не в том, что `File.delete` работает (он работает), а в
/// том, что его вообще вызывают. Забытый вызов не ломает ничего заметного:
/// приложение продолжает работать, просто на устройстве навсегда остаётся
/// файл, на который больше никто не ссылается. Такую ошибку можно поймать
/// только тестом.
class _FakePhotoStore implements SessionPhotoStore {
  final List<String?> deleted = [];
  final List<String> saved = [];

  @override
  Future<String> save(String sourcePath) async {
    saved.add(sourcePath);
    return '/photos/${p.basename(sourcePath)}';
  }

  @override
  Future<void> delete(String? path) async => deleted.add(path);
}

SessionEntity _session(String id, {String? photoPath}) => SessionEntity(
      id: id,
      taskTitle: 'Диплом',
      category: TaskCategory.study,
      difficulty: TaskDifficulty.medium,
      mood: Mood.good,
      technique: FocusTechnique.values.first,
      plannedFocusMinutes: 25,
      plannedBreakMinutes: 5,
      plannedCycles: 2,
      actualFocusSeconds: 1500,
      outcome: SessionOutcome.completed,
      startedAt: DateTime(2026, 3, 1, 10),
      endedAt: DateTime(2026, 3, 1, 11),
      contextKey: 'good|study|medium|morning|7',
      photoPath: photoPath,
    );

void main() {
  late AppDatabase db;
  late _FakePhotoStore photos;
  late SessionRepositoryImpl repository;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    photos = _FakePhotoStore();
    repository = SessionRepositoryImpl(db, photos: photos);
  });

  tearDown(() => db.close());

  group('фото в сессии', () {
    test('путь доезжает до базы и обратно', () async {
      await repository.addSession(_session('s1', photoPath: '/photos/a.jpg'));

      final stored = await repository.watchRecentSessions().first;
      expect(stored.single.photoPath, '/photos/a.jpg');
      expect(stored.single.hasPhoto, isTrue);
    });

    test('сессия без фото ничем не отличается от прежних', () async {
      await repository.addSession(_session('s1'));

      final stored = await repository.watchRecentSessions().first;
      expect(stored.single.photoPath, isNull);
      expect(stored.single.hasPhoto, isFalse);
    });
  });

  group('удаление сессии', () {
    test('удаляет и запись, и файл', () async {
      await repository.addSession(_session('s1', photoPath: '/photos/a.jpg'));

      await repository.deleteSession('s1');

      expect(await repository.watchRecentSessions().first, isEmpty);
      expect(photos.deleted, ['/photos/a.jpg']);
    });

    test('сессия без фото удаляется без попытки стереть чужой файл', () async {
      await repository.addSession(_session('s1'));

      await repository.deleteSession('s1');

      expect(await repository.watchRecentSessions().first, isEmpty);
      // null — «удалять нечего»; хранилище обязано это пережить молча.
      expect(photos.deleted, [null]);
    });

    test('удаление несуществующей сессии ничего не трогает', () async {
      await repository.addSession(_session('s1', photoPath: '/photos/a.jpg'));

      await repository.deleteSession('нет такой');

      expect(await repository.watchRecentSessions().first, hasLength(1));
      expect(photos.deleted, isEmpty);
    });

    test('соседние сессии и их фото не задеваются', () async {
      await repository.addSession(_session('s1', photoPath: '/photos/a.jpg'));
      await repository.addSession(_session('s2', photoPath: '/photos/b.jpg'));

      await repository.deleteSession('s1');

      final left = await repository.watchRecentSessions().first;
      expect(left.single.id, 's2');
      expect(left.single.photoPath, '/photos/b.jpg');
      expect(photos.deleted, ['/photos/a.jpg']);
    });
  });

  group('импорт с заменой', () {
    test('стирая историю, стирает и прикреплённые к ней файлы', () async {
      await repository.addSession(_session('s1', photoPath: '/photos/a.jpg'));
      await repository.addSession(_session('s2', photoPath: '/photos/b.jpg'));
      await repository.addSession(_session('s3'));

      final service = ExportService(db, photos: photos);
      // Пустой снимок: важно ровно то, что старое ушло целиком.
      await service.importSnapshot(
        {
          'format': ExportService.formatName,
          'version': ExportService.formatVersion,
          'data': <String, dynamic>{},
        },
        merge: false,
      );

      expect(await repository.watchRecentSessions().first, isEmpty);
      expect(photos.deleted, containsAll(['/photos/a.jpg', '/photos/b.jpg']));
      // Сессия без фото файла за собой не тянет.
      expect(photos.deleted, hasLength(2));
    });

    test('слияние ничего не удаляет', () async {
      await repository.addSession(_session('s1', photoPath: '/photos/a.jpg'));

      final service = ExportService(db, photos: photos);
      await service.importSnapshot(
        {
          'format': ExportService.formatName,
          'version': ExportService.formatVersion,
          'data': <String, dynamic>{},
        },
        merge: true,
      );

      expect(await repository.watchRecentSessions().first, hasLength(1));
      expect(photos.deleted, isEmpty);
    });
  });

  group('файловое хранилище', () {
    late Directory documents;

    setUp(() async {
      documents = await Directory.systemTemp.createTemp('texfi_photos_test');
    });

    tearDown(() async {
      if (await documents.exists()) await documents.delete(recursive: true);
    });

    FileSessionPhotoStore store() =>
        FileSessionPhotoStore(documentsDirectory: () async => documents);

    test('копирует файл к себе и не трогает оригинал', () async {
      final source = File(p.join(documents.path, 'source.jpg'))
        ..writeAsBytesSync([1, 2, 3]);

      final saved = await store().save(source.path);

      // Копия, а не ссылка: путь от системного выбора может указывать во
      // временный каталог, который вычистят когда угодно.
      expect(saved, isNot(source.path));
      expect(
        p.basename(p.dirname(saved)),
        FileSessionPhotoStore.folderName,
      );
      expect(File(saved).readAsBytesSync(), [1, 2, 3]);
      expect(source.existsSync(), isTrue);
    });

    test('расширение сохраняется, имя — нет', () async {
      final source = File(p.join(documents.path, 'снимок.png'))
        ..writeAsBytesSync([9]);

      final saved = await store().save(source.path);

      expect(p.extension(saved), '.png');
      expect(p.basenameWithoutExtension(saved), isNot('снимок'));
    });

    test('два снимка не затирают друг друга', () async {
      final first = File(p.join(documents.path, 'a.jpg'))
        ..writeAsBytesSync([1]);
      final second = File(p.join(documents.path, 'b.jpg'))
        ..writeAsBytesSync([2]);

      final saved = store();
      final one = await saved.save(first.path);
      final two = await saved.save(second.path);

      expect(one, isNot(two));
      expect(File(one).readAsBytesSync(), [1]);
      expect(File(two).readAsBytesSync(), [2]);
    });

    test('удаление стирает файл, а отсутствующий не считается ошибкой',
        () async {
      final source = File(p.join(documents.path, 'a.jpg'))
        ..writeAsBytesSync([1]);
      final subject = store();
      final saved = await subject.save(source.path);

      await subject.delete(saved);
      expect(File(saved).existsSync(), isFalse);

      // Повторное удаление, null и пустая строка проходят молча: запись могла
      // пережить чистку кеша или переезд на другое устройство.
      await subject.delete(saved);
      await subject.delete(null);
      await subject.delete('');
    });
  });
}
