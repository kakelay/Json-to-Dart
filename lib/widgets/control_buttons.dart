import 'package:flutter/material.dart';
import 'package:json_convert_dart/widgets/app_color.dart';
import 'package:json_convert_dart/widgets/app_style.dart';
import 'package:json_convert_dart/widgets/rounded_button.dart';

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
          child: RoundedButton(
            text: 'Convet Json to Dart',
            onPress: onConvert,
            borderRadius: AppStyle.SPACING_24,
          ),
        ),
        const SizedBox(width: AppStyle.SPACING_8),

        RoundedButton(
          text: 'Clear Text',
          onPress: onClear,
          borderRadius: AppStyle.SPACING_24,
          weight: FontWeight.w100
        
        ),
        const SizedBox(width: AppStyle.SPACING_8),

        RoundedButton(
          text: 'Load Sample',
          onPress: onLoadSample,
          borderRadius: AppStyle.SPACING_24,
          weight: FontWeight.w100
        ),
      ],
    );
  }
}
