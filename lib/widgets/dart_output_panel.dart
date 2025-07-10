import 'package:flutter/material.dart';

class DartOutputPanel extends StatelessWidget {
  final String dartCode;
  final VoidCallback onCopy;

  const DartOutputPanel({
    required this.dartCode,
    required this.onCopy,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Dart Model Output:'),
              IconButton(
                icon: const Icon(Icons.copy),
                onPressed: dartCode.isEmpty ? null : onCopy,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).dividerColor),
                borderRadius: BorderRadius.circular(4),
              ),
              child: SingleChildScrollView(
                child: SelectableText(
                  dartCode.isEmpty
                      ? 'Your Dart model will appear here...'
                      : dartCode,
                  style: const TextStyle(fontFamily: 'Courier'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
