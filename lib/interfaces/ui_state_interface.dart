import 'package:flutter/material.dart';

abstract class UIStateInterface {
  bool get hasWindowFocus;
  void setScreenState(String screenName, String key, dynamic value);
  T? getScreenState<T>(String screenName, String key);
  void registerScreen(BuildContext context);
  void unregisterScreen(BuildContext context);
  void setWindowFocus(bool focus);
}