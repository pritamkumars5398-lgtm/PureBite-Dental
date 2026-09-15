import 'package:flutter/material.dart';

import '../../../core/constants/app_breakpoints.dart';

enum WindowSizeClass { compact, medium, expanded }

WindowSizeClass windowSizeOf(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;
  if (width < AppBreakpoints.compact) return WindowSizeClass.compact;
  if (width < AppBreakpoints.medium) return WindowSizeClass.medium;
  return WindowSizeClass.expanded;
}
