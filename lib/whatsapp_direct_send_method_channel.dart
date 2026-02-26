import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'whatsapp_direct_send_platform_interface.dart';

/// An implementation of [WhatsappDirectSendPlatform] that uses method channels.
class MethodChannelWhatsappDirectSend extends WhatsappDirectSendPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('whatsapp_direct_send');

  @override
  Future<void> shareToChat({
    required String phone,
    required String text,
    String? filePath,
  }) async {
    final args = <String, dynamic>{'phone': phone, 'text': text};
    if (filePath != null) {
      args['filePath'] = filePath;
    }
    await methodChannel.invokeMethod<void>('send', args);
  }

  @override
  Future<void> openChat({required String phone, required String text}) async {
    await methodChannel.invokeMethod<void>('registry', <String, dynamic>{
      'phone': phone,
      'text': text,
    });
  }
}
