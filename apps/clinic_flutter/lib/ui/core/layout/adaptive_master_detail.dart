import 'package:flutter/material.dart';

import '../../../core/constants/app_breakpoints.dart';
import '../../../core/constants/app_spacing.dart';

class AdaptiveMasterDetail extends StatelessWidget {
  const AdaptiveMasterDetail({
    super.key,
    required this.master,
    required this.detail,
    required this.showDetail,
  });

  final Widget master;
  final Widget detail;
  final bool showDetail;

  @override
  Widget build(BuildContext context) {
    final wide =
        MediaQuery.sizeOf(context).width >= AppBreakpoints.compact;
    if (!wide) {
      return showDetail ? detail : master;
    }
    return Row(
      children: [
        SizedBox(width: 360, child: master),
        const VerticalDivider(width: 1),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: detail,
          ),
        ),
      ],
    );
  }
}
