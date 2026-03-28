import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class OpeningExplorerScreen extends StatelessWidget {
  const OpeningExplorerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('OPENING EXPLORER', style: AppTextStyles.headline.copyWith(fontSize: 20)),
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
              const Icon(Icons.menu_book, color: AppColors.white, size: 64),
              const SizedBox(height: 24),
              Text(
                'DATABASE OF OPENINGS',
                style: AppTextStyles.title,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Explore classic openings and variations here.',
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
