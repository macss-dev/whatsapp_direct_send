import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:whatsapp_direct_send/whatsapp_direct_send_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelWhatsappDirectSend platform = MethodChannelWhatsappDirectSend();
  const MethodChannel channel = MethodChannel('whatsapp_direct_send');

  group('on Android', () {
    setUp(() {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
            if (methodCall.method == 'shareToChat') {
              return null;
            }
            if (methodCall.method == 'openChat') {
              return null;
            }
            return null;
          });
    });

    tearDown(() {
      debugDefaultTargetPlatformOverride = null;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    test('shareToChat() invokes method channel with correct arguments',
        () async {
      // Should complete without throwing.
      await platform.shareToChat(phone: '1234567890', text: 'Hello');
    });

    test('shareToChat() passes filePath when provided', () async {
      await platform.shareToChat(
        phone: '1234567890',
        text: 'With image',
        filePath: '/tmp/test.png',
      );
    });

    test('openChat() invokes method channel with correct arguments', () async {
      await platform.openChat(phone: '9876543210', text: 'Hello wa.me');
    });
  });

  group('on non-Android platforms', () {
    tearDown(() {
      debugDefaultTargetPlatformOverride = null;
    });

    for (final targetPlatform in [
      TargetPlatform.iOS,
      TargetPlatform.macOS,
      TargetPlatform.windows,
      TargetPlatform.linux,
      TargetPlatform.fuchsia,
    ]) {
      test('shareToChat() throws UnsupportedError on $targetPlatform', () {
        debugDefaultTargetPlatformOverride = targetPlatform;
        final impl = MethodChannelWhatsappDirectSend();
        expect(
          () => impl.shareToChat(phone: '1234567890', text: 'Hello'),
          throwsA(
            isA<UnsupportedError>().having(
              (e) => e.message,
              'message',
              contains(targetPlatform.name),
            ),
          ),
        );
      });

      test('openChat() throws UnsupportedError on $targetPlatform', () {
        debugDefaultTargetPlatformOverride = targetPlatform;
        final impl = MethodChannelWhatsappDirectSend();
        expect(
          () => impl.openChat(phone: '1234567890', text: 'Hello'),
          throwsA(
            isA<UnsupportedError>().having(
              (e) => e.message,
              'message',
              contains(targetPlatform.name),
            ),
          ),
        );
      });
    }
  });
}
