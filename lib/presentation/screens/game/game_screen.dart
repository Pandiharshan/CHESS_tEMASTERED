import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../home/home_screen.dart';
import '../../widgets/game/top_bar.dart';
import '../../widgets/board/chess_board.dart';
import '../../widgets/common/primary_button.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  // Key forces ChessBoard to fully rebuild on restart
  Key _boardKey = UniqueKey();
  bool _isWhiteTurn = true;

  void _restart() {
    setState(() {
      _boardKey = UniqueKey();
      _isWhiteTurn = true;
    });
  }

  void _onTurnChanged(bool isWhiteTurn) {
    setState(() => _isWhiteTurn = isWhiteTurn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            TopBar(
              onBackPressed: () => Navigator.of(context).pop(),
              onSettingsPressed: () => _showDialog(context, 'SETTINGS'),
            ),

            // Board Area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
                child: ChessBoard(
                  key: _boardKey,
                  onTurnChanged: _onTurnChanged,
                ),
              ),
            ),

            // Bottom Control
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: const BoxDecoration(
                color: AppColors.black,
                border: Border(top: BorderSide(color: AppColors.white, width: 2.0)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Turn indicator
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.white, width: 1.0),
                    ),
                    child: Text(
                      _isWhiteTurn ? '♔  WHITE\'S TURN' : '♚  BLACK\'S TURN',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.buttonText.copyWith(letterSpacing: 3.0),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: PrimaryButton(text: 'Restart', onPressed: _restart),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: PrimaryButton(
                          text: 'Exit',
                          onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (_) => const HomeScreen()),
                            (route) => false,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDialog(BuildContext context, String message) {
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
