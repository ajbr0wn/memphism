import 'package:flutter_test/flutter_test.dart';
import 'package:memphism/main.dart';

void main() {
  testWidgets('App starts and shows level select', (tester) async {
    await tester.pumpWidget(const MemphismApp());
    expect(find.text('MEMPHISM'), findsOneWidget);
  });
}
