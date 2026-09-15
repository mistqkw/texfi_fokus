import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/haptics/haptics.dart';
import '../../core/theme/app_colors_ext.dart';
import '../../core/theme/app_l10n_ext.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles_ext.dart';
import '../../data/settings/currency_store.dart';
import '../../domain/entities/shop_item.dart';
import '../../l10n/app_localizations.dart';
import '../shared/pixel_background.dart';
import '../shared/pixel_button.dart';
import '../shared/pixel_card.dart';
import '../shared/pixel_sprite.dart';

/// Название, описание и значок товара — представление поверх [ShopItem],
/// у которого есть только id и цена (см. комментарий там о том, почему).
({String name, String description, List<String> icon}) _presentation(
  AppLocalizations l10n,
  String id,
) {
  return switch (id) {
    'frame_ember' => (
        name: l10n.shopItemEmberName,
        description: l10n.shopItemEmberDescription,
        icon: PixelSprites.moon,
      ),
    'frame_tide' => (
        name: l10n.shopItemTideName,
        description: l10n.shopItemTideDescription,
        icon: PixelSprites.hourglass,
      ),
    'frame_midnight' => (
        name: l10n.shopItemMidnightName,
        description: l10n.shopItemMidnightDescription,
        icon: PixelSprites.bell,
      ),
    _ => (
        name: l10n.shopItemNoonName,
        description: l10n.shopItemNoonDescription,
        icon: PixelSprites.camera,
      ),
  };
}

/// Витрина косметики за внутриигровую валюту, заработанную сессиями.
///
/// Предметы — заглушки: у них есть честная механика покупки (баланс, владение,
/// невозможность купить дважды или без денег), но нет собственного визуального
/// эффекта на экранах приложения. Это сделано ради проверки самого потока, а
/// не ради того, чтобы выдать недоделанное за готовое, — см. комментарий у
/// [ShopCatalog].
class ShopScreen extends ConsumerWidget {
  const ShopScreen({super.key});

  Future<void> _buy(
    BuildContext context,
    WidgetRef ref,
    ShopItem item,
  ) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final outcome = await ref.read(purchaseShopItemProvider)(item);
    switch (outcome) {
      case PurchaseOutcome.bought:
        Haptics.success();
        messenger.showSnackBar(SnackBar(content: Text(l10n.shopBought)));
      case PurchaseOutcome.insufficientFunds:
        Haptics.warning();
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.shopInsufficientFunds)),
        );
      case PurchaseOutcome.alreadyOwned:
        // Кнопка на купленный предмет и так неактивна — сюда попасть нельзя,
        // но тихий выход честнее любого сообщения о состоянии, которое
        // интерфейс не должен был допустить.
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.colors;
    final balance = ref.watch(currencyBalanceProvider);
    final owned = ref.watch(ownedShopItemsProvider);

    return PixelBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(l10n.shopTitle),
        ),
        body: ListView(
          padding: AppSpacing.screen,
          children: [
            PixelCard(
              accent: true,
              child: Row(
                children: [
                  PixelSprite(
                    rows: PixelSprites.hourglass,
                    size: 20,
                    color: colors.accent,
                  ),
                  AppSpacing.wGapMd,
                  Expanded(
                    child: Text(l10n.shopBalance, style: context.text.caption),
                  ),
                  Text(
                    '$balance',
                    style: context.text.counterMedium.copyWith(
                      color: colors.accent,
                    ),
                  ),
                ],
              ),
            ),
            AppSpacing.gapLg,
            for (final item in ShopCatalog.items) ...[
              _ShopItemCard(
                item: item,
                owned: owned.contains(item.id),
                canAfford: balance >= item.price,
                onBuy: () => _buy(context, ref, item),
              ),
              AppSpacing.gapMd,
            ],
          ],
        ),
      ),
    );
  }
}

class _ShopItemCard extends StatelessWidget {
  const _ShopItemCard({
    required this.item,
    required this.owned,
    required this.canAfford,
    required this.onBuy,
  });

  final ShopItem item;
  final bool owned;
  final bool canAfford;
  final VoidCallback onBuy;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final info = _presentation(l10n, item.id);

    return PixelCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PixelSprite(
            rows: info.icon,
            size: 32,
            color: owned ? colors.textTertiary : colors.accent,
          ),
          AppSpacing.wGapMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(info.name, style: context.text.sectionTitle),
                AppSpacing.gapXs,
                Text(
                  info.description,
                  style: context.text.caption.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                AppSpacing.gapSm,
                Text(
                  l10n.shopPrice(item.price),
                  style: context.text.chartLabel.copyWith(
                    color: canAfford || owned
                        ? colors.textSecondary
                        : colors.warning,
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.wGapMd,
          PixelButton(
            label: owned ? l10n.shopOwned : l10n.shopBuy,
            expand: false,
            primary: !owned,
            onPressed: owned || !canAfford ? null : onBuy,
          ),
        ],
      ),
    );
  }
}
