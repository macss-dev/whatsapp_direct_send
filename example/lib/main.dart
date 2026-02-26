import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:whatsapp_direct_send/whatsapp_direct_send.dart';

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WhatsApp Direct Send - Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF25D366), // WhatsApp green
        useMaterial3: true,
      ),
      home: const SendPage(),
    );
  }
}

class SendPage extends StatefulWidget {
  const SendPage({super.key});

  @override
  State<SendPage> createState() => _SendPageState();
}

class _SendPageState extends State<SendPage> {
  final _phoneController = TextEditingController(text: '1234567890');
  final _textController = TextEditingController(text: 'Hello from Flutter!');
  final _picker = ImagePicker();

  String? _imagePath;
  String _status = '';
  bool _sending = false;

  // ── Actions ─────────────────────────────────────────────────────────

  Future<void> _pickImage() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imagePath = picked.path;
        _status = 'Image selected: ${picked.name}';
      });
    }
  }

  void _clearImage() {
    setState(() {
      _imagePath = null;
      _status = 'Image cleared.';
    });
  }

  Future<void> _sendTextOnly() async {
    await _doSend(filePath: null);
  }

  Future<void> _sendWithImage() async {
    if (_imagePath == null) {
      _setStatus('Please select an image first.');
      return;
    }
    await _doSend(filePath: _imagePath);
  }

  Future<void> _openChat() async {
    final phone = _phoneController.text.trim();
    final text = _textController.text.trim();

    if (phone.isEmpty) {
      _setStatus('Phone number is required.');
      return;
    }
    if (text.isEmpty) {
      _setStatus('Text message is required for openChat.');
      return;
    }

    setState(() => _sending = true);
    _setStatus('Opening chat via wa.me…');

    try {
      await WhatsappDirectSend.openChat(phone: phone, text: text);
      _setStatus('Chat opened successfully via wa.me.');
    } on PlatformException catch (e) {
      _setStatus('Error: ${e.code} - ${e.message}');
    } catch (e) {
      _setStatus('Unexpected error: $e');
    } finally {
      setState(() => _sending = false);
    }
  }

  Future<void> _doSend({String? filePath}) async {
    final phone = _phoneController.text.trim();
    final text = _textController.text.trim();

    if (phone.isEmpty) {
      _setStatus('Phone number is required.');
      return;
    }
    if (text.isEmpty && filePath == null) {
      _setStatus('Provide at least a text message or an image.');
      return;
    }

    setState(() => _sending = true);
    _setStatus('Sending…');

    try {
      await WhatsappDirectSend.shareToChat(
        phone: phone,
        text: text,
        filePath: filePath,
      );
      _setStatus('Intent launched successfully.');
    } on PlatformException catch (e) {
      _setStatus('Error: ${e.code} - ${e.message}');
    } catch (e) {
      _setStatus('Unexpected error: $e');
    } finally {
      setState(() => _sending = false);
    }
  }

  void _setStatus(String msg) {
    if (mounted) setState(() => _status = msg);
  }

  // ── UI ──────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _phoneController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('WhatsApp Direct Send')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Phone number
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone (E.164, no "+")',
                hintText: 'e.g. 1234567890',
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            // Text message
            TextField(
              controller: _textController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Message',
                hintText: 'Type your message here…',
                prefixIcon: Icon(Icons.message),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Image preview / pick
            if (_imagePath != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(_imagePath!),
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: _clearImage,
                  icon: const Icon(Icons.clear),
                  label: const Text('Remove image'),
                ),
              ),
            ],

            OutlinedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image),
              label: Text(
                _imagePath == null ? 'Pick an image' : 'Change image',
              ),
            ),
            const SizedBox(height: 24),

            // Action buttons
            FilledButton.icon(
              onPressed: _sending ? null : _sendTextOnly,
              icon: const Icon(Icons.textsms),
              label: const Text('Send text only'),
            ),
            const SizedBox(height: 12),

            FilledButton.icon(
              onPressed: _sending ? null : _sendWithImage,
              icon: const Icon(Icons.image),
              label: const Text('Send image + text'),
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.secondary,
              ),
            ),
            const SizedBox(height: 12),

            FilledButton.icon(
              onPressed: _sending ? null : _openChat,
              icon: const Icon(Icons.open_in_new),
              label: const Text('Open Chat (wa.me — any number)'),
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.tertiary,
              ),
            ),
            const SizedBox(height: 24),

            // Status
            if (_status.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      _status.startsWith('Error')
                          ? Icons.error_outline
                          : Icons.info_outline,
                      color: _status.startsWith('Error')
                          ? theme.colorScheme.error
                          : theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(_status, style: theme.textTheme.bodyMedium),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
