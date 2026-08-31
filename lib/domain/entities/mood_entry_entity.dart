import 'mood.dart';

/// Отметка настроения. Пишется на каждом check-in — в том числе если
/// пользователь так и не запустил сессию: сам факт «открыл и передумал»
/// тоже часть картины.
class MoodEntryEntity {
  const MoodEntryEntity({
    required this.id,
    required this.mood,
    required this.recordedAt,
    this.sessionId,
  });

  final String id;
  final Mood mood;
  final DateTime recordedAt;

  /// Сессия, которая началась с этой отметки. null — сессию не запустили.
  final String? sessionId;
}
