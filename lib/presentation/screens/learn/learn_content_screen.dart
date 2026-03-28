import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class LearnContentScreen extends StatelessWidget {
  final String title;
  final String contentDescription;

  const LearnContentScreen({
    super.key,
    required this.title,
    required this.contentDescription,
  });

  String _getLessonContent(String title) {
    if (title.contains('ROOK')) {
      return 'The Rook moves horizontally or vertically, through any number of unoccupied squares. It is a major piece, valued at 5 points. Together with the King, it can perform castles.';
    } else if (title.contains('KNIGHT')) {
      return 'The Knight moves in an "L" shape: two squares in one direction and one square orthogonally. It is the only piece that can jump over other pieces. Valued at 3 points.';
    } else if (title.contains('BISHOP')) {
      return 'The Bishop moves diagonally through any number of unoccupied squares. Each Bishop is restricted to the color of square it starts on (light-squared and dark-squared). Valued at 3 points.';
    } else if (title.contains('QUEEN')) {
      return 'The Queen is the most powerful piece, combining the powers of the Rook and Bishop. It moves horizontally, vertically, or diagonally. Valued at 9 points.';
    } else if (title.contains('KING')) {
      return 'The King moves one square in any direction. The objective of the game is to checkmate the opponent\'s King while keeping yours safe. Cannot move into check.';
    } else if (title.contains('PAWN')) {
      return 'Pawns move forward one square, but capture diagonally. On their first move, they may advance two squares. If a pawn reaches the opposite end of the board, it promotes to any other piece.';
    } else if (title.contains('NOTATION')) {
      return 'Chess notation uses a grid system. Columns are files (a-h) and rows are ranks (1-8).\n\nN = Knight\nB = Bishop\nR = Rook\nQ = Queen\nK = King\n\nx = capture\n+ = check\n# = checkmate\nO-O = King-side castle';
    } else if (title.contains('FAMOUS')) {
      return 'The "Game of the Century"\nDonald Byrne vs Bobby Fischer (13 yrs old), 1956.\n\nA brilliant display of tactical foresight where Fischer sacrificed his Queen to unleash an unstoppable windmill attack using his Bishop and Knight.';
    } else if (title.contains('ENDGAME')) {
      return 'The most essential endgames:\n\n1. King + Queen vs King\n2. King + Rook vs King\n3. King + Pawn vs King (Rule of the Square)\n\nLearn opposition and outflanking to convert winning advantages.';
    }
    return contentDescription;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(title, style: AppTextStyles.headline.copyWith(fontSize: 20)),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('[ LESSON MANUAL ]', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Text(title, style: AppTextStyles.title),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.white, width: 2),
                color: AppColors.white.withValues(alpha: 0.05),
              ),
              child: Text(
                _getLessonContent(title),
                style: AppTextStyles.bodySecondary.copyWith(height: 1.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

