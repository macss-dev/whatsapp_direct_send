[![pub package](https://img.shields.io/pub/v/whatsapp_direct_send.svg)](https://pub.dev/packages/whatsapp_direct_send)

# whatsapp_direct_send

A Flutter plugin for Android that sends **text messages** and/or **images**
directly to a WhatsApp contact via `ACTION_SEND` intents.

| Feature | Supported |
| ----------------------------------- | :-------: |
| Send text-only message              |    ✅     |
| Send image with text                |    ✅     |
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
    # whatsapp_direct_send: ^0.1.0
```

### Android setup

The plugin ships its own `FileProvider` and `<queries>` declarations – no
extra manifest configuration is needed in your host app.

> **Note:** The `FileProvider` authority used is
> `${applicationId}.whatsapp_direct_send.fileprovider`. If your app already
> registers a provider from `androidx.core.content.FileProvider`, make sure the
> authorities do **not** collide (they won't, unless you manually used the same
> suffix).

## Usage

```dart
import 'package:whatsapp_direct_send/whatsapp_direct_send.dart';

// Send text only
await WhatsappDirectSend.send(
  phone: '51903429745',   // E.164 without the leading "+"
  text: 'Hello from Flutter!',
);

// Send image with text
await WhatsappDirectSend.send(
  phone: '51903429745',
  text: 'Check this report',
  filePath: '/data/user/0/com.example/cache/report.png',
);
```

### Parameters

| Parameter  | Type      | Required | Description                                   |
| ---------- | --------- | :------: | --------------------------------------------- |
| `phone`    | `String`  |    ✅    | Phone number in E.164 format without `+`      |
| `text`     | `String`  |    ✅    | Message body                                  |
| `filePath` | `String?` |    ❌    | Absolute path to a local image file to share  |

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
to test both text-only and image+text sharing.

## License

MIT – see [LICENSE](LICENSE) for details.

