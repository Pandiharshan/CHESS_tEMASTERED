import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:chess_remastered/presentation/widgets/board/chess_sprites.dart';
import 'package:chess_remastered/core/constants/app_colors.dart';

void main() {
  testWidgets('Generate Chess Piece PNGs', (WidgetTester tester) async {
    final directory = Directory('assets/pieces');
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    final pieces = {
      'pawn': 'p',
      'rook': 'r',
      'knight': 'n',
      'bishop': 'b',
      'queen': 'q',
      'king': 'k',
    };

    for (var entry in pieces.entries) {
      final String name = entry.key;
      final String type = entry.value;

      for (bool isWhite in [true, false]) {
        final Color fillColor = isWhite ? AppColors.white : AppColors.black;
        final Color outlineColor = isWhite ? AppColors.black : AppColors.white;

        final ui.PictureRecorder recorder = ui.PictureRecorder();
        final Canvas canvas = Canvas(recorder);
        final Size size = const Size(40, 40);

        final painter = PixelSpritePainter(
          sprite: ChessSprites.getSprite(type),
          fillColor: fillColor,
          outlineColor: outlineColor,
        );

        painter.paint(canvas, size);

        final ui.Picture picture = recorder.endRecording();
        final ui.Image image = await picture.toImage(size.width.toInt(), size.height.toInt());
        final data = await image.toByteData(format: ui.ImageByteFormat.png);
        
        final fileName = '${name}_${isWhite ? "white" : "black"}.png';
        final file = File('assets/pieces/$fileName');
        await file.writeAsBytes(data!.buffer.asUint8List());
        print('Generated $fileName');
      }
    }
  });
}
