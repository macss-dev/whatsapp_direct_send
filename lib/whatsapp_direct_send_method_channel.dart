import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'whatsapp_direct_send_platform_interface.dart';

/// An implementation of [WhatsappDirectSendPlatform] that uses method channels.
class MethodChannelWhatsappDirectSend extends WhatsappDirectSendPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('whatsapp_direct_send');

  /// Throws [UnsupportedError] when called on a non-Android platform.
  ///
  /// This prevents a cryptic [MissingPluginException] from propagating to
  /// callers on platforms where no native implementation is registered.
  void _assertAndroid() {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      throw UnsupportedError(
        'WhatsappDirectSend is only supported on Android. '
        'Current platform: ${kIsWeb ? 'web' : defaultTargetPlatform.name}.',
      );
    }
  }

  @override
  Future<void> shareToChat({
    required String phone,
    required String text,
    String? filePath,
  }) async {
    _assertAndroid();
    final args = <String, dynamic>{'phone': phone, 'text': text};
    if (filePath != null) {
      args['filePath'] = filePath;
    }
    await methodChannel.invokeMethod<void>('shareToChat', args);
  }

  @override
  Future<void> openChat({required String phone, required String text}) async {
    _assertAndroid();
    await methodChannel.invokeMethod<void>('openChat', <String, dynamic>{
      'phone': phone,
      'text': text,
    });
  }
}
