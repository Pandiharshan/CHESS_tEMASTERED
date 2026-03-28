import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import 'vector_chess_pieces.dart';

class ChessTileFloor extends StatelessWidget {
  final bool isWhiteTile;
  final bool isSelected;
  final VoidCallback onTap;

  const ChessTileFloor({
    super.key,
    required this.isWhiteTile,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isWhiteTile ? AppColors.white : AppColors.black,
          border: Border.all(
            color: isSelected ? AppColors.gray : AppColors.white.withValues(alpha: 0.1),
            width: isSelected ? 4.0 : 1.0,
          ),
        ),
      ),
    );
  }
}

class ChessTilePieceInteraction extends StatefulWidget {
  final String? pieceType;
  final bool? isPieceWhite;
  final bool isSelected;

  const ChessTilePieceInteraction({
    super.key,
    required this.pieceType,
    required this.isPieceWhite,
    required this.isSelected,
  });

  @override
  State<ChessTilePieceInteraction> createState() => _ChessTilePieceInteractionState();
}

class _ChessTilePieceInteractionState extends State<ChessTilePieceInteraction> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    if (widget.isSelected) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(ChessTilePieceInteraction oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected && !oldWidget.isSelected) {
      _controller.repeat(reverse: true);
    } else if (!widget.isSelected && oldWidget.isSelected) {
      _controller.stop();
      _controller.value = 0.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        if (widget.isSelected && widget.pieceType == null)
          // Highlight possible move dot completely scaled out natively through the Z layout
          Center(
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
            ),
          ),
        if (widget.pieceType != null && widget.isPieceWhite != null)
          ScaleTransition(
            scale: _pulseAnimation,
            child: AspectRatio(
              aspectRatio: 1,
              child: ChessPiece(
                type: widget.pieceType!,
                isWhite: widget.isPieceWhite!,
                size: 40,
                isSelected: widget.isSelected,
              ),
            ),
          ),
      ],
    );
  }
}
