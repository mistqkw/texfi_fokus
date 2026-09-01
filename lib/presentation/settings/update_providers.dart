import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_info.dart';
import '../../core/update/app_release.dart';
import '../../core/update/update_cache.dart';
import '../../core/update/update_service.dart';
import '../../data/providers/data_providers.dart';

/// Стадия, в которой находится обновление прямо сейчас.
enum UpdateStage {
  /// Ничего не происходит: либо ещё не проверяли, либо обновления нет.
  idle,
  checking,

  /// Найдена версия новее установленной.
  available,
  downloading,

  /// Пакет скачан, установщик запущен (или вот-вот будет).
  readyToInstall,
}

class UpdateState {
  const UpdateState({
    this.stage = UpdateStage.idle,
    this.release,
    this.progress = 0,
    this.installExplainerShown = false,
  });

  final UpdateStage stage;

  /// Релиз новее текущего. `null` во всех остальных случаях — в том числе
  /// когда установлена самая свежая версия.
  final AppRelease? release;

  /// Прогресс загрузки `0..1`.
  final double progress;

  /// Показывали ли уже объяснение про «установку из неизвестных источников».
  final bool installExplainerShown;

  bool get hasUpdate => release != null;

  UpdateState copyWith({
    UpdateStage? stage,
    AppRelease? release,
    bool clearRelease = false,
    double? progress,
    bool? installExplainerShown,
  }) {
    return UpdateState(
      stage: stage ?? this.stage,
      release: clearRelease ? null : (release ?? this.release),
      progress: progress ?? this.progress,
      installExplainerShown:
          installExplainerShown ?? this.installExplainerShown,
    );
  }
}

/// Проверка обновлений: когда ходить в сеть, что показывать и что качать.
///
/// Ошибки наружу не выходят ни в каком виде — ни диалогом, ни снекбаром.
/// Единственное наблюдаемое следствие неудачной проверки: карточка
/// обновления не появляется.
class UpdateController extends StateNotifier<UpdateState> {
  UpdateController({
    required this.service,
    required this.cache,
    this.currentVersion = AppInfo.version,
    this.now = DateTime.now,
  }) : super(const UpdateState()) {
    _restoreFromCache();
  }

  final UpdateService service;
  final UpdateCheckCache cache;

  /// Версия, с которой сравнивается тег релиза. Параметр, а не константа,
  /// ровно ради тестов: подставить «старую» версию проще, чем поднимать
  /// приложение нужной сборки.
  final String currentVersion;

  /// Источник времени — тоже ради тестов: проверить, что кэш протухает через
  /// шесть часов, иначе можно было бы только подождав шесть часов.
  final DateTime Function() now;

  bool _busy = false;

  /// Кэш — не только защита от лишних запросов, но и источник карточки при
  /// старте: обновление, найденное вчера, должно быть видно сразу, не дожидаясь
  /// нового похода в сеть.
  void _restoreFromCache() {
    final last = cache.read();
    final release = last?.release;
    if (release == null) return;
    if (!isNewerVersion(release.version, currentVersion)) return;
    state = state.copyWith(stage: UpdateStage.available, release: release);
  }

  /// Фоновая проверка при старте. Молчит, если кэш ещё свежий.
  Future<void> checkOnLaunch() => _check(force: false);

  /// Кнопка в настройках: всегда идёт в сеть.
  Future<void> checkNow() => _check(force: true);

  Future<void> _check({required bool force}) async {
    if (!updatesSupported || _busy) return;
    final startedAt = now();
    if (!shouldCheckNow(last: cache.read(), now: startedAt, force: force)) {
      return;
    }

    _busy = true;
    if (force) state = state.copyWith(stage: UpdateStage.checking);
    try {
      final release = await service.fetchLatest();
      final checkedAt = now();
      if (release == null) {
        // Отказ тоже записывается: иначе следующий запуск снова полезет в
        // API и лимит не восстановится никогда.
        await cache.write(
          UpdateCheckState(checkedAt: checkedAt, succeeded: false),
        );
        if (mounted && state.stage == UpdateStage.checking) {
          state = state.copyWith(stage: UpdateStage.idle);
        }
        return;
      }

      await cache.write(UpdateCheckState(
        checkedAt: checkedAt,
        succeeded: true,
        release: release,
      ));
      if (!mounted) return;

      final newer = isNewerVersion(release.version, currentVersion);
      state = newer
          ? state.copyWith(stage: UpdateStage.available, release: release)
          : state.copyWith(stage: UpdateStage.idle, clearRelease: true);
    } finally {
      _busy = false;
    }
  }

  /// Объяснение про разрешение показывается один раз за сессию — перед
  /// первым запуском установщика.
  void markExplainerShown() {
    if (!mounted) return;
    state = state.copyWith(installExplainerShown: true);
  }

  /// Качает пакет и отдаёт его системному установщику.
  ///
  /// Возвращает `false`, если что-то не получилось, — вызывающий код решает,
  /// сказать ли об этом человеку (в отличие от проверки версии, здесь он сам
  /// нажал кнопку и вправе узнать, что она не сработала).
  Future<bool> downloadAndInstall() async {
    final release = state.release;
    if (!updatesSupported || release == null || !release.hasApk) return false;
    if (state.stage == UpdateStage.downloading) return false;

    state = state.copyWith(stage: UpdateStage.downloading, progress: 0);
    File? file;
    try {
      file = await service.downloadApk(
        release,
        onProgress: (value) {
          if (mounted) state = state.copyWith(progress: value);
        },
      );
    } catch (error) {
      debugPrint('downloadAndInstall failed: $error');
    }

    if (file == null) {
      if (mounted) {
        state = state.copyWith(stage: UpdateStage.available, progress: 0);
      }
      return false;
    }

    if (mounted) state = state.copyWith(stage: UpdateStage.readyToInstall);
    final opened = await service.installApk(file);
    if (!opened && mounted) {
      state = state.copyWith(stage: UpdateStage.available, progress: 0);
    }
    return opened;
  }
}

final updateServiceProvider = Provider<UpdateService>((ref) {
  final service = UpdateService();
  ref.onDispose(service.dispose);
  return service;
});

final updateControllerProvider =
    StateNotifierProvider<UpdateController, UpdateState>((ref) {
  return UpdateController(
    service: ref.watch(updateServiceProvider),
    cache: UpdateCheckCache(ref.watch(sharedPreferencesProvider)),
  );
});
