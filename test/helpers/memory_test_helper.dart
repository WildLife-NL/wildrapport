import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class MemoryTestHelper {
  static Future<int> measureMemoryUsage({
    required WidgetTester tester,
    required int cycles,
    required String testName,
    required Widget Function() buildWidget,
  }) async {
    final initialMemory = ProcessInfo.currentRss;
    
    for (int i = 1; i <= cycles; i++) {
      debugPrint('$testName - Cycle $i/$cycles');
      
      await tester.pumpWidget(buildWidget());
      await tester.pump();
      await Future.delayed(const Duration(milliseconds: 100));
      await tester.pump();
      
      await tester.pumpWidget(Container());
      await tester.pump();
      await Future.delayed(const Duration(milliseconds: 100));
      await tester.pump();
    }
    
    return ProcessInfo.currentRss - initialMemory;
  }
}


