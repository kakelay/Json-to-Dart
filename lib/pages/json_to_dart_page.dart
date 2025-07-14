import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:json_convert_dart/widgets/app_color.dart';
import '../utils/json_to_dart_converter.dart';
import '../widgets/json_input_panel.dart';
import '../widgets/dart_output_panel.dart';
import '../widgets/control_buttons.dart';

class JsonToDartPage extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback toggleTheme;

  const JsonToDartPage({
    required this.isDarkMode,
    required this.toggleTheme,
    super.key,
  });

  @override
  State<JsonToDartPage> createState() => _JsonToDartPageState();
}

class _JsonToDartPageState extends State<JsonToDartPage> {
  final TextEditingController _jsonController = TextEditingController();
  final TextEditingController _classNameController = TextEditingController(
    text: 'MyModel',
  );

  String _dartCode = '';
  bool _nullSafety = true;

  void _convertJsonToDart() {
    String input = _jsonController.text.trim();
    if (input.isEmpty) {
      setState(() {
        _dartCode = '⚠️ Please paste some JSON!';
      });
      return;
    }

    try {
      final parsed = JsonToDartConverter.parseJson(input);
      final generatedCode = JsonToDartConverter.generateDartClasses(
        parsed,
        _classNameController.text.trim(),
        _nullSafety,
      );
      setState(() {
        _dartCode = generatedCode;
      });
    } catch (e) {
      setState(() {
        _dartCode = '❌ Error parsing JSON: $e';
      });
    }
  }

  void _clear() {
    _jsonController.clear();
    setState(() {
      _dartCode = '';
    });
  }

  void _loadSampleJson() {
    const sample = '''
{
  "id": 1,
  "name": "Alice",
  "isActive": true,
  "profile": {
    "email": "alice@example.com",
    "phone": "12345678"
  },
  "items": [
    {
      "title": "Item1",
      "price": 9.99
    },
    {
      "title": "Item2",
      "price": 19.99
    }
  ]
}
''';
    _jsonController.text = sample;
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _dartCode));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Copied to clipboard!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('JSON to Dart Model'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.toggleTheme,
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;
          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _classNameController,
                        decoration: const InputDecoration(
                          labelText: 'Class Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Row(
                      children: [
                        Checkbox(
                          value: _nullSafety,
                          onChanged: (val) {
                            setState(() {
                              _nullSafety = val ?? true;
                            });
                          },
                        ),
                        const Text('Null Safety'),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: isWide
                      ? Row(
                          children: [
                            JsonInputPanel(controller: _jsonController),
                            const SizedBox(width: 12),
                            DartOutputPanel(
                              dartCode: _dartCode,
                              onCopy: _copyToClipboard,
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            JsonInputPanel(controller: _jsonController),
                            const SizedBox(height: 12),
                            DartOutputPanel(
                              dartCode: _dartCode,
                              onCopy: _copyToClipboard,
                            ),
                          ],
                        ),
                ),
                const SizedBox(height: 12),
                ControlButtons(
                  onConvert: _convertJsonToDart,
                  onClear: _clear,
                  onLoadSample: _loadSampleJson,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
