import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/common/primary_button.dart';
import '../../widgets/common/title_text.dart';
import '../../widgets/layout/centered_column.dart';
import '../game/game_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CenteredColumn(
          spacing: 60.0,
          children: [
            const TitleText(title: 'CHESS\nREMASTERED'),
            CenteredColumn(
              spacing: 24.0,
              children: [
                PrimaryButton(
                  text: 'Start Game',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const GameScreen()),
                    );
                  },
                ),
                PrimaryButton(
                  text: 'Settings',
                  onPressed: () {
                    // Navigate to Settings Screen (placeholder)
                    _showPlaceholderDialog(context, 'Settings Screen');
                  },
                ),
                PrimaryButton(
                  text: 'Exit',
                  onPressed: () {
                    // Handle Exit
                    _showPlaceholderDialog(context, 'Exiting Game...');
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showPlaceholderDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.black,
        shape: const RoundedRectangleBorder(
          side: BorderSide(color: AppColors.white, width: 2.0),
          borderRadius: BorderRadius.zero,
        ),
        title: Text(
          message,
          style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        actions: [
          PrimaryButton(
            text: 'OK',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
