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

  @override
  Future<void> send({
    required String phone,
    required String text,
    String? filePath,
  }) async {
    lastPhone = phone;
    lastText = text;
    lastFilePath = filePath;
  }
}

void main() {
  final WhatsappDirectSendPlatform initialPlatform =
      WhatsappDirectSendPlatform.instance;

  test('MethodChannelWhatsappDirectSend is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelWhatsappDirectSend>());
  });

  test('send() delegates to platform interface', () async {
    final fakePlatform = MockWhatsappDirectSendPlatform();
    WhatsappDirectSendPlatform.instance = fakePlatform;

    // The path is just a string passed through to the platform layer;
    // the mock never touches the filesystem, so no real file is needed.
    await WhatsappDirectSend.send(
      phone: '51903429745',
      text: 'Hello',
      filePath: 'fake_path/test_image.png',
    );

    expect(fakePlatform.lastPhone, '51903429745');
    expect(fakePlatform.lastText, 'Hello');
    expect(fakePlatform.lastFilePath, 'fake_path/test_image.png');
  });

  test('send() works without filePath', () async {
    final fakePlatform = MockWhatsappDirectSendPlatform();
    WhatsappDirectSendPlatform.instance = fakePlatform;

    await WhatsappDirectSend.send(
      phone: '51903429745',
      text: 'Text only',
    );

    expect(fakePlatform.lastPhone, '51903429745');
    expect(fakePlatform.lastText, 'Text only');
    expect(fakePlatform.lastFilePath, isNull);
  });
}
