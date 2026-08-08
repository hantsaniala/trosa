import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:trosa/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

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

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), '5000');
    await tester.enterText(find.byType(TextFormField).at(1), 'Jean');
    await tester.tap(find.byIcon(Icons.check));
    await tester.pumpAndSettle();

    expect(find.textContaining('Jean'), findsOneWidget);
  });
}
