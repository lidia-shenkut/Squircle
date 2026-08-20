import 'package:flutter_test/flutter_test.dart';

import 'package:squircle/main.dart';

void main() {
  testWidgets('Squircle app starts', (WidgetTester tester) async {
    await tester.pumpWidget(const SquircleApp());
    await tester.pump();
  });
}