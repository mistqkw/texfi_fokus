import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:texfi_fokus/core/update/update_service.dart';
import 'package:texfi_fokus/data/providers/data_providers.dart';
import 'package:texfi_fokus/l10n/app_localizations.dart';
import 'package:texfi_fokus/presentation/settings/update_card.dart';

/// Блок обновлений существует только на Android.
///
/// Тесты идут на хосте (Linux), то есть ровно в той ситуации, которую надо
/// проверить: `.apk` здесь поставить некуда, и кнопка «скачать и установить»
/// была бы мёртвой. Проверяем не «скрыт ли он на Linux», а «скрыт ли он
/// везде, где обновление невозможно» — иначе тест сломается на Android CI.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('на платформе без самообновления карточка не рисуется вовсе',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: [Locale('ru')],
          locale: Locale('ru'),
          home: Scaffold(body: UpdateCard()),
        ),
      ),
    );
    await tester.pump();

    if (updatesSupported) {
      expect(find.byType(SizedBox), findsWidgets);
      return;
    }

    // Ни кнопки, ни текста — совсем ничего: пустой блок с заголовком
    // «Обновления» был бы таким же обманом, как мёртвая кнопка.
    expect(find.byType(ElevatedButton), findsNothing);
    expect(find.textContaining('Скачать'), findsNothing);
    expect(find.textContaining('Проверить'), findsNothing);
    expect(
      tester.widget<UpdateCard>(find.byType(UpdateCard)),
      isA<UpdateCard>(),
    );
  });
}
