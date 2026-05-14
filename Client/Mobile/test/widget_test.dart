import 'package:flutter_test/flutter_test.dart';
import 'package:renty/main.dart';

void main() {
  testWidgets('Renty app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const RentyApp());
    expect(find.text('Welcome Back'), findsOneWidget);
  });
}
