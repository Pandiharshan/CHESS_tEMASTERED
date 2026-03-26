import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class TopBar extends StatelessWidget {
  final VoidCallback onBackPressed;
  final VoidCallback onSettingsPressed;

  const TopBar({
    super.key,
    required this.onBackPressed,
    required this.onSettingsPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: const BoxDecoration(
        color: AppColors.black,
        border: Border(
          bottom: BorderSide(color: AppColors.white, width: 2.0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: onBackPressed,
            child: const Text('<- BACK', style: AppTextStyles.buttonText),
          ),
          Text(
            'CHESS REMASTERED',
            style: AppTextStyles.title.copyWith(fontSize: 18, letterSpacing: 2.0),
          ),
          GestureDetector(
            onTap: onSettingsPressed,
            child: const Icon(Icons.settings, color: AppColors.white, size: 28),
          ),
        ],
      ),
    );
  }
}
