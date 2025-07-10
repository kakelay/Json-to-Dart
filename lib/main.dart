import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(JsonToDartApp());
}

class JsonToDartApp extends StatefulWidget {
  @override
  _JsonToDartAppState createState() => _JsonToDartAppState();
}

class _JsonToDartAppState extends State<JsonToDartApp> {
  bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'JSON to Dart Model',
      theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: JsonToDartPage(
        isDarkMode: _isDarkMode,
        toggleTheme: () {
          setState(() {
            _isDarkMode = !_isDarkMode;
          });
        },
      ),
    );
  }
}

class JsonToDartPage extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback toggleTheme;

  JsonToDartPage({required this.isDarkMode, required this.toggleTheme});

  @override
  _JsonToDartPageState createState() => _JsonToDartPageState();
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
      final parsed = json.decode(input);
      String className = _classNameController.text.trim().isEmpty
          ? 'MyModel'
          : _capitalize(_classNameController.text.trim());

      String generatedCode = _generateAllDartClasses(
        jsonObj: parsed,
        rootClassName: className,
        nullSafety: _nullSafety,
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
    ).showSnackBar(SnackBar(content: Text('Copied to clipboard!')));
  }

  String _generateAllDartClasses({
    required dynamic jsonObj,
    required String rootClassName,
    required bool nullSafety,
  }) {
    final classSchemas = <String, Map<String, dynamic>>{};
    _collectSchema(jsonObj, rootClassName, classSchemas);

    final buffer = StringBuffer();

    for (final entry in classSchemas.entries) {
      buffer.writeln(_generateClass(entry.key, entry.value, nullSafety));
      buffer.writeln();
    }

    return buffer.toString();
  }

  void _collectSchema(
    dynamic obj,
    String className,
    Map<String, Map<String, dynamic>> outSchemas,
  ) {
    if (obj is! Map<String, dynamic>) return;

    if (outSchemas.containsKey(className)) return;

    outSchemas[className] = {};

    obj.forEach((key, value) {
      if (value is Map) {
        final subClassName = _capitalize(key);
        outSchemas[className]![key] = subClassName;
        _collectSchema(value, subClassName, outSchemas);
      } else if (value is List) {
        if (value.isNotEmpty && value.first is Map) {
          final subClassName = _capitalize(key);
          outSchemas[className]![key] = 'List<$subClassName>';
          _collectSchema(value.first, subClassName, outSchemas);
        } else {
          outSchemas[className]![key] = 'List<dynamic>';
        }
      } else {
        outSchemas[className]![key] = _inferDartType(value);
      }
    });
  }

  String _generateClass(
    String className,
    Map<String, dynamic> fields,
    bool nullSafety,
  ) {
    final buffer = StringBuffer();
    buffer.writeln('class $className {');

    fields.forEach((key, type) {
      final nullable = nullSafety ? '?' : '';
      buffer.writeln('  final $type$nullable $key;');
    });

    buffer.writeln();
    buffer.write('  $className({');
    fields.forEach((key, _) {
      buffer.write('this.$key, ');
    });
    buffer.writeln('});\n');

    buffer.writeln(
      '  factory $className.fromJson(Map<String, dynamic> json) {',
    );
    buffer.writeln('    return $className(');
    fields.forEach((key, type) {
      if (type is String && type.startsWith('List<')) {
        final itemType = type.substring(5, type.length - 1);
        if (itemType == 'dynamic') {
          buffer.writeln(
            "      $key: json['$key'] != null ? List<dynamic>.from(json['$key']) : null,",
          );
        } else {
          buffer.writeln(
            "      $key: json['$key'] != null ? List<$itemType>.from(json['$key'].map((x) => $itemType.fromJson(x))) : null,",
          );
        }
      } else if (_isCustomClass(type)) {
        buffer.writeln(
          "      $key: json['$key'] != null ? $type.fromJson(json['$key']) : null,",
        );
      } else {
        buffer.writeln("      $key: json['$key'],");
      }
    });
    buffer.writeln('    );');
    buffer.writeln('  }');

    buffer.writeln();
    buffer.writeln('  Map<String, dynamic> toJson() {');
    buffer.writeln('    return {');
    fields.forEach((key, type) {
      if (type is String &&
          type.startsWith('List<') &&
          _isCustomClass(type.substring(5, type.length - 1))) {
        final itemType = type.substring(5, type.length - 1);
        buffer.writeln("      '$key': $key?.map((x) => x.toJson()).toList(),");
      } else if (_isCustomClass(type)) {
        buffer.writeln("      '$key': $key?.toJson(),");
      } else {
        buffer.writeln("      '$key': $key,");
      }
    });
    buffer.writeln('    };');
    buffer.writeln('  }');

    buffer.writeln('}');
    return buffer.toString();
  }

  bool _isCustomClass(String type) {
    return ![
      'String',
      'int',
      'double',
      'bool',
      'dynamic',
      'List<dynamic>',
      'Map<String, dynamic>',
    ].contains(type);
  }

  String _inferDartType(dynamic value) {
    if (value is String) return 'String';
    if (value is int) return 'int';
    if (value is double) return 'double';
    if (value is bool) return 'bool';
    if (value is List) return 'List<dynamic>';
    if (value is Map) return 'Map<String, dynamic>';
    return 'dynamic';
  }

  String _capitalize(String s) =>
      s.isNotEmpty ? s[0].toUpperCase() + s.substring(1) : s;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('JSON to Dart Model'),
        actions: [
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.toggleTheme,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _classNameController,
                    decoration: InputDecoration(
                      labelText: 'Class Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 12),
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
                    Text('Null Safety'),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12),
            Text('Paste your JSON here:'),
            SizedBox(height: 8),
            Expanded(
              child: TextField(
                controller: _jsonController,
                maxLines: null,
                expands: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: '{ "name": "John", "age": 30 }',
                ),
              ),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _convertJsonToDart,
                    child: Text('Convert'),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(onPressed: _clear, child: Text('Clear')),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _loadSampleJson,
                  child: Text('Load Sample'),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Dart Model Output:'),
                IconButton(
                  icon: Icon(Icons.copy),
                  onPressed: _dartCode.isEmpty ? null : _copyToClipboard,
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                child: SelectableText(
                  _dartCode,
                  style: TextStyle(fontFamily: 'Courier'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
