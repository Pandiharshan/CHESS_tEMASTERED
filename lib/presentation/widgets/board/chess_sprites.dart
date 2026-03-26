import 'package:flutter/material.dart';

class ChessSprites {
  static const List<String> pawn = [
    '                ',
    '      XXXX      ',
    '     XXXXXX     ',
    '     XXXXXX     ',
    '      XXXX      ',
    '       XX       ',
    '      XXXX      ',
    '     XXXXXX     ',
    '     XXXXXX     ',
    '     XXXXXX     ',
    '    XXXXXXXX    ',
    '   XXXXXXXXXX   ',
    '  XXXXXXXXXXXX  ',
    ' XXXXXXXXXXXXXX ',
    '                ',
    '                ',
  ];

  static const List<String> knight = [
    '                ',
    '      XXXXX     ',
    '    XXXXXXXX    ',
    '   XXXXXXXXXX   ',
    '  XXXXX XXXXX   ',
    ' XXXXXXXXXXXXX  ',
    ' XXXXXXXXXXXX   ',
    '  XXXXXXXXXXXX  ',
    '    XXXXXXXXXXX ',
    '     XXXXXXXXXX ',
    '     XXXXXXXXXX ',
    '    XXXXXXXXXXXX',
    '   XXXXXXXXXXXXX',
    '  XXXXXXXXXXXXXX',
    '                ',
    '                ',
  ];

  static const List<String> bishop = [
    '                ',
    '       XX       ',
    '      XXXX      ',
    '     XX XX      ',
    '     XXXXXX     ',
    '      XXXX      ',
    '       XX       ',
    '      XXXX      ',
    '     XXXXXX     ',
    '     XXXXXX     ',
    '    XXXXXXXX    ',
    '   XXXXXXXXXX   ',
    '  XXXXXXXXXXXX  ',
    ' XXXXXXXXXXXXXX ',
    '                ',
    '                ',
  ];

  static const List<String> rook = [
    '                ',
    '   XX  XX  XX   ',
    '   XXXXXXXXXX   ',
    '    XXXXXXXX    ',
    '    XXXXXXXX    ',
    '     XXXXXX     ',
    '     XXXXXX     ',
    '     XXXXXX     ',
    '     XXXXXX     ',
    '    XXXXXXXX    ',
    '   XXXXXXXXXX   ',
    '  XXXXXXXXXXXX  ',
    ' XXXXXXXXXXXXXX ',
    ' XXXXXXXXXXXXXX ',
    '                ',
    '                ',
  ];

  static const List<String> queen = [
    '                ',
    '   X   XX   X   ',
    '   X   XX   X   ',
    '   XX XXXX XX   ',
    '   XXXXXXXXXX   ',
    '    XXXXXXXX    ',
    '     XXXXXX     ',
    '     XXXXXX     ',
    '    XXXXXXXX    ',
    '    XXXXXXXX    ',
    '   XXXXXXXXXX   ',
    '  XXXXXXXXXXXX  ',
    ' XXXXXXXXXXXXXX ',
    ' XXXXXXXXXXXXXX ',
    '                ',
    '                ',
  ];

  static const List<String> king = [
    '                ',
    '       XX       ',
    '     XXXXXX     ',
    '       XX       ',
    '   X  XXXX  X   ',
    '   XXXXXXXXXX   ',
    '    XXXXXXXX    ',
    '     XXXXXX     ',
    '     XXXXXX     ',
    '    XXXXXXXX    ',
    '    XXXXXXXX    ',
    '   XXXXXXXXXX   ',
    '  XXXXXXXXXXXX  ',
    ' XXXXXXXXXXXXXX ',
    '                ',
    '                ',
  ];

  static List<String> getSprite(String pieceType) {
    switch (pieceType.toUpperCase()) {
      case 'P': return pawn;
      case 'N': return knight;
      case 'B': return bishop;
      case 'R': return rook;
      case 'Q': return queen;
      case 'K': return king;
      default: return pawn;
    }
  }
}

class PixelSpritePainter extends CustomPainter {
  final List<String> sprite;
  final Color fillColor;
  final Color outlineColor;

  PixelSpritePainter({
    required this.sprite,
    required this.fillColor,
    required this.outlineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (sprite.isEmpty) return;
    int rows = sprite.length;
    int cols = sprite[0].length;
    double pixelWidth = size.width / cols;
    double pixelHeight = size.height / rows;

    Paint fillPaint = Paint()..color = fillColor..style = PaintingStyle.fill;
    Paint outlinePaint = Paint()..color = outlineColor..style = PaintingStyle.fill;

    for (int y = 0; y < rows; y++) {
      for (int x = 0; x < cols; x++) {
        if (sprite[y][x] == 'X') {
          canvas.drawRect(
            Rect.fromLTWH(x * pixelWidth, y * pixelHeight, pixelWidth, pixelHeight),
            fillPaint,
          );
        } else {
          // Check adjacent for outline rendering giving retro depth
          bool hasAdjacent = false;
          for (int dy = -1; dy <= 1; dy++) {
            for (int dx = -1; dx <= 1; dx++) {
              if (dy == 0 && dx == 0) continue;
              int ny = y + dy;
              int nx = x + dx;
              if (ny >= 0 && ny < rows && nx >= 0 && nx < cols && sprite[ny][nx] == 'X') {
                hasAdjacent = true;
                break;
              }
            }
            if (hasAdjacent) break;
          }
          if (hasAdjacent) {
            canvas.drawRect(
              Rect.fromLTWH(x * pixelWidth, y * pixelHeight, pixelWidth, pixelHeight),
              outlinePaint,
            );
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant PixelSpritePainter oldDelegate) {
    return oldDelegate.fillColor != fillColor ||
           oldDelegate.outlineColor != outlineColor ||
           oldDelegate.sprite != sprite;
  }
}
