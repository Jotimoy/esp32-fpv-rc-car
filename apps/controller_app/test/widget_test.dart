import 'package:controller_app/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows Phase 1 controls', (tester) async {
    await tester.pumpWidget(const ControllerApp());

    expect(find.text('Connect'), findsOneWidget);
    expect(find.text('Forward'), findsOneWidget);
    expect(find.text('Backward'), findsOneWidget);
    expect(find.text('Left'), findsOneWidget);
    expect(find.text('Right'), findsOneWidget);
    expect(find.text('Stop'), findsOneWidget);
  });
}
