import 'package:flutter/material.dart';

abstract class NavigationStateInterface {
  void dispose();

  void resetToHome(BuildContext context);

  void clearApplicationState(BuildContext context);

  void pushAndRemoveUntil(BuildContext context, Widget screen);

  void pushReplacementForward(BuildContext context, Widget screen);

  void pushReplacementBack(BuildContext context, Widget screen);

  void pushForward(BuildContext context, Widget screen);
}
