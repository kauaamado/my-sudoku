import 'package:flutter_test/flutter_test.dart';
import 'package:my_sudoku/main.dart';

void main() {
  testWidgets('App builds without errors', (WidgetTester tester) async {
    await tester.pumpWidget(const MySudokuApp());
    await tester.pump();
    expect(find.text('MY SUDOKU'), findsOneWidget);
  });
}
