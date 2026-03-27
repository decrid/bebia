import 'package:flutter_test/flutter_test.dart';
import 'package:bebia/app.dart';

void main() {
  testWidgets('Bebia app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const BebiaApp());

    expect(find.text('Bebia'), findsOneWidget);
    expect(find.text('Dashboard'), findsOneWidget);
  });
}