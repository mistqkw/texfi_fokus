import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/shop_item.dart';
import '../providers/data_providers.dart';

/// Баланс внутриигровой валюты.
///
/// Живёт в SharedPreferences, а не в Drift, — тем же способом, что и
/// [CustomPresetsNotifier] рядом: одно целое число не стоит отдельной таблицы
/// со своей миграцией, когда работающее хранилище настроек уже есть.
class CurrencyNotifier extends StateNotifier<int> {
  CurrencyNotifier(this._prefs) : super(_prefs.getInt(prefsKey) ?? 0);

  static const String prefsKey = 'currency_balance';

  final SharedPreferences _prefs;

  Future<void> add(int amount) async {
    if (amount <= 0) return;
    state += amount;
    await _prefs.setInt(prefsKey, state);
  }

  /// Списывает сумму, если она есть на балансе. Возвращает `false` без
  /// списания, если денег не хватает, — вызывающий сам решает, как об этом
  /// сказать.
  Future<bool> spend(int amount) async {
    if (amount <= 0 || state < amount) return false;
    state -= amount;
    await _prefs.setInt(prefsKey, state);
    return true;
  }
}

final currencyBalanceProvider =
    StateNotifierProvider<CurrencyNotifier, int>((ref) {
  return CurrencyNotifier(ref.watch(sharedPreferencesProvider));
});

/// Купленные предметы витрины — набор id.
class OwnedShopItemsNotifier extends StateNotifier<Set<String>> {
  OwnedShopItemsNotifier(this._prefs) : super(_read(_prefs));

  static const String prefsKey = 'shop_owned_items';

  final SharedPreferences _prefs;

  static Set<String> _read(SharedPreferences prefs) {
    return (prefs.getStringList(prefsKey) ?? const []).toSet();
  }

  Future<void> add(String id) async {
    if (state.contains(id)) return;
    state = {...state, id};
    await _prefs.setStringList(prefsKey, state.toList());
  }
}

final ownedShopItemsProvider =
    StateNotifierProvider<OwnedShopItemsNotifier, Set<String>>((ref) {
  return OwnedShopItemsNotifier(ref.watch(sharedPreferencesProvider));
});

/// Итог попытки покупки — экрану нужно различить эти два отказа, чтобы
/// сказать точную причину, а не общее «не вышло».
enum PurchaseOutcome { bought, alreadyOwned, insufficientFunds }

/// Покупка одного предмета: списывает цену и записывает владение одной
/// операцией, чтобы между «списали» и «выдали» не было окна, в которое можно
/// закрыть экран и остаться без того и другого.
final purchaseShopItemProvider =
    Provider<Future<PurchaseOutcome> Function(ShopItem item)>((ref) {
  return (item) async {
    if (ref.read(ownedShopItemsProvider).contains(item.id)) {
      return PurchaseOutcome.alreadyOwned;
    }
    final spent = await ref.read(currencyBalanceProvider.notifier).spend(
          item.price,
        );
    if (!spent) return PurchaseOutcome.insufficientFunds;
    await ref.read(ownedShopItemsProvider.notifier).add(item.id);
    return PurchaseOutcome.bought;
  };
});
