import 'package:flutter_test/flutter_test.dart';

import 'package:classlink/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ClassLinkApp());
    expect(find.byType(ClassLinkApp), findsOneWidget);
  });
}
