import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

/// Откуда берётся снимок.
enum PhotoSource { camera, gallery }

/// Съёмка и выбор фотографии.
///
/// Отделено от [SessionPhotoStore] нарочно: выбор файла — это системный
/// плагин, которого на некоторых платформах просто нет, а копирование и
/// удаление файлов работает везде и должно проверяться тестами без него.
///
/// Ничего не сохраняет: возвращает путь к тому, что выбрал пользователь, и на
/// этом заканчивается. Раскладывать файлы по своим каталогам — работа
/// хранилища.
class SessionPhotoPicker {
  SessionPhotoPicker({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  /// Поддерживает ли платформа съёмку и выбор вовсе.
  ///
  /// На Linux у `image_picker` реализации нет, и вызов упал бы
  /// `MissingPluginException`. Кнопку, которая гарантированно не работает,
  /// показывать не нужно — это честнее, чем показать и извиниться.
  static bool get isSupported {
    if (kIsWeb) return true;
    return Platform.isAndroid ||
        Platform.isIOS ||
        Platform.isMacOS ||
        Platform.isWindows;
  }

  /// Путь к выбранному файлу или null, если пользователь передумал.
  ///
  /// Снимок ужимается на входе: фотография с современной камеры — это
  /// несколько десятков мегабайт, а на карточке задачи от них не остаётся
  /// ничего, кроме занятого места на устройстве.
  Future<String?> pick(PhotoSource source) async {
    final file = await _picker.pickImage(
      source: source == PhotoSource.camera
          ? ImageSource.camera
          : ImageSource.gallery,
      maxWidth: 1600,
      maxHeight: 1600,
      imageQuality: 85,
    );
    return file?.path;
  }
}
