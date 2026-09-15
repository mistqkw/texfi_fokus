import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/haptics/haptics.dart';
import '../../core/storage/backup_storage_access.dart';
import '../../core/theme/app_colors_ext.dart';
import '../../core/theme/app_l10n_ext.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles_ext.dart';
import '../../data/local/export_service.dart';
import '../../data/providers/data_providers.dart';
import '../shared/pixel_background.dart';
import '../shared/pixel_button.dart';
import '../shared/pixel_card.dart';

/// Импорт и резервные копии — отдельным экраном, а не диалогом поверх
/// настроек: теперь на нём завязан ещё и системный доступ к общему
/// хранилищу, и уместить его объяснение в одну плашку под тумблером было бы
/// тесно.
///
/// При открытии, если доступ к хранилищу уже выдан, экран сам открывает
/// папку `TexFi Backup` в системном «Файлы» — чтобы человек сразу увидел, что
/// там уже лежит, не разыскивая её руками. Если доступа ещё нет, вместо этого
/// показывается объяснение и кнопка на системный экран согласия: открывать
/// системный диалог без предупреждения, зачем он вообще, — не тот стиль,
/// которым это приложение просит о чём-либо.
class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen>
    with WidgetsBindingObserver {
  final BackupStorageAccess _storage = const BackupStorageAccess();

  /// `null` — ещё не проверяли.
  bool? _hasAccess;

  /// Папку открываем только один раз за посещение экрана: возврат из
  /// системных настроек и последующая перепроверка доступа не должны каждый
  /// раз перекидывать поверх приложения ещё и «Файлы».
  bool _openedFolder = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshAccess());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Согласие на «Доступ ко всем файлам» выдаётся на отдельном системном
    // экране — узнать о нём можно только вернувшись и спросив заново.
    if (state == AppLifecycleState.resumed) _refreshAccess();
  }

  Future<void> _refreshAccess() async {
    final granted = await _storage.hasAccess();
    if (!mounted) return;
    setState(() => _hasAccess = granted);
    if (granted && !_openedFolder) {
      _openedFolder = true;
      await _storage.openBackupFolder();
    }
  }

  Future<void> _requestAccess() async {
    Haptics.tap();
    await _storage.requestManageStorage();
    // Результат намеренно не читаем здесь: он вернётся из системных
    // настроек, а не из этого вызова, и его подхватит `didChangeAppLifecycleState`.
  }

  Future<void> _export(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    try {
      final path = await ref.read(exportServiceProvider).exportToFile();
      Haptics.success();
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.settingsExportDone(path))),
      );
    } catch (error) {
      Haptics.warning();
      messenger.showSnackBar(
        SnackBar(content: Text('${l10n.settingsExportFailed}: $error')),
      );
    }
  }

  /// Импорт через системный выбор файла — тот же диалог, что открывает любое
  /// другое приложение, а не собственное поле для ручного ввода пути.
  Future<void> _import(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);

    final FilePickerResult? picked;
    try {
      picked = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
    } catch (error) {
      Haptics.warning();
      messenger.showSnackBar(
        SnackBar(content: Text('${l10n.settingsImportFailed}: $error')),
      );
      return;
    }

    final path = picked?.files.singleOrNull?.path;
    if (path == null || !context.mounted) return;

    final merge = await showDialog<bool>(
      context: context,
      builder: (context) => const ImportModeDialog(),
    );
    if (merge == null || !context.mounted) return;

    try {
      final result = await ref
          .read(exportServiceProvider)
          .importFromFile(File(path), merge: merge);
      Haptics.success();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            l10n.settingsImportDone(
              result.habits,
              result.tasks,
              result.sessions,
            ),
          ),
        ),
      );
    } catch (error) {
      Haptics.warning();
      messenger.showSnackBar(
        SnackBar(content: Text('${l10n.settingsImportFailed}: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final hasAccess = _hasAccess;
    final needsRationale =
        _storage.isSupported && hasAccess != null && !hasAccess;

    return PixelBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(l10n.backupTitle),
        ),
        body: ListView(
          padding: AppSpacing.screen,
          children: [
            if (needsRationale) ...[
              PixelCard(
                borderColor: colors.warning,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.backupAccessRationale,
                      style: context.text.body,
                    ),
                    AppSpacing.gapSm,
                    Text(
                      l10n.backupFolderPathHint(
                        ExportService.androidBackupPathForDisplay,
                      ),
                      style: context.text.caption.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                    AppSpacing.gapMd,
                    PixelButton(
                      label: l10n.backupGrantAccess,
                      onPressed: _requestAccess,
                    ),
                  ],
                ),
              ),
              AppSpacing.gapLg,
            ],
            PixelCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.settingsExport, style: context.text.sectionTitle),
                  AppSpacing.gapSm,
                  Text(
                    l10n.backupFolderPathHint(
                      ExportService.androidBackupPathForDisplay,
                    ),
                    style: context.text.caption,
                  ),
                  AppSpacing.gapMd,
                  PixelButton(
                    label: l10n.settingsExport,
                    onPressed: () => _export(context, ref),
                  ),
                ],
              ),
            ),
            AppSpacing.gapLg,
            PixelCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.settingsImport, style: context.text.sectionTitle),
                  AppSpacing.gapSm,
                  Text(l10n.settingsImportSubtitle, style: context.text.caption),
                  AppSpacing.gapMd,
                  PixelButton(
                    label: l10n.settingsImport,
                    primary: false,
                    onPressed: () => _import(context, ref),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension _SingleOrNull<T> on List<T> {
  T? get singleOrNull => length == 1 ? first : null;
}

/// Слияние или замена. Замена подписана прямо: «сотрёт всё, что есть» — на
/// этом экране эвфемизм стоил бы кому-то всей истории.
///
/// Публичный класс: раньше жил приватным в `settings_screen.dart`, теперь им
/// пользуется ещё и этот экран.
class ImportModeDialog extends StatelessWidget {
  const ImportModeDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.all(AppSpacing.page),
      child: PixelCard(
        borderColor: colors.warning,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.settingsImportWarnTitle,
              style: context.text.sectionTitle.copyWith(color: colors.warning),
            ),
            AppSpacing.gapMd,
            Text(l10n.settingsImportWarnBody, style: context.text.body),
            AppSpacing.gapXl,
            PixelButton(
              label: l10n.settingsImportMerge,
              onPressed: () => Navigator.of(context).pop(true),
            ),
            AppSpacing.gapMd,
            PixelButton(
              label: l10n.settingsImportReplace,
              danger: true,
              onPressed: () => Navigator.of(context).pop(false),
            ),
            AppSpacing.gapMd,
            PixelButton(
              label: l10n.commonCancel,
              primary: false,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
