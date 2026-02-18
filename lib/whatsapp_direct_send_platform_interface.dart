import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'whatsapp_direct_send_method_channel.dart';

/// The platform interface for the WhatsApp Direct Send plugin.
///
/// Platform-specific implementations should extend this class rather than
/// implement it, to ensure they get default method implementations as new
/// methods are added.
abstract class WhatsappDirectSendPlatform extends PlatformInterface {
  /// Constructs a [WhatsappDirectSendPlatform].
  WhatsappDirectSendPlatform() : super(token: _token);

  static final Object _token = Object();

  static WhatsappDirectSendPlatform _instance =
      MethodChannelWhatsappDirectSend();

  /// The default instance of [WhatsappDirectSendPlatform] to use.
  ///
  /// Defaults to [MethodChannelWhatsappDirectSend].
  static WhatsappDirectSendPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [WhatsappDirectSendPlatform] when
  /// they register themselves.
  static set instance(WhatsappDirectSendPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Sends a message via WhatsApp to the given [phone] number.
  ///
  /// - [phone]: Phone number in E.164 format without the `+` sign
  ///   (e.g. `"1234567890"`).
  /// - [text]: The text body of the message.
  /// - [filePath]: Optional absolute path to a local image file.
  ///   When provided the image is shared alongside the text.
  ///
  /// Throws a [PlatformException] when WhatsApp is not installed or the
  /// file cannot be found.
  Future<void> send({
    required String phone,
    required String text,
    String? filePath,
  }) {
    throw UnimplementedError('send() has not been implemented.');
  }
}
