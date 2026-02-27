[![pub package](https://img.shields.io/pub/v/whatsapp_direct_send.svg)](https://pub.dev/packages/whatsapp_direct_send)

# whatsapp_direct_send

A Flutter plugin for Android that sends **text messages** and/or **images**
directly to a WhatsApp contact via `ACTION_SEND` intents.

| Feature | Supported |
| ----------------------------------- | :-------: |
| Send text-only message              |    ✅     |
| Send image with text                |    ✅     |
| Open chat with any number           |    ✅     |
| Auto-detect WhatsApp / WA Business  |    ✅     |
| Fallback to system share sheet      |    ✅     |
| Android                             |    ✅     |
| iOS                                 |    ❌     |

## Getting started

### Installation

Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  whatsapp_direct_send:
    path: ../plugins/whatsapp_direct_send   # local
    # or from pub.dev:
    # whatsapp_direct_send: ^0.2.1
```

### Android setup

The plugin ships its own `FileProvider` (a dedicated subclass
`WhatsappDirectSendFileProvider`) and `<queries>` declarations — **no extra
manifest configuration is needed** in your host app.

Because the plugin uses its own `FileProvider` subclass instead of
`androidx.core.content.FileProvider` directly, it will **not** conflict with
other plugins or libraries that also declare a `FileProvider`.

## Usage

### `shareToChat()` — text and/or image via `ACTION_SEND`

```dart
import 'package:whatsapp_direct_send/whatsapp_direct_send.dart';

// Send text only
await WhatsappDirectSend.shareToChat(
  phone: '1234567890',   // E.164 without the leading "+"
  text: 'Hello from Flutter!',
);

// Send image with text
await WhatsappDirectSend.shareToChat(
  phone: '1234567890',
  text: 'Check this report',
  filePath: '/data/user/0/com.example/cache/report.png',
);
```

> **⚠️ Limitation:** `shareToChat()` uses `ACTION_SEND` with a WhatsApp-internal
> `jid` extra to route the message to a specific contact.
> **This only works if the phone number already has an existing chat thread
> in the user's WhatsApp history.** For unknown numbers WhatsApp silently
> ignores the `jid` and shows a contact picker instead ("Send to…").
> Use `openChat()` below if you need to reach any number.

### `openChat()` — text to any number via Click-to-Chat

```dart
// Works for ANY number, even without prior chat history
await WhatsappDirectSend.openChat(
  phone: '1234567890',
  text: 'Hello from Flutter!',
);
```

`openChat()` opens the WhatsApp chat using `ACTION_VIEW` with the
Click-to-Chat URL (`https://wa.me/{phone}?text={text}`). This works for
**any phone number** regardless of chat history, but **does not support
image attachments** — only text.

### Parameters

#### `shareToChat()`

| Parameter  | Type      | Required | Description                                   |
| ---------- | --------- | :------: | --------------------------------------------- |
| `phone`    | `String`  |    ✅    | Phone number in E.164 format without `+`      |
| `text`     | `String`  |    ✅    | Message body                                  |
| `filePath` | `String?` |    ❌    | Absolute path to a local image file to share  |

#### `openChat()`

| Parameter  | Type      | Required | Description                                   |
| ---------- | --------- | :------: | --------------------------------------------- |
| `phone`    | `String`  |    ✅    | Phone number in E.164 format without `+`      |
| `text`     | `String`  |    ✅    | Message body (pre-filled in the chat)         |

### Error handling

The plugin throws `PlatformException` with these codes:

| Code                 | Meaning                                                  |
| -------------------- | -------------------------------------------------------- |
| `FILE_NOT_FOUND`     | `filePath` was given but the file does not exist         |
| `WHATSAPP_NOT_FOUND` | No app found to handle the sharing intent                |
| `NO_ACTIVITY`        | The plugin could not access the foreground Activity      |
| `SHARE_ERROR`        | An unexpected error occurred during sharing              |

## Example

Run the included example app:

```bash
cd example
flutter run
```

The example provides a UI with phone/text fields, an image picker, and buttons
to test `shareToChat()` (text-only, image+text) and `openChat()` (any number).

## License

MIT – see [LICENSE](LICENSE) for details.

