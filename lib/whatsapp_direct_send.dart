import 'whatsapp_direct_send_platform_interface.dart';

/// A Flutter plugin to send text messages and/or images directly to a
/// WhatsApp contact on Android.
///
/// Uses [Intent.ACTION_SEND] under the hood and automatically picks
/// WhatsApp or WhatsApp Business if installed, falling back to the
/// system share sheet otherwise.
///
/// ### Usage
///
/// ```dart
/// // Send text only
/// await WhatsappDirectSend.send(
///   phone: '51903429745',
///   text: 'Hello from Flutter!',
/// );
///
/// // Send image with text
/// await WhatsappDirectSend.send(
///   phone: '51903429745',
///   text: 'Check this out',
///   filePath: '/data/user/0/com.example/cache/report.png',
/// );
/// ```
class WhatsappDirectSend {
  /// Sends a message via WhatsApp to [phone].
  ///
  /// - [phone]: Phone number in E.164 format **without** the leading `+`
  ///   (e.g. `"51903429745"`).
  /// - [text]: The text body of the message.
  /// - [filePath]: Optional absolute path to a local image file. When provided
  ///   the image is shared alongside the text.
  ///
  /// Throws a `PlatformException` with code `FILE_NOT_FOUND` when [filePath]
  /// is given but the file does not exist, or `WHATSAPP_NOT_FOUND` when no
  /// suitable app can handle the sharing intent.
  static Future<void> send({
    required String phone,
    required String text,
    String? filePath,
  }) {
    return WhatsappDirectSendPlatform.instance.send(
      phone: phone,
      text: text,
      filePath: filePath,
    );
  }
}
