import 'package:flutter/material.dart';

class ControlButtons extends StatelessWidget {
  final VoidCallback onConvert;
  final VoidCallback onClear;
  final VoidCallback onLoadSample;

  const ControlButtons({
    required this.onConvert,
    required this.onClear,
    required this.onLoadSample,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: onConvert,
            child: const Text('Convert'),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: onClear,
          child: const Text('Clear'),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: onLoadSample,
          child: const Text('Load Sample'),
        ),
      ],
    );
  }
}
