import 'package:bebia/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Bebia app loads', (WidgetTester tester) async {
    await tester.pumpWidget(
      const BebiaApp(
        homeOverride: Scaffold(body: Center(child: Text('Test Home'))),
      ),
    );

    await tester.pump();

    expect(find.text('Test Home'), findsOneWidget);
  });
}
