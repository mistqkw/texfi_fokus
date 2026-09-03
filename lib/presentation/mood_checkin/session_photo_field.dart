import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/haptics/haptics.dart';
import '../../core/photos/session_photo_picker.dart';
import '../../core/theme/app_colors_ext.dart';
import '../../core/theme/app_l10n_ext.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles_ext.dart';
import '../../data/providers/data_providers.dart';
import '../shared/pixel_button.dart';
import '../shared/pixel_sprite.dart';
import '../shared/session_photo.dart';
import 'mood_checkin_providers.dart';

/// Необязательное фото к сессии: тетрадь, экран, стол — то, над чем человек
/// действительно работал.
///
/// Полностью необязательное и поэтому нарочно тихое: одна кнопка без рамки,
/// без звёздочки «обязательно» и без пустой рамки-заглушки под будущий
/// снимок. Не нажали — экран выглядит ровно так же, как выглядел до того, как
/// эта функция появилась.
///
/// На платформах, где системного выбора файла нет вовсе (десктопный Linux),
/// блок не показывается: кнопка, которая гарантированно ответит ошибкой,
/// хуже, чем её отсутствие.
class SessionPhotoField extends ConsumerWidget {
  const SessionPhotoField({super.key});

  Future<void> _attach(
    BuildContext context,
    WidgetRef ref,
    PhotoSource source,
  ) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);

    try {
      final picked = await ref.read(sessionPhotoPickerProvider).pick(source);
      if (picked == null) return;

      // Копия делается сразу: путь от системного выбора может указывать во
      // временный каталог, который вычистят когда угодно, — и в истории
      // осталась бы ссылка в никуда.
      final stored = await ref.read(sessionPhotoStoreProvider).save(picked);

      // Замена — это тоже удаление, просто вместе с добавлением. Прежняя
      // копия уже лежит в документах приложения, и на неё после этой строки
      // не сошлётся никто: черновик был единственным, кто о ней знал.
      // Удаляется она после успешного копирования новой — если бы выбор
      // сорвался посередине, снимок пропал бы, а взамен ничего не появилось.
      final replaced = ref.read(sessionDraftProvider).photoPath;
      ref.read(sessionDraftProvider.notifier).setPhoto(stored);
      if (replaced != null && replaced != stored) {
        await ref.read(sessionPhotoStoreProvider).delete(replaced);
      }
      Haptics.success();
    } catch (error, stack) {
      debugPrint('attaching a session photo failed: $error\n$stack');
      messenger.showSnackBar(SnackBar(content: Text(l10n.photoFailed)));
    }
  }

  Future<void> _pickSource(BuildContext context, WidgetRef ref) async {
    Haptics.tap();
    final l10n = context.l10n;

    final source = await showModalBottomSheet<PhotoSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppSpacing.gapLg,
            Text(l10n.photoSourceTitle, style: context.text.sectionTitle),
            AppSpacing.gapLg,
            Padding(
              padding: AppSpacing.screen,
              child: Column(
                children: [
                  PixelButton(
                    label: l10n.photoFromCamera,
                    sprite: PixelSprites.camera,
                    onPressed: () =>
                        Navigator.of(context).pop(PhotoSource.camera),
                  ),
                  AppSpacing.gapMd,
                  PixelButton(
                    label: l10n.photoFromGallery,
                    primary: false,
                    onPressed: () =>
                        Navigator.of(context).pop(PhotoSource.gallery),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    if (source == null || !context.mounted) return;
    await _attach(context, ref, source);
  }

  /// Убирает снимок и стирает файл: черновик — единственное, что о нём
  /// знало, и без удаления файл остался бы на устройстве навсегда.
  Future<void> _remove(WidgetRef ref, String path) async {
    Haptics.tap();
    ref.read(sessionDraftProvider.notifier).clearPhoto();
    await ref.read(sessionPhotoStoreProvider).delete(path);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!SessionPhotoPicker.isSupported) return const SizedBox.shrink();

    final l10n = context.l10n;
    final colors = context.colors;
    final path = ref.watch(sessionDraftProvider).photoPath;

    if (path == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PixelButton(
            label: l10n.photoAdd,
            primary: false,
            sprite: PixelSprites.camera,
            onPressed: () => _pickSource(context, ref),
          ),
          AppSpacing.gapSm,
          Text(l10n.photoHint, style: context.text.caption),
        ],
      );
    }

    return Row(
      children: [
        SessionPhotoThumbnail(
          path: path,
          size: 56,
          onTap: () => SessionPhotoViewer.open(context, path),
        ),
        AppSpacing.wGapMd,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.photoSectionTitle, style: context.text.label),
              AppSpacing.gapXs,
              Row(
                children: [
                  GestureDetector(
                    onTap: () => _pickSource(context, ref),
                    child: Text(
                      l10n.photoReplace,
                      style: context.text.chartLabel
                          .copyWith(color: colors.accent),
                    ),
                  ),
                  AppSpacing.wGapLg,
                  GestureDetector(
                    onTap: () => _remove(ref, path),
                    child: Text(
                      l10n.photoRemove,
                      style: context.text.chartLabel
                          .copyWith(color: colors.danger),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
