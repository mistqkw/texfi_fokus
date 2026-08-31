/// Четыре состояния переключателя настроения. Порядок значим: индекс
/// используется как часть ключа контекста рекомендаций и хранится в БД,
/// поэтому переставлять значения нельзя.
enum Mood {
  bad,
  neutral,
  good,
  fullFokus;

  static Mood fromIndex(int index) =>
      index >= 0 && index < Mood.values.length ? Mood.values[index] : Mood.neutral;
}
