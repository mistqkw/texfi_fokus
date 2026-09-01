import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/haptics/haptics.dart';
import '../../core/theme/app_colors_ext.dart';
import '../../core/theme/app_l10n_ext.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles_ext.dart';
import '../../core/update/app_release.dart';
import '../../core/update/update_service.dart';
import '../shared/pixel_button.dart';
import '../shared/pixel_card.dart';
import 'update_providers.dart';

/// Блок «Обновления» в настройках.
///
/// Целиком исчезает там, где обновиться нельзя (см. [updatesSupported]):
/// десктопные сборки ставятся не из `.apk`, и кнопка «скачать и установить»
/// была бы для них заведомо мёртвой.
class UpdateCard extends ConsumerWidget {
  const UpdateCard({super.key});

  Future<void> _install(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final controller = ref.read(updateControllerProvider.notifier);
    final messenger = ScaffoldMessenger.of(context);

    // Разрешение «установка неизвестных приложений» пугает ровно до тех пор,
    // пока не объяснить, почему его спрашивают. Показываем один раз, перед
    // первым запуском установщика.
    if (!ref.read(updateControllerProvider).installExplainerShown) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.updateInstallExplainerTitle),
          content: Text(l10n.updateInstallExplainerBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.commonCancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.updateInstallExplainerOk),
            ),
          ],
        ),
      );
      if (proceed != true) return;
      controller.markExplainerShown();
    }

    final ok = await controller.downloadAndInstall();
    if (!ok) {
      Haptics.warning();
      messenger.showSnackBar(SnackBar(content: Text(l10n.updateFailed)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!updatesSupported) return const SizedBox.shrink();

    final l10n = context.l10n;
    final colors = context.colors;
    final state = ref.watch(updateControllerProvider);
    final release = state.release;
    final busy = state.stage == UpdateStage.checking ||
        state.stage == UpdateStage.downloading;

    return PixelCard(
      accent: state.hasUpdate,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (release == null) ...[
            Text(
              state.stage == UpdateStage.checking
                  ? l10n.updateChecking
                  : l10n.updateUpToDate,
              style: context.text.body,
            ),
          ] else ...[
            Text(
              l10n.updateAvailable(release.version),
              style: context.text.sectionTitle,
            ),
            if (release.notes.trim().isNotEmpty) ...[
              AppSpacing.gapSm,
              Text(
                notesPreview(release.notes),
                style: context.text.caption,
              ),
            ],
            AppSpacing.gapMd,
            if (state.stage == UpdateStage.downloading) ...[
              // Прогресс именно линейкой: пакет весит десятки мегабайт, и
              // бесконечный спиннер на таком времени выглядит как зависание.
              LinearProgressIndicator(
                value: state.progress,
                minHeight: AppRadius.pixelBorder * 3,
                backgroundColor: colors.divider,
                color: colors.accent,
              ),
              AppSpacing.gapSm,
              Text(
                l10n.updateDownloading((state.progress * 100).round()),
                style: context.text.caption,
              ),
            ] else
              PixelButton(
                label: release.hasApk
                    ? l10n.updateDownloadButton
                    : l10n.updateNoApk,
                onPressed:
                    release.hasApk ? () => _install(context, ref) : null,
              ),
          ],
          AppSpacing.gapMd,
          PixelButton(
            label: l10n.updateCheckButton,
            primary: false,
            onPressed: busy
                ? null
                : () => ref.read(updateControllerProvider.notifier).checkNow(),
          ),
        ],
      ),
    );
  }
}
