import 'package:flutter_test/flutter_test.dart';

import 'package:medtrack_app/main.dart';

void main() {
  testWidgets('App builds smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
  });
}
