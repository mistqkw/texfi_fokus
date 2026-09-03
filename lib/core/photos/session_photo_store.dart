import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

/// Хранилище фотографий, прикреплённых к сессиям.
///
/// Отдельная сущность, а не пара вызовов `File` по месту, ровно по одной
/// причине: файл, на который больше никто не ссылается, никто и не удалит.
/// Раз хранилище одно, то и удаление живёт в одном месте — там же, где
/// создание, и его можно проверить тестом на подделке, не трогая диск.
///
/// Ничего не отправляет наружу: снимок кладётся в документы приложения и
/// остаётся на устройстве. Приложение офлайновое, и фото — не исключение.
abstract class SessionPhotoStore {
  /// Копирует выбранный файл к себе и возвращает путь копии.
  ///
  /// Именно копирует: путь, который отдаёт системный выбор файла, может
  /// указывать во временный каталог, который система вычистит когда захочет,
  /// — и история осталась бы со ссылкой в никуда.
  Future<String> save(String sourcePath);

  /// Удаляет файл, если он есть. Отсутствующий файл — не ошибка: запись
  /// могла пережить чистку кеша или переезд на другое устройство.
  Future<void> delete(String? path);

  /// Удаляет из хранилища всё, на что не ссылается ни одна сессия, и
  /// возвращает число убранных файлов.
  ///
  /// Нужна потому, что копия снимка появляется на диске раньше, чем сессия в
  /// базе: файл кладётся сюда в момент выбора, а строка пишется только когда
  /// сессия закончится. Между этими двумя моментами человек может передумать
  /// — закрыть check-in, выйти из приложения, — и копия останется без
  /// единственного, кто о ней знал.
  ///
  /// Удаление именно по списку ссылок, а не по возрасту файла или по тому,
  /// что черновик сбросили: [keep] приходит из самой базы, и всё, что в неё
  /// попало, переживает уборку по построению. Ошибиться в другую сторону —
  /// стереть снимок, который человек сделал сам и который виден в истории, —
  /// здесь несопоставимо хуже, чем не убрать лишний файл.
  Future<int> deleteUnreferenced(Set<String> keep);
}

/// Реальное хранилище: `<документы приложения>/session_photos/<uuid><ext>`.
class FileSessionPhotoStore implements SessionPhotoStore {
  FileSessionPhotoStore({Future<Directory> Function()? documentsDirectory})
      : _documentsDirectory =
            documentsDirectory ?? getApplicationDocumentsDirectory;

  final Future<Directory> Function() _documentsDirectory;

  static const String folderName = 'session_photos';
  static const Uuid _uuid = Uuid();

  Future<Directory> _folder() async {
    final documents = await _documentsDirectory();
    final folder = Directory(p.join(documents.path, folderName));
    if (!await folder.exists()) {
      await folder.create(recursive: true);
    }
    return folder;
  }

  @override
  Future<String> save(String sourcePath) async {
    final folder = await _folder();
    // Расширение сохраняем: по нему просмотрщик и галерея понимают формат, а
    // переименовывать всё в .jpg значило бы врать про содержимое.
    final extension = p.extension(sourcePath).toLowerCase();
    final name = '${_uuid.v4()}${extension.isEmpty ? '.jpg' : extension}';
    final target = p.join(folder.path, name);
    await File(sourcePath).copy(target);
    return target;
  }

  @override
  Future<void> delete(String? path) async {
    if (path == null || path.isEmpty) return;
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  @override
  Future<int> deleteUnreferenced(Set<String> keep) async {
    final documents = await _documentsDirectory();
    final folder = Directory(p.join(documents.path, folderName));
    // Папки может не быть вовсе — фото ни разу не прикладывали. Создавать её
    // ради уборки незачем: убирать в ней нечего.
    if (!await folder.exists()) return 0;

    var removed = 0;
    await for (final entity in folder.list(followLinks: false)) {
      if (entity is! File) continue;
      if (keep.contains(entity.path)) continue;
      try {
        await entity.delete();
        removed += 1;
      } on FileSystemException {
        // Файл могли забрать из-под нас — например, он уже удалён вместе с
        // сессией. Уборка не тот повод, чтобы ронять запуск.
        continue;
      }
    }
    return removed;
  }
}
