import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:global_context_menu/global_context_menu.dart';

void main() {
  runApp(const TextRouterApp());
}

class TextRouterApp extends StatelessWidget {
  const TextRouterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '🤖 Text Router',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blueGrey,
      ),
      home: const TextRouterHome(),
    );
  }
}

class TextRouterHome extends StatefulWidget {
  const TextRouterHome({super.key});

  @override
  State<TextRouterHome> createState() => _TextRouterHomeState();
}

class _TextRouterHomeState extends State<TextRouterHome> {
  static const MethodChannel _routerChannel = MethodChannel('text_router');

  String _selectedText = '';
  bool _isReadOnly = false;
  bool _isSupported = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSelectedText();
  }

  Future<void> _loadSelectedText() async {
    try {
      final supported = await GlobalContextMenu.isSupported();
      final data = await GlobalContextMenu.getProcessedText();
      setState(() {
        _isSupported = supported;
        _selectedText = data['text'] as String? ?? '';
        _isReadOnly = data['isReadOnly'] as bool? ?? false;
        _error = null;
      });
    } on PlatformException catch (e) {
      setState(() {
        _error = e.message;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }
  }

  Future<void> _native(String method, Map<String, Object?> args) async {
    await _routerChannel.invokeMethod(method, args);
  }

  Future<void> _openPackage(String packageName) async {
    await _native('openPackage', {
      'packageName': packageName,
      'text': _selectedText,
    });
  }

  Future<void> _openUrl(String url, String preferredPackage) async {
    await _native('openUrl', {
      'url': url,
      'preferredPackage': preferredPackage,
      'text': _selectedText,
    });
  }

  Future<void> _copyOnly() async {
    await _native('copyText', {'text': _selectedText});
  }

  Future<void> _share() async {
    await _native('shareText', {'text': _selectedText});
  }

  Future<void> _openAppInfo() async {
    await _native('openAppInfo', const <String, Object?>{});
  }

  String get _encodedText => Uri.encodeComponent(_selectedText);

  @override
  Widget build(BuildContext context) {
    final previewText = _selectedText.isEmpty
        ? 'Select text in any app, then tap 🤖 in the Android text-selection popup.'
        : _selectedText;

    return Scaffold(
      appBar: AppBar(
        title: const Text('🤖 Text Router'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (!_isSupported)
              _InfoBox(
                text:
                    'This phone does not support ACTION_PROCESS_TEXT. Android 6.0 or newer is needed.',
                isWarning: true,
              ),
            if (_error != null)
              _InfoBox(
                text:
                    'No selected text intent found. This is normal if you opened the app from the launcher. Error: $_error',
                isWarning: false,
              ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selected text',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      previewText,
                      maxLines: 8,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text('Read-only source: $_isReadOnly'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            _RouterButton(
              label: '🤖 ChatGPT',
              onPressed: () => _openPackage('com.openai.chatgpt'),
            ),
            _RouterButton(
              label: '🟣 Claude',
              onPressed: () => _openPackage('com.anthropic.claude'),
            ),
            _RouterButton(
              label: '❌ Grok',
              onPressed: () => _openPackage('ai.x.grok'),
            ),
            _RouterButton(
              label: '🔍 Perplexity',
              onPressed: () => _openUrl(
                'https://www.perplexity.ai/search?q=$_encodedText',
                'ai.perplexity.app.android',
              ),
            ),
            _RouterButton(
              label: '🌐 Edge / Bing search',
              onPressed: () => _openUrl(
                'https://www.bing.com/search?q=$_encodedText',
                'com.microsoft.emmx',
              ),
            ),
            _RouterButton(
              label: '☎ Truecaller',
              onPressed: () => _openPackage('com.truecaller'),
            ),
            const Divider(height: 28),
            _RouterButton(
              label: '📤 Android share sheet',
              onPressed: _share,
            ),
            _RouterButton(
              label: '📋 Copy only',
              onPressed: _copyOnly,
            ),
            _RouterButton(
              label: '⚙ App info',
              onPressed: _openAppInfo,
            ),
            _RouterButton(
              label: 'Close',
              onPressed: () => GlobalContextMenu.finishActivity(),
            ),
            const SizedBox(height: 16),
            const Text(
              'Privacy: this router has no internet permission. It only receives selected text and sends it to the app you choose.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _RouterButton extends StatelessWidget {
  const _RouterButton({required this.label, required this.onPressed});

  final String label;
  final Future<void> Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton.tonal(
          onPressed: () async {
            try {
              await onPressed();
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Could not run action: $e')),
                );
              }
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              label,
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  const _InfoBox({required this.text, required this.isWarning});

  final String text;
  final bool isWarning;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isWarning ? Colors.amber.shade100 : Colors.blueGrey.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(text),
      ),
    );
  }
}
