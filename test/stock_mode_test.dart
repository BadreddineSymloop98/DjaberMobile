import 'package:djaber_mobile/core/storage/prefs_storage.dart';
import 'package:djaber_mobile/data/models/stock_mode.dart';
import 'package:djaber_mobile/presentation/viewmodels/stock_mode_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The stock mode as an app-wide preference: what it defaults to, that it
/// survives a restart, and that a screen watching it actually rebuilds.
void main() {
  Future<PrefsStorage> prefsWith([Map<String, Object> values = const {}]) async {
    SharedPreferences.setMockInitialValues(values);
    return PrefsStorage.load();
  }

  group('StockMode', () {
    test('defaults to simple, the web default', () {
      // dashboard/layout.tsx:140 — useState<'simple' | 'advanced'>('simple').
      expect(StockMode.fromName(null), StockMode.simple);
      expect(StockMode.fromName('nonsense'), StockMode.simple);
      expect(StockMode.fromName('advanced'), StockMode.advanced);
    });

    test('the wire name matches the string the web stores', () {
      expect(StockMode.simple.wireName, 'simple');
      expect(StockMode.advanced.wireName, 'advanced');
    });
  });

  group('the app-wide model', () {
    test('starts from what is on the device', () async {
      final fresh = StockModeViewModel(prefs: await prefsWith());
      expect(fresh.mode, StockMode.simple);
      expect(fresh.isSimple, isTrue);
      expect(fresh.isAdvanced, isFalse);

      final stored = StockModeViewModel(
        prefs: await prefsWith({'stockMode': 'advanced'}),
      );
      expect(stored.mode, StockMode.advanced);
      expect(stored.isAdvanced, isTrue);
    });

    test('setMode persists, so the choice survives a restart', () async {
      final prefs = await prefsWith();
      final model = StockModeViewModel(prefs: prefs);

      await model.setMode(StockMode.advanced);

      expect(prefs.stockMode, StockMode.advanced);
      // A model built afresh — as it is on the next cold start — sees it.
      expect(StockModeViewModel(prefs: prefs).mode, StockMode.advanced);
    });

    test('notifies on a change, and stays quiet on a no-op', () async {
      final model = StockModeViewModel(prefs: await prefsWith());
      var notifications = 0;
      model.addListener(() => notifications++);

      await model.setMode(StockMode.advanced);
      expect(notifications, 1);

      // Setting the value it already holds must not rebuild every watcher.
      await model.setMode(StockMode.advanced);
      expect(notifications, 1);

      await model.setMode(StockMode.simple);
      expect(notifications, 2);
    });

    testWidgets('a watching screen rebuilds when the mode changes',
        (tester) async {
      // This is the point of exposing it app-wide rather than reading prefs
      // at each call site: changing the mode in settings has to re-render
      // whatever is already on screen.
      final model = StockModeViewModel(prefs: await prefsWith());

      await tester.pumpWidget(
        ChangeNotifierProvider<StockModeViewModel>.value(
          value: model,
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                final mode = context.watch<StockModeViewModel>();
                return Text(
                  mode.isAdvanced ? 'advanced' : 'simple',
                  textDirection: TextDirection.ltr,
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('simple'), findsOneWidget);

      await model.setMode(StockMode.advanced);
      await tester.pumpAndSettle();

      expect(find.text('advanced'), findsOneWidget);
      expect(find.text('simple'), findsNothing);
    });
  });
}
