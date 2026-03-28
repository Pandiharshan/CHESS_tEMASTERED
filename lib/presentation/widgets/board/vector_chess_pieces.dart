import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

// Helper to get the painter based on standard chess notation
CustomPainter getPainterForPiece(String type, bool isWhite) {
  return VectorChessPiecePainter(
    pieceType: type,
    isWhite: isWhite,
  );
}

class ChessPiece extends StatelessWidget {
  final String type; // pawn, rook, knight, bishop, queen, king
  final bool isWhite;
  final double size;
  final bool isSelected; // Added for selection

  const ChessPiece({
    super.key, 
    required this.type, 
    required this.isWhite, 
    required this.size,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    if (type.toLowerCase() == 'p') {
      return SizedBox(
        width: size,
        height: size,
        // The user must place 'assets/pawn.glb' exported from Blender
        child: ModelViewer(
          src: 'assets/pawn.glb',
          alt: "Pawn Soldier",
          autoRotate: true,
          cameraControls: false,
          ar: false,
          disableZoom: true,
          disablePan: true,
          backgroundColor: Colors.transparent,
        ),
      );
    }

    return Container(
      decoration: const BoxDecoration(
        color: Colors.transparent, // Ensure container itself is transparent
      ),
      width: size,
      height: size,
      child: CustomPaint(
        size: Size(size, size),
        painter: getPainterForPiece(type, isWhite),
      ),
    );
  }
}

class VectorChessPiecePainter extends CustomPainter {
  final String pieceType;
  final bool isWhite;

  VectorChessPiecePainter({
    required this.pieceType,
    required this.isWhite,
  });

  Path _getPath(String type, double w, double h) {
    Path path = Path();
    switch (type.toLowerCase()) {
      case 'p':
        path.addOval(Rect.fromCircle(center: Offset(w * 0.5, h * 0.35), radius: w * 0.15));
        path.addRect(Rect.fromLTWH(w * 0.35, h * 0.5, w * 0.3, h * 0.05));
        path.moveTo(w * 0.45, h * 0.55);
        path.lineTo(w * 0.35, h * 0.85);
        path.lineTo(w * 0.65, h * 0.85);
        path.lineTo(w * 0.55, h * 0.55);
        path.close();
        path.addRect(Rect.fromLTWH(w * 0.25, h * 0.85, w * 0.5, h * 0.1));
        break;
      case 'r':
        path.addRect(Rect.fromLTWH(w * 0.2, h * 0.85, w * 0.6, h * 0.1));
        path.addRect(Rect.fromLTWH(w * 0.25, h * 0.35, w * 0.5, h * 0.5));
        path.addRect(Rect.fromLTWH(w * 0.2, h * 0.2, w * 0.6, h * 0.15));
        path.addRect(Rect.fromLTWH(w * 0.2, h * 0.1, w * 0.15, h * 0.1));
        path.addRect(Rect.fromLTWH(w * 0.425, h * 0.1, w * 0.15, h * 0.1));
        path.addRect(Rect.fromLTWH(w * 0.65, h * 0.1, w * 0.15, h * 0.1));
        break;
      case 'n':
        path.addRect(Rect.fromLTWH(w * 0.25, h * 0.85, w * 0.5, h * 0.1));
        path.moveTo(w * 0.3, h * 0.85);
        path.lineTo(w * 0.7, h * 0.85);
        path.lineTo(w * 0.7, h * 0.4);
        path.lineTo(w * 0.6, h * 0.2);
        path.lineTo(w * 0.25, h * 0.4);
        path.lineTo(w * 0.3, h * 0.5);
        path.lineTo(w * 0.4, h * 0.5);
        path.lineTo(w * 0.35, h * 0.85);
        path.close();
        break;
      case 'b':
        path.addRect(Rect.fromLTWH(w * 0.25, h * 0.85, w * 0.5, h * 0.1));
        path.moveTo(w * 0.3, h * 0.85);
        path.lineTo(w * 0.7, h * 0.85);
        path.lineTo(w * 0.55, h * 0.45);
        path.lineTo(w * 0.45, h * 0.45);
        path.close();
        path.addRect(Rect.fromLTWH(w * 0.35, h * 0.4, w * 0.3, h * 0.05));
        path.moveTo(w * 0.35, h * 0.4);
        path.lineTo(w * 0.65, h * 0.4);
        path.lineTo(w * 0.5, h * 0.1);
        path.close();
        break;
      case 'q':
        path.addRect(Rect.fromLTWH(w * 0.25, h * 0.85, w * 0.5, h * 0.1));
        path.moveTo(w * 0.3, h * 0.85);
        path.lineTo(w * 0.7, h * 0.85);
        path.lineTo(w * 0.6, h * 0.35);
        path.lineTo(w * 0.4, h * 0.35);
        path.close();
        path.addRect(Rect.fromLTWH(w * 0.35, h * 0.3, w * 0.3, h * 0.05));
        path.moveTo(w * 0.35, h * 0.3);
        path.lineTo(w * 0.15, h * 0.1);
        path.lineTo(w * 0.4, h * 0.2);
        path.lineTo(w * 0.5, h * 0.05);
        path.lineTo(w * 0.6, h * 0.2);
        path.lineTo(w * 0.85, h * 0.1);
        path.lineTo(w * 0.65, h * 0.3);
        path.close();
        break;
      case 'k':
        path.addRect(Rect.fromLTWH(w * 0.25, h * 0.85, w * 0.5, h * 0.1));
        path.moveTo(w * 0.3, h * 0.85);
        path.lineTo(w * 0.7, h * 0.85);
        path.lineTo(w * 0.65, h * 0.4);
        path.lineTo(w * 0.35, h * 0.4);
        path.close();
        path.addRect(Rect.fromLTWH(w * 0.3, h * 0.35, w * 0.4, h * 0.05));
        path.addRect(Rect.fromLTWH(w * 0.35, h * 0.2, w * 0.3, h * 0.15));
        path.addRect(Rect.fromLTWH(w * 0.475, h * 0.05, w * 0.05, h * 0.15));
        path.addRect(Rect.fromLTWH(w * 0.4, h * 0.1, w * 0.2, h * 0.05));
        break;
    }
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    double w = size.width;
    double h = size.height;
    Path path = _getPath(pieceType, w, h);

    // 1-bit Macintosh styling: Solid drop shadow for critical depth separation
    Path shadowPath = path.shift(const Offset(2.0, 3.0));
    Paint shadowPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.black;
    canvas.drawPath(shadowPath, shadowPaint);

    Paint shadowOutline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeJoin = StrokeJoin.round
      ..color = Colors.black;
    canvas.drawPath(shadowPath, shadowOutline);

    Paint fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = isWhite ? Colors.white : Colors.black;

    // A white outline ensures contrast even on black drop-shadows
    Paint strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeJoin = StrokeJoin.round
      ..color = isWhite ? Colors.black : Colors.white;

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);

    // Extra details to clarify shape
    Paint detailPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = isWhite ? Colors.black : Colors.white;

    if (pieceType.toLowerCase() == 'b') {
      canvas.drawLine(Offset(w * 0.5, h * 0.1), Offset(w * 0.5, h * 0.35), detailPaint);
    } else if (pieceType.toLowerCase() == 'n') {
      canvas.drawCircle(Offset(w * 0.4, h * 0.3), w * 0.04, detailPaint);
    } else if (pieceType.toLowerCase() == 'p') {
      canvas.drawLine(Offset(w * 0.35, h * 0.525), Offset(w * 0.65, h*0.525), detailPaint);
    }
  }

  @override
  bool shouldRepaint(covariant VectorChessPiecePainter oldDelegate) {
    return oldDelegate.pieceType != pieceType ||
        oldDelegate.isWhite != isWhite;
  }
}
