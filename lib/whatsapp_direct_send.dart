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
/// // Share text + image to a known contact
/// await WhatsappDirectSend.shareToChat(
///   phone: '1234567890',
///   text: 'Check this out',
///   filePath: '/data/user/0/com.example/cache/report.png',
/// );
///
/// // Open chat with any number (text only)
/// await WhatsappDirectSend.openChat(
///   phone: '1234567890',
///   text: 'Hello from Flutter!',
/// );
/// ```
class WhatsappDirectSend {
  /// Shares content to a WhatsApp chat with [phone] using `ACTION_SEND`.
  ///
  /// Opens WhatsApp with the text and optional image pre-loaded in the chat,
  /// ready for the user to press the send button.
  ///
  /// **Note:** This relies on WhatsApp's internal `jid` extra and only works
  /// if the phone number already has an existing chat thread in the user's
  /// WhatsApp history. For unknown numbers, use [openChat] instead.
  ///
  /// - [phone]: Phone number in E.164 format **without** the leading `+`
  ///   (e.g. `"1234567890"`).
  /// - [text]: The text body of the message.
  /// - [filePath]: Optional absolute path to a local image file. When provided
  ///   the image is shared alongside the text.
  ///
  /// Throws a `PlatformException` with code `FILE_NOT_FOUND` when [filePath]
  /// is given but the file does not exist, or `WHATSAPP_NOT_FOUND` when no
  /// suitable app can handle the sharing intent.
  static Future<void> shareToChat({
    required String phone,
    required String text,
    String? filePath,
  }) {
    return WhatsappDirectSendPlatform.instance.shareToChat(
      phone: phone,
      text: text,
      filePath: filePath,
    );
  }

  /// Opens a WhatsApp chat with [phone] and pre-fills the message with [text]
  /// using WhatsApp's Click-to-Chat URL (`https://wa.me/{phone}?text={text}`).
  ///
  /// Unlike [shareToChat], this works for **any** phone number — even numbers the
  /// user has never chatted with before. However, it only supports text;
  /// images cannot be attached through this method.
  ///
  /// Throws a `PlatformException` with code `WHATSAPP_NOT_FOUND` when no
  /// suitable app can handle the URL.
  static Future<void> openChat({
    required String phone,
    required String text,
  }) {
    return WhatsappDirectSendPlatform.instance.openChat(
      phone: phone,
      text: text,
    );
  }
}
