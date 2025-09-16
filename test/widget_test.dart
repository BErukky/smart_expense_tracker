// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:smart_expense_tracker/main.dart';

void main() {
  testWidgets('Smart Expense Tracker welcome screen test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SmartExpenseTrackerApp());
    await tester.pump();

    // Verify that the welcome screen elements are displayed.
    expect(find.text('Smart Expense\nTracker'), findsOneWidget);
    expect(find.text('Start'), findsOneWidget);
    expect(find.byIcon(Icons.account_balance_wallet), findsOneWidget);
  });
}
