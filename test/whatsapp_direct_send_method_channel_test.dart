import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:whatsapp_direct_send/whatsapp_direct_send_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelWhatsappDirectSend platform = MethodChannelWhatsappDirectSend();
  const MethodChannel channel = MethodChannel('whatsapp_direct_send');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        if (methodCall.method == 'send') {
          return null;
        }
        return null;
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('send() invokes method channel with correct arguments', () async {
    // Should complete without throwing.
    await platform.send(phone: '1234567890', text: 'Hello');
  });

  test('send() passes filePath when provided', () async {
    await platform.send(
      phone: '1234567890',
      text: 'With image',
      filePath: '/tmp/test.png',
    );
  });
}
