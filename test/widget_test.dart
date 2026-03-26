import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chess_remastered/main.dart';
import 'package:chess_remastered/presentation/screens/game/game_screen.dart';

void main() {
  testWidgets('Home Screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ChessRemasteredApp());
    expect(find.text('CHESS\nREMASTERED'), findsOneWidget);
    expect(find.text('START GAME'), findsOneWidget);
    expect(find.text('SETTINGS'), findsOneWidget);
    expect(find.text('EXIT'), findsOneWidget);
  });

  testWidgets('Game Screen renders', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: GameScreen()),
    );
    await tester.pump();
    expect(find.byType(GameScreen), findsOneWidget);
  });
}
