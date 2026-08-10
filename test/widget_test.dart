import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:trosa/db/sqflite_provider.dart';
import 'package:trosa/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  // The isolate-based factory deadlocks inside the widget test's fake-async
  // zone (pending sqflite lock-warning timers). The no-isolate factory runs
  // synchronously through FFI and works with setUp/tearDown.
  databaseFactory = databaseFactoryFfiNoIsolate;

  Future<void> clearDatabase() async {
    final db = await DatabaseProvider.db.database;
    await db.delete(DatabaseProvider.tableTrosa);
    await db.delete('settings');
  }

  setUp(() async {
    await clearDatabase();
    // Skip the first-run onboarding so existing dashboard tests land on the
    // dashboard (the onboarding flow has its own dedicated test).
    await DatabaseProvider.db.setSetting('onboardingDone', 'true');
  });

  Future<void> addDebt(WidgetTester tester, String amount, String owner) async {
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), amount);
    await tester.enterText(find.byType(TextFormField).at(1), owner);
    await tester.tap(find.byIcon(Icons.check));
    await tester.pumpAndSettle();
  }

  /// Swipes a card and lets the async reload (real DB futures) finish.
  /// `pumpAndSettle` alone returns before those futures resolve, so give the
  /// event loop real time to run them.
  Future<void> swipeAndSettle(WidgetTester tester, Finder target,
      Offset offset) async {
    await tester.drag(target, offset);
    await tester.pumpAndSettle();
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 200)));
    await tester.pumpAndSettle();
  }

  testWidgets('Trosa app renders the dashboard', (tester) async {
    await tester.pumpWidget(const TrosaApp());
    await tester.pumpAndSettle();

    expect(find.text('Trosa'), findsOneWidget);
    expect(find.text('Vola ho raisina'), findsOneWidget);
    expect(find.text('Vola mila haloa'), findsOneWidget);
    expect(find.text("Lisitr'ireo Trosa"), findsOneWidget);
  });

  testWidgets('adding a debt shows it in the list', (tester) async {
    await tester.pumpWidget(const TrosaApp());
    await tester.pumpAndSettle();

    await addDebt(tester, '5000', 'Jean');

    expect(find.textContaining('Jean'), findsOneWidget);
  });

  testWidgets('search field filters the list by owner', (tester) async {
    await tester.pumpWidget(const TrosaApp());
    await tester.pumpAndSettle();

    await addDebt(tester, '1000', 'Jean');
    await addDebt(tester, '2000', 'Nivo');

    // The search field itself matches typed text, so scope finders to the
    // list area (Cards) to count list items.
    Finder inList(String text) => find.descendant(
        of: find.byType(ListView), matching: find.textContaining(text));
    expect(inList('Jean'), findsOneWidget);
    expect(inList('Nivo'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'Nivo');
    await tester.pumpAndSettle();

    expect(inList('Nivo'), findsOneWidget);
    expect(inList('Jean'), findsNothing);
  });

  testWidgets('marking a debt as paid via swipe shows the paid badge',
      (tester) async {
    await tester.pumpWidget(const TrosaApp());
    await tester.pumpAndSettle();

    await addDebt(tester, '5000', 'Jean');

    // Swipe left-to-right to toggle "paid" (past the 40% dismiss threshold).
    await swipeAndSettle(
        tester, find.textContaining('Jean'), const Offset(600, 0));

    expect(find.text('Voaloa'), findsOneWidget);
  });

  testWidgets('unpaid filter hides paid debts', (tester) async {
    await tester.pumpWidget(const TrosaApp());
    await tester.pumpAndSettle();

    await addDebt(tester, '5000', 'Jean');

    // Mark paid.
    await swipeAndSettle(
        tester, find.textContaining('Jean'), const Offset(600, 0));
    expect(find.text('Voaloa'), findsOneWidget);

    // Switch to the unpaid filter.
    await tester.tap(find.text('Mbola tsy voaloa'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Jean'), findsNothing);
  });

  testWidgets('deleting a debt can be undone', (tester) async {
    await tester.pumpWidget(const TrosaApp());
    await tester.pumpAndSettle();

    await addDebt(tester, '5000', 'Jean');

    // Swipe right-to-left to delete, then confirm in the dialog.
    await swipeAndSettle(
        tester, find.textContaining('Jean'), const Offset(-600, 0));
    await tester.tap(find.text('ENY'));
    await tester.pumpAndSettle();
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 200)));
    await tester.pumpAndSettle();

    expect(find.textContaining('Jean'), findsNothing);

    // Undo restores the record.
    await tester.tap(find.text('AVERY'));
    await tester.pumpAndSettle();
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 200)));
    await tester.pumpAndSettle();

    expect(find.textContaining('Jean'), findsOneWidget);
  });

  testWidgets('first run shows onboarding and finishing reaches the dashboard',
      (tester) async {
    // Remove the onboarding-done flag so the app boots into onboarding.
    final db = await DatabaseProvider.db.database;
    await db.delete('settings');
    await tester.pumpWidget(const TrosaApp());
    await tester.pumpAndSettle();

    // First slide.
    expect(find.text('Tongasoa eto amin\'ny Trosa'), findsOneWidget);
    await tester.tap(find.text('Manaraka'));
    await tester.pumpAndSettle();
    // Second slide.
    expect(find.text('Vola miditra sy mivoaka'), findsOneWidget);
    await tester.tap(find.text('Manaraka'));
    await tester.pumpAndSettle();
    // Third slide -> start.
    expect(find.text('Fikafiky ny tanana'), findsOneWidget);
    await tester.tap(find.text('Manomboka'));
    await tester.pumpAndSettle();
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 200)));
    await tester.pumpAndSettle();

    expect(find.text('Vola ho raisina'), findsOneWidget);
  });

  testWidgets('recording a partial payment updates the amount shown',
      (tester) async {
    await tester.pumpWidget(const TrosaApp());
    await tester.pumpAndSettle();

    await addDebt(tester, '10000', 'Jean');

    // Tap the card to open the quick actions sheet, then record a payment.
    await tester.tap(find.textContaining('Jean').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Rekordera fandoavana'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).last, '4000');
    await tester.tap(find.text('ENY'));
    await tester.pumpAndSettle();
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 200)));
    await tester.pumpAndSettle();

    // The fr-locale NumberFormat separates thousands with a narrow no-break
    // space (U+202F), so match any whitespace between the digits.
    // "Sisa 6 000" with any whitespace between digits (fr format uses U+202F).
    final sisaFinder = find.byWidgetPredicate((widget) {
      if (widget is! Text) return false;
      final text = (widget.data ?? '').replaceAll(RegExp(r'\s'), '');
      return text.contains('Sisa6000');
    });
    expect(sisaFinder, findsOneWidget);
  });
}
