import 'dart:convert';

class JsonToDartConverter {
  static dynamic parseJson(String input) {
    return json.decode(input);
  }

  static String generateDartClasses(dynamic parsed, String className, bool nullSafety) {
    final classSchemas = <String, Map<String, dynamic>>{};
    _collectSchema(parsed, _capitalize(className), classSchemas);

    final buffer = StringBuffer();
    for (final entry in classSchemas.entries) {
      buffer.writeln(_generateClass(entry.key, entry.value, nullSafety));
      buffer.writeln();
    }
    return buffer.toString();
  }

  static void _collectSchema(
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

  static String _generateClass(
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

    buffer.writeln('  factory $className.fromJson(Map<String, dynamic> json) {');
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

  static bool _isCustomClass(String type) {
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

  static String _inferDartType(dynamic value) {
    if (value is String) return 'String';
    if (value is int) return 'int';
    if (value is double) return 'double';
    if (value is bool) return 'bool';
    if (value is List) return 'List<dynamic>';
    if (value is Map) return 'Map<String, dynamic>';
    return 'dynamic';
  }

  static String _capitalize(String s) =>
      s.isNotEmpty ? s[0].toUpperCase() + s.substring(1) : s;
}
