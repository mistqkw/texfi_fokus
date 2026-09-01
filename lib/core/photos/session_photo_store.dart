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
}
