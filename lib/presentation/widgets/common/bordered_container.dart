import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class BorderedContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const BorderedContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(
          color: AppColors.border,
          width: 2.0,
        ),
        borderRadius: BorderRadius.zero,
      ),
      child: child,
    );
  }
}
