import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import 'vector_chess_pieces.dart';

class PerspectiveBoard extends StatefulWidget {
  const PerspectiveBoard({super.key});

  @override
  State<PerspectiveBoard> createState() => _PerspectiveBoardState();
}

class _PerspectiveBoardState extends State<PerspectiveBoard> {
  // Simple board state for UI only
  final List<String?> _board = List.generate(64, (index) {
    if (index < 16 || index >= 48) return 'P'; // Just placeholders
    return null;
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        child: AspectRatio(
          aspectRatio: 1,
          child: Stack(
            children: [
              // The Board Tiles with perspective
              Transform.scale(
                scale: 0.85, // Prevent bounding box corner clipping
                child: Transform(
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.0015) // Perspective effect
                    ..rotateX(-0.6), // Tilt back (~35 degrees)
                  alignment: FractionalOffset.center,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.white.withValues(alpha: 0.1),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 8,
                      ),
                      itemCount: 64,
                      itemBuilder: (context, index) {
                        final row = index ~/ 8;
                        final col = index % 8;
                        final isLight = (row + col) % 2 == 0;
                        
                        return Container(
                          decoration: BoxDecoration(
                            color: isLight ? AppColors.white : AppColors.black,
                            border: Border.all(color: isLight ? AppColors.black : AppColors.white, width: 0.5),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              
              // The Pieces (positioned over the board tiles)
              // NOTE: In a real app, you'd calculate the 2D position for each 3D tile center.
              // For UI only, we'll overlay them in a way that respects the perspective visually.
              IgnorePointer(
                child: _buildPiecesLayer(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPiecesLayer() {
    // This is a simplified layer. In a full implementation, you'd use a Stack 
    // and Positioned widgets with coordinates derived from the perspective transform.
    return Transform.scale(
      scale: 0.85, // Prevent clipping bounds
      child: Transform(
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.0015)
          ..rotateX(-0.6),
        alignment: FractionalOffset.center,
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 8,
          ),
          itemCount: 64,
          itemBuilder: (context, index) {
            final row = index ~/ 8;
            final piece = _board[index];
            if (piece == null) return const SizedBox();
            
            // Pieces need to "stand up", so we rotate them back relative to the board
            return Transform(
              transform: Matrix4.identity()..rotateX(0.6), 
              alignment: FractionalOffset.bottomCenter,
              child: BattleChessPiece(
                type: _getPieceTypeForIndex(index),
                isWhite: index >= 48,
                row: row,
              ),
            );
          },
        ),
      ),
    );
  }

  String _getPieceTypeForIndex(int index) {
    int col = index % 8;
    if (index >= 8 && index < 16) return 'p';
    if (index >= 48 && index < 56) return 'p';
    if (col == 0 || col == 7) return 'r';
    if (col == 1 || col == 6) return 'n';
    if (col == 2 || col == 5) return 'b';
    if (col == 3) return 'q';
    return 'k';
  }
}

class BattleChessPiece extends StatelessWidget {
  final String type;
  final bool isWhite;
  final int row;

  const BattleChessPiece({
    super.key,
    required this.type,
    required this.isWhite,
    required this.row,
  });

  @override
  Widget build(BuildContext context) {
    // Scale pieces based on row to simulate depth
    double scale = 0.8 + (row * 0.05); 
    
    return Transform.scale(
      scale: scale,
      alignment: Alignment.bottomCenter,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: ChessPiece(
                type: type,
                isWhite: isWhite,
                size: 40,
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
