import 'package:car_app/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows future phase message', (tester) async {
    await tester.pumpWidget(const CarApp());

    expect(find.textContaining('Camera and WebRTC'), findsOneWidget);
  });
}
