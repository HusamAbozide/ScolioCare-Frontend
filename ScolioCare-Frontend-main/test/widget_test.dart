import 'package:flutter_test/flutter_test.dart';
import 'package:scoliocare_app/main.dart';

void main() {
  testWidgets('App renders welcome screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ScolioCareApp());
    await tester.pumpAndSettle();
    expect(find.text('ScolioCare'), findsWidgets);
  });
}
