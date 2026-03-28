import 'package:flutter/material.dart';

class ChessPieceWidget extends StatelessWidget {
  final String pieceType; // 'p', 'r', 'n', 'b', 'q', 'k'
  final bool isWhite;
  final double size;
  final int row; // Used for depth scaling 0 (top) to 7 (bottom)
  
  const ChessPieceWidget({
    super.key,
    required this.pieceType,
    required this.isWhite,
    required this.size,
    required this.row,
  });

  @override
  Widget build(BuildContext context) {
    if (pieceType.isEmpty) return const SizedBox.shrink();

    // Map piece letter to filename
    String name = '';
    switch (pieceType.toLowerCase()) {
      case 'p': name = 'pawn'; break;
      case 'r': name = 'rook'; break;
      case 'n': name = 'knight'; break;
      case 'b': name = 'bishop'; break;
      case 'q': name = 'queen'; break;
      case 'k': name = 'king'; break;
    }
    
    if (name.isEmpty) return const SizedBox.shrink();
    
    String colorStr = isWhite ? 'white' : 'black';
    String assetPath = 'assets/pieces/${name}_$colorStr.png';

    // Scale pieces based on row to enhance perspective depth
    // Top row (0) = 0.7x, Bottom row (7) = 1.2x
    double depthScale = 0.7 + (row / 7) * 0.5;
    double actualSize = size * depthScale;

    // Apply strict monochrome visual outlines depending on piece color and row depth
    return SizedBox(
      width: actualSize,
      height: actualSize,
      child: Image.asset(
        assetPath,
        filterQuality: FilterQuality.none,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          // Fallback if the user hasn't successfully generated the PNGs yet
          return Container(
            alignment: Alignment.center,
            child: Text(
              isWhite ? pieceType.toUpperCase() : pieceType.toLowerCase(),
              style: TextStyle(
                color: isWhite ? Colors.white : Colors.black,
                fontSize: actualSize * 0.6,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    offset: const Offset(1, 1),
                    blurRadius: 0,
                    color: isWhite ? Colors.black : Colors.white,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
