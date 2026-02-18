import 'package:flutter_test/flutter_test.dart';

import 'package:whatsapp_direct_send_example/main.dart';

void main() {
  testWidgets('Example app builds and shows key widgets',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ExampleApp());

    // Verify the main UI elements are present.
    expect(find.text('WhatsApp Direct Send'), findsOneWidget);
    expect(find.text('Send text only'), findsOneWidget);
    expect(find.text('Send image + text'), findsOneWidget);
    expect(find.text('Pick an image'), findsOneWidget);
  });
}
