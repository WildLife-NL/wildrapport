import 'package:flutter/material.dart';

const double kMinTouchTargetHeight = 48.0;

double primaryButtonHeight(BuildContext context) {
  final h = MediaQuery.sizeOf(context).height;
  return (h * 0.065).clamp(kMinTouchTargetHeight, 56.0);
}

double menuButtonHeight(BuildContext context) {
  final h = MediaQuery.sizeOf(context).height;
  return (h * 0.07).clamp(kMinTouchTargetHeight, 64.0);
}

double buttonSpacing(BuildContext context) {
  final h = MediaQuery.sizeOf(context).height;
  return (h * 0.018).clamp(12.0, 20.0);
}

double contentHorizontalPadding(BuildContext context) {
  final w = MediaQuery.sizeOf(context).width;
  return (w * 0.05).clamp(16.0, 24.0);
}
