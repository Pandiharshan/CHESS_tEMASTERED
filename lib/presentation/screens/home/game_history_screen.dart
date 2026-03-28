import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class GameHistoryScreen extends StatelessWidget {
  const GameHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('GAME HISTORY', style: AppTextStyles.headline.copyWith(fontSize: 20)),
        backgroundColor: AppColors.black,
        elevation: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(2),
          child: Divider(color: AppColors.white, height: 2, thickness: 2),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.history, color: AppColors.white, size: 64),
              const SizedBox(height: 24),
              Text(
                'NO RECENT GAMES FOUND',
                style: AppTextStyles.title,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Play a match to see your history here.',
                style: AppTextStyles.bodySecondary,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
