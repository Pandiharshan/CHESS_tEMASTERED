import 'package:flutter/foundation.dart';
import 'ai_controller.dart';
import '../engine/game_state.dart';
import '../engine/chess_engine.dart';

class GameController extends ChangeNotifier {
  final GameState state;
  final AIController aiController;

  // AI Configuration
  int aiLevel = 2;
  bool isAiEnabled = true; // AI responds to player
  bool autoAiMode = false; // AI plays against itself
  bool playerIsWhite = true;
  bool vsPlayer = false;

  bool isAiThinking = false;
  
  // Timers (in seconds)
  int player1Seconds = 600;
  int player2Seconds = 600; // AI or Player 2

  GameController({
    required this.state,
    required this.aiController,
    this.aiLevel = 2,
    this.autoAiMode = false,
    this.playerIsWhite = true,
    this.vsPlayer = false,
  }) {
    isAiEnabled = !vsPlayer;
  }

  void reset() {
    state.reset();
    isAiThinking = false;
    player1Seconds = 600;
    player2Seconds = 600;
    notifyListeners();
    _triggerAiIfNecessary();
  }

  void setAiLevel(int level) {
    aiLevel = level;
    notifyListeners();
  }

  void toggleAutoAi(bool value) {
    isAiEnabled = value;
    notifyListeners();
    if (value) _triggerAiIfNecessary();
  }

  bool handleTileTap(int gridIndex) {
    if (state.isGameOver || isAiThinking) return false;
    
    // Determine if it is the local player's turn to interact
    if (!vsPlayer && isAiEnabled && state.isWhiteTurn != playerIsWhite) {
      return false; // It's AI's turn, ignore tap
    }

    bool changed = state.onTap(gridIndex);
    if (changed) {
      notifyListeners();
      _triggerAiIfNecessary();
    }
    return changed;
  }

  void _triggerAiIfNecessary() {
    if (state.isGameOver) return;
    
    // If AI explicitly plays against itself
    if (autoAiMode) {
      _doAiMove();
      return;
    }

    if (vsPlayer || !isAiEnabled) return;
    
    // Is it AI's turn?
    if (state.isWhiteTurn != playerIsWhite) {
      _doAiMove();
    }
  }

  Future<void> _doAiMove() async {
    if (isAiThinking || state.isGameOver) return;
    
    isAiThinking = true;
    notifyListeners();

    int side = state.isWhiteTurn ? 1 : -1;
    final move = await aiController.calculateBestMove(
      boardState: state.board,
      side: side,
      level: aiLevel,
      isHint: false,
    );

    isAiThinking = false;
    
    if (move != null && move.length >= 2) {
      // Apply move and force turn change
      state.applyAiMove(move[0], move[1]);
    }
    
    notifyListeners();
    _triggerAiIfNecessary();
  }

  Future<void> requestHint() async {
    if (state.isGameOver || isAiThinking) return;

    isAiThinking = true;
    notifyListeners();

    int side = state.isWhiteTurn ? 1 : -1;
    final move = await aiController.calculateBestMove(
      boardState: state.board,
      side: side,
      level: aiLevel, // Match hint strength to AI level
      isHint: true,
    );

    isAiThinking = false;
    
    if (move != null && move.length >= 2) {
      // Show visual hint
      state.hintMove = move;
    }
    
    notifyListeners();
  }

  void disposeAll() {
    aiController.dispose();
    dispose();
  }

  /// Public refresh – use this instead of calling notifyListeners() externally.
  void refresh() => notifyListeners();
}
