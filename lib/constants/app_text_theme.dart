import 'package:flutter/material.dart';
import 'package:wildlifenl_map_ui_components/wildlifenl_map_ui_components.dart' show WildLifeNLTextTheme;

/// App text theme – forwards to [WildLifeNLTextTheme] from wildlifenl_map_ui_components.
class AppTextTheme {
  AppTextTheme._();

  static TextTheme get textTheme => WildLifeNLTextTheme.textTheme;
}
