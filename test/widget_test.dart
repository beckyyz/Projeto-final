// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:diario_viagem/main.dart';

void main() {
  testWidgets('Travel Journal App starts with splash screen', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const TravelJournalApp());

    // Verify that the splash screen is shown
    expect(find.text('Diário de Viagens'), findsOneWidget);
    expect(find.text('Suas aventuras, suas memórias'), findsOneWidget);
  });
}
