import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class ChessPiece extends StatelessWidget {
  final String pieceType; // 'K', 'Q', 'R', 'B', 'N', 'P'
  final bool isWhite;

  const ChessPiece({
    super.key,
    required this.pieceType,
    required this.isWhite,
  });

  // Returns the correct Unicode chess symbol
  String get _unicode {
    if (isWhite) {
      switch (pieceType) {
        case 'K': return '♔';
        case 'Q': return '♕';
        case 'R': return '♖';
        case 'B': return '♗';
        case 'N': return '♘';
        case 'P': return '♙';
      }
    } else {
      switch (pieceType) {
        case 'K': return '♚';
        case 'Q': return '♛';
        case 'R': return '♜';
        case 'B': return '♝';
        case 'N': return '♞';
        case 'P': return '♟';
      }
    }
    return '?';
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double fontSize = constraints.maxWidth * 0.72;
        return Stack(
          alignment: Alignment.center,
          children: [
            // Drop shadow for depth (slightly larger, black text behind)
            Text(
              _unicode,
              style: TextStyle(
                fontSize: fontSize,
                color: isWhite ? AppColors.black : AppColors.black,
                height: 1.0,
              ),
              textAlign: TextAlign.center,
            ),
            // Actual piece colored on top
            Text(
              _unicode,
              style: TextStyle(
                fontSize: fontSize * 0.95,
                color: isWhite ? AppColors.white : AppColors.darkGrey,
                height: 1.0,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        );
      },
    );
  }
}
