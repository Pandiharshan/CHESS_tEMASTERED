import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../widgets/common/primary_button.dart';

class BottomPanel extends StatelessWidget {
  final VoidCallback onRestart;
  final VoidCallback onExit;
  final String currentTurn;

  const BottomPanel({
    super.key,
    required this.onRestart,
    required this.onExit,
    this.currentTurn = 'WHITE TURN',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      color: AppColors.black,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            currentTurn,
            style: AppTextStyles.title.copyWith(fontSize: 24, letterSpacing: 4.0),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: PrimaryButton(
                  text: 'Restart',
                  onPressed: onRestart,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: PrimaryButton(
                  text: 'Exit',
                  onPressed: onExit,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
