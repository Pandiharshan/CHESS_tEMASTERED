import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

enum PieceType { pawn, knight, bishop, rook, queen, king }

class ChessPieceModel {
  final PieceType type;
  final bool isWhite;

  const ChessPieceModel({required this.type, required this.isWhite});

  String get unicode {
    if (isWhite) {
      switch (type) {
        case PieceType.king:   return '♔';
        case PieceType.queen:  return '♕';
        case PieceType.rook:   return '♖';
        case PieceType.bishop: return '♗';
        case PieceType.knight: return '♘';
        case PieceType.pawn:   return '♙';
      }
    } else {
      switch (type) {
        case PieceType.king:   return '♚';
        case PieceType.queen:  return '♛';
        case PieceType.rook:   return '♜';
        case PieceType.bishop: return '♝';
        case PieceType.knight: return '♞';
        case PieceType.pawn:   return '♟';
      }
    }
  }
}

class ChessPieceWidget extends StatelessWidget {
  final ChessPieceModel piece;
  final bool isSelected;

  const ChessPieceWidget({
    super.key,
    required this.piece,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: isSelected
          ? BoxDecoration(
              border: Border.all(color: AppColors.white, width: 3),
              color: AppColors.grey,
            )
          : null,
      child: FittedBox(
        fit: BoxFit.contain,
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Text(
            piece.unicode,
            style: TextStyle(
              fontSize: 40,
              color: piece.isWhite ? AppColors.white : AppColors.darkGrey,
              shadows: [
                Shadow(
                  color: piece.isWhite ? AppColors.black : AppColors.white,
                  blurRadius: 2,
                  offset: const Offset(1, 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
