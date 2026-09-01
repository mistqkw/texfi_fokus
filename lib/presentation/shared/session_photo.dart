import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/haptics/haptics.dart';
import '../../core/theme/app_colors_ext.dart';
import '../../core/theme/app_l10n_ext.dart';
import '../../core/theme/app_page_transitions.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles_ext.dart';
import 'pixel_sprite.dart';

/// Маленькое превью прикреплённого к сессии фото.
///
/// Файла может не быть: путь переживает и чистку кеша, и импорт бэкапа с
/// другого устройства, а сам снимок — нет. Отсутствие проверяется до
/// отрисовки, потому что `Image.file` на пропавшем файле роняет в консоль
/// исключение на каждый кадр, а показывает всё равно ничего.
class SessionPhotoThumbnail extends StatelessWidget {
  const SessionPhotoThumbnail({
    super.key,
    required this.path,
    this.size = 44,
    this.onTap,
  });

  final String path;
  final double size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final exists = File(path).existsSync();

    return GestureDetector(
      onTap: exists ? onTap : null,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: colors.surfaceVariant,
          border: Border.all(
            color: colors.divider,
            width: AppRadius.pixelBorder,
          ),
        ),
        clipBehavior: Clip.hardEdge,
        child: exists
            ? Image.file(File(path), fit: BoxFit.cover)
            : Center(
                child: PixelSprite(
                  rows: PixelSprites.camera,
                  size: size * 0.45,
                  color: colors.textTertiary,
                ),
              ),
      ),
    );
  }
}

/// Полноразмерный просмотр снимка.
///
/// Отдельный экран, а не диалог: фотография тетради или экрана — это текст,
/// который хотят прочитать, и ему нужно всё место, какое есть, плюс
/// возможность приблизить.
class SessionPhotoViewer extends StatelessWidget {
  const SessionPhotoViewer({super.key, required this.path});

  final String path;

  static Future<void> open(BuildContext context, String path) {
    Haptics.tap();
    return Navigator.of(context).push(
      // Тот же pixel-dissolve, что и на всех остальных переходах: экран
      // просмотра — не исключение из общего визуального языка.
      pixelDissolveRoute<void>(SessionPhotoViewer(path: path)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final exists = File(path).existsSync();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.photoViewerTitle)),
      body: Center(
        child: exists
            ? InteractiveViewer(
                maxScale: 5,
                child: Image.file(File(path), fit: BoxFit.contain),
              )
            : Padding(
                padding: AppSpacing.screen,
                child: Text(
                  l10n.photoMissing,
                  textAlign: TextAlign.center,
                  style: context.text.body,
                ),
              ),
      ),
    );
  }
}
