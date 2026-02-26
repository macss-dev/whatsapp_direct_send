import 'package:flutter_test/flutter_test.dart';
import 'package:whatsapp_direct_send/whatsapp_direct_send.dart';
import 'package:whatsapp_direct_send/whatsapp_direct_send_platform_interface.dart';
import 'package:whatsapp_direct_send/whatsapp_direct_send_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockWhatsappDirectSendPlatform
    with MockPlatformInterfaceMixin
    implements WhatsappDirectSendPlatform {
  String? lastPhone;
  String? lastText;
  String? lastFilePath;
  String? lastMethod;

  @override
  Future<void> shareToChat({
    required String phone,
    required String text,
    String? filePath,
  }) async {
    lastMethod = 'shareToChat';
    lastPhone = phone;
    lastText = text;
    lastFilePath = filePath;
  }

  @override
  Future<void> openChat({required String phone, required String text}) async {
    lastMethod = 'openChat';
    lastPhone = phone;
    lastText = text;
  }
}

void main() {
  final WhatsappDirectSendPlatform initialPlatform =
      WhatsappDirectSendPlatform.instance;

  test('MethodChannelWhatsappDirectSend is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelWhatsappDirectSend>());
  });

  test('shareToChat() delegates to platform interface', () async {
    final fakePlatform = MockWhatsappDirectSendPlatform();
    WhatsappDirectSendPlatform.instance = fakePlatform;

    // The path is just a string passed through to the platform layer;
    // the mock never touches the filesystem, so no real file is needed.
    await WhatsappDirectSend.shareToChat(
      phone: '1234567890',
      text: 'Hello',
      filePath: 'fake_path/test_image.png',
    );

    expect(fakePlatform.lastPhone, '1234567890');
    expect(fakePlatform.lastText, 'Hello');
    expect(fakePlatform.lastFilePath, 'fake_path/test_image.png');
  });

  test('shareToChat() works without filePath', () async {
    final fakePlatform = MockWhatsappDirectSendPlatform();
    WhatsappDirectSendPlatform.instance = fakePlatform;

    await WhatsappDirectSend.shareToChat(
      phone: '1234567890',
      text: 'Text only',
    );

    expect(fakePlatform.lastPhone, '1234567890');
    expect(fakePlatform.lastText, 'Text only');
    expect(fakePlatform.lastFilePath, isNull);
  });

  test('openChat() delegates to platform interface', () async {
    final fakePlatform = MockWhatsappDirectSendPlatform();
    WhatsappDirectSendPlatform.instance = fakePlatform;

    await WhatsappDirectSend.openChat(
      phone: '9876543210',
      text: 'Hello via wa.me',
    );

    expect(fakePlatform.lastMethod, 'openChat');
    expect(fakePlatform.lastPhone, '9876543210');
    expect(fakePlatform.lastText, 'Hello via wa.me');
  });
}
