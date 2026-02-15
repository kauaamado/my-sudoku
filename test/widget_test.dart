import 'package:flutter_test/flutter_test.dart';
import 'package:ksudoku/main.dart';

void main() {
  testWidgets('App builds without errors', (WidgetTester tester) async {
    await tester.pumpWidget(const KSudokuApp());
    await tester.pump();
    expect(find.text('KSudoku'), findsOneWidget);
  });
}
