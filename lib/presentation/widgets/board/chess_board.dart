import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/logic/chess_piece_model.dart';

// The full 8x8 board grid as a flat 64-slot map
List<ChessPieceModel?> buildInitialBoard() {
  List<ChessPieceModel?> board = List.filled(64, null);

  void place(int index, PieceType type, bool isWhite) {
    board[index] = ChessPieceModel(type: type, isWhite: isWhite);
  }

  // --- Black pieces (top) ---
  place(0, PieceType.rook,   false); place(1, PieceType.knight, false);
  place(2, PieceType.bishop, false); place(3, PieceType.queen,  false);
  place(4, PieceType.king,   false); place(5, PieceType.bishop, false);
  place(6, PieceType.knight, false); place(7, PieceType.rook,   false);
  for (int c = 0; c < 8; c++) { place(8 + c, PieceType.pawn, false); }

  // --- White pieces (bottom) ---
  for (int c = 0; c < 8; c++) { place(48 + c, PieceType.pawn, true); }
  place(56, PieceType.rook,   true); place(57, PieceType.knight, true);
  place(58, PieceType.bishop, true); place(59, PieceType.queen,  true);
  place(60, PieceType.king,   true); place(61, PieceType.bishop, true);
  place(62, PieceType.knight, true); place(63, PieceType.rook,   true);

  return board;
}

class ChessBoard extends StatefulWidget {
  final ValueChanged<bool>? onTurnChanged;

  const ChessBoard({super.key, this.onTurnChanged});

  @override
  State<ChessBoard> createState() => _ChessBoardState();
}

class _ChessBoardState extends State<ChessBoard> {
  late List<ChessPieceModel?> _board;
  int? _selectedIndex;
  bool _isWhiteTurn = true; // white always goes first

  @override
  void initState() {
    super.initState();
    _board = buildInitialBoard();
  }

  void _handleTap(int index) {
    setState(() {
      final ChessPieceModel? tapped = _board[index];

      if (_selectedIndex == null) {
        // Only select a piece that belongs to the current turn
        if (tapped != null && tapped.isWhite == _isWhiteTurn) {
          _selectedIndex = index;
        }
      } else {
        final ChessPieceModel? selected = _board[_selectedIndex!];

        if (_selectedIndex == index) {
          // Deselect
          _selectedIndex = null;
        } else if (tapped != null && tapped.isWhite == selected!.isWhite) {
          // Switch selection to another own piece
          _selectedIndex = index;
        } else {
          // Execute move (capture or empty square)
          _board[index] = _board[_selectedIndex!];
          _board[_selectedIndex!] = null;
          _selectedIndex = null;
          _isWhiteTurn = !_isWhiteTurn;
          // Notify parent of turn change
          widget.onTurnChanged?.call(_isWhiteTurn);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: AppColors.white.withValues(alpha: 0.1),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 64,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 8,
          ),
          itemBuilder: (context, index) {
            final int row = index ~/ 8;
            final int col = index % 8;
            final bool isWhiteTile = (row + col) % 2 == 0;
            final ChessPieceModel? piece = _board[index];
            final bool isSelected = _selectedIndex == index;

            return GestureDetector(
              onTap: () => _handleTap(index),
              child: Container(
                color: isSelected
                    ? AppColors.grey
                    : (isWhiteTile ? AppColors.white : AppColors.black),
                child: piece != null
                    ? ChessPieceWidget(piece: piece, isSelected: isSelected)
                    : null,
              ),
            );
          },
        ),
      ),
    );
  }
}
