import 'package:flutter/material.dart';

class JsonInputPanel extends StatelessWidget {
  final TextEditingController controller;

  const JsonInputPanel({required this.controller, super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Paste your JSON here:'),
          const SizedBox(height: 8),
          Expanded(
            child: TextField(
              controller: controller,
              maxLines: null,
              expands: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: '{ "name": "John", "age": 30 }',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
