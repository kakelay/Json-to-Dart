import 'package:flutter/material.dart';
import 'package:json_convert_dart/widgets/app_color.dart';

Text TextWidget(
  String text, {
  double fontSize = 14,
  FontWeight weight = FontWeight.normal,
  Color? color,
  TextAlign align = TextAlign.left,
}) {
  color ??= AppColors.black1D1D23;
  return Text(
    text,
    textAlign: align,
    style: TextStyle(
      fontSize: fontSize,
      color: color,
      fontWeight: weight,
    ),
  );
}