import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import 'learn_content_screen.dart';

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('LEARN', style: AppTextStyles.headline.copyWith(fontSize: 20)),
        backgroundColor: AppColors.black,
        elevation: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(2),
          child: Divider(color: AppColors.white, height: 2, thickness: 2),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          _buildLearnCard(context, 'BASICS', 'Learn how pieces move', '75%'),
          _buildLearnCard(context, 'OPENINGS', 'Master the first moves', '20%'),
          _buildLearnCard(context, 'TACTICS', 'Solve coordinate puzzles', '0%'),
          const SizedBox(height: 32),
          _buildResourceSection(context),
        ],
      ),
    );
  }

  Widget _buildLearnCard(BuildContext context, String title, String subtitle, String progress) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => LearnContentScreen(title: title, contentDescription: subtitle)));
        },
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.white, width: 2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.title.copyWith(fontSize: 18)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: AppTextStyles.bodySecondary),
                  ],
                ),
              ),
              Column(
                children: [
                  Text(progress, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
                  Text('DONE', style: AppTextStyles.bodySecondary.copyWith(fontSize: 10)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResourceSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('[ RESOURCES ]', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildResourceItem(context, 'CHESS NOTATION GUIDE', 'Learn standard algebraic notation'),
        _buildResourceItem(context, 'FAMOUS GAMES ANALYSIS', 'Deep dive into historical matches'),
        _buildResourceItem(context, 'ENDGAME PATTERNS', 'Master essential endgame techniques'),
      ],
    );
  }

  Widget _buildResourceItem(BuildContext context, String label, String description) {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => LearnContentScreen(title: label, contentDescription: description)));
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.gray, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTextStyles.bodySecondary),
            const Icon(Icons.chevron_right, color: AppColors.white, size: 16),
          ],
        ),
      ),
    );
  }
}
