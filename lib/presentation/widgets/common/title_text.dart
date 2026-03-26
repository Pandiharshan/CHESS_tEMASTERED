import 'package:flutter/material.dart';
import '../../../core/constants/app_text_styles.dart';

class TitleText extends StatelessWidget {
  final String title;

  const TitleText({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTextStyles.title,
      textAlign: TextAlign.center,
    );
  }
}
