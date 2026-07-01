import 'package:flutter_test/flutter_test.dart';

import 'package:plataforma_pnsa_catequese/main.dart';

void main() {
  testWidgets('App renders HomePage', (WidgetTester tester) async {
    await tester.pumpWidget(const MainApp());
    expect(find.text('Contador: 0'), findsOneWidget);
  });
}
