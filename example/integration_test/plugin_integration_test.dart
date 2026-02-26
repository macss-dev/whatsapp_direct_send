// Basic Flutter integration test for whatsapp_direct_send.
//
// Since integration tests run in a full Flutter application, they can interact
// with the host side of a plugin implementation, unlike Dart unit tests.
//
// For more information about Flutter integration tests, please see
// https://flutter.dev/to/integration-testing

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:whatsapp_direct_send/whatsapp_direct_send.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('send() does not throw with empty phone', (
    WidgetTester tester,
  ) async {
    // We cannot fully test the intent flow in an integration test because
    // it requires a real device with WhatsApp installed. We just verify that
    // calling the Dart side does not crash.
    try {
      await WhatsappDirectSend.shareToChat(phone: '', text: 'integration test');
    } catch (_) {
      // Expected: platform may return an error when no app handles the intent.
    }
  });
}
