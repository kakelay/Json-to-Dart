import 'package:flutter/material.dart';
import 'package:json_convert_dart/widgets/app_color.dart';
import 'pages/json_to_dart_page.dart';

class JsonToDartApp extends StatefulWidget {
  @override
  _JsonToDartAppState createState() => _JsonToDartAppState();
}

class _JsonToDartAppState extends State<JsonToDartApp> {
  bool _isDarkMode = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      color: AppColors.appColor,
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
