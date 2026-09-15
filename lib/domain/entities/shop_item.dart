/// Один товар витрины: устойчивый id и цена.
///
/// Имя, описание и иконка — представление, и здесь их нет: у домена нет
/// зависимости на Flutter/l10n, а у товара найдётся только то, что решает
/// саму механику покупки — сколько он стоит и как его узнать среди купленных.
class ShopItem {
  const ShopItem({required this.id, required this.price});

  final String id;
  final int price;
}

/// Витрина косметики за внутриигровую валюту.
///
/// Пока это заглушки для проверки самого потока покупки — баланс уменьшается,
/// владение сохраняется, повторная покупка недоступна, — а не готовые
/// косметические предметы с эффектом на экране: применённого визуала за ними
/// ещё не стоит. Честнее показать рабочую покупку без эффекта, чем эффект
/// без честной покупки.
abstract final class ShopCatalog {
  static const List<ShopItem> items = [
    ShopItem(id: 'frame_ember', price: 30),
    ShopItem(id: 'frame_tide', price: 30),
    ShopItem(id: 'frame_midnight', price: 60),
    ShopItem(id: 'frame_noon', price: 90),
  ];

  static ShopItem? byId(String id) {
    for (final item in items) {
      if (item.id == id) return item;
    }
    return null;
  }
}
