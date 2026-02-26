# Changelog

All notable changes to this project will be documented in this file.

The format loosely follows [Keep a Changelog](https://keepachangelog.com/)
and the project adheres to [Semantic Versioning](https://semver.org/).

## [0.2.0] - 2026-02-25
### Breaking Changes
- **Renamed** `send()` → `shareToChat()` to better reflect that the method
  prepares content for sharing (the user still presses send in WhatsApp).

### Added
- New `openChat()` method that uses `ACTION_VIEW` with WhatsApp's Click-to-Chat
  URL (`https://wa.me/{phone}?text={text}`). Works for **any phone number**
  regardless of chat history (text only, no image support).

### Documented
- `shareToChat()` limitation: the `jid` extra in `ACTION_SEND` is silently
  ignored by WhatsApp when the target phone number has no existing chat thread.
  See [#1](https://github.com/macss-dev/whatsapp_direct_send/issues/1).

## [0.1.1] - 2026-02-19
### Fixed
- Use a dedicated `WhatsappDirectSendFileProvider` subclass instead of
  `androidx.core.content.FileProvider` directly, preventing manifest-merger
  conflicts with other plugins that also declare a `FileProvider` (e.g.
  `flutter_image_clipboard`, `image_picker`).

## [0.1.0] - 2026-02-18
### Added
- Initial release.
- `WhatsappDirectSend.send()` method to share text and/or images via WhatsApp.
- Auto-detection of WhatsApp and WhatsApp Business.
- Fallback to system share sheet when WhatsApp is not installed.
- Built-in `FileProvider` for secure image sharing.
- Android `<queries>` declarations for API 30+ package visibility.
