import 'package:flutter/material.dart';

class CenteredColumn extends StatelessWidget {
  final List<Widget> children;
  final double spacing;

  const CenteredColumn({
    super.key,
    required this.children,
    this.spacing = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    final List<Widget> spacedChildren = [];
    for (int i = 0; i < children.length; i++) {
      spacedChildren.add(children[i]);
      if (i < children.length - 1) {
        spacedChildren.add(SizedBox(height: spacing));
      }
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: spacedChildren,
      ),
    );
  }
}
