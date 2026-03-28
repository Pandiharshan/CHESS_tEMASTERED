import 'dart:isolate';
import 'package:flutter/foundation.dart';
import '../engine/chess_engine.dart';

class AIController {
  Isolate? _engineIsolate;
  ReceivePort? _receivePort;

  // Cleanup any running isolate
  void dispose() {
    _cancelComputation();
  }

  void _cancelComputation() {
    _receivePort?.close();
    _engineIsolate?.kill(priority: Isolate.immediate);
    _engineIsolate = null;
    _receivePort = null;
  }

  /// Calculates the best move. Cancels any existing computation.
  Future<List<int>?> calculateBestMove({
    required List<int> boardState,
    required int side, // 1 for white, -1 for black
    required int level, // 1, 2, 3, 4
    required bool isHint, // true if user requested a hint
  }) async {
    _cancelComputation();

    _receivePort = ReceivePort();
    
    // Copy the board to pass safely to the isolate
    final boardCopy = List<int>.from(boardState);

    debugPrint('[AIController] Starting computation... Level: $level, isHint: $isHint');

    try {
      _engineIsolate = await Isolate.spawn<List<dynamic>>(
        _aiIsolateTask,
        [_receivePort!.sendPort, boardCopy, side, level, isHint],
      );

      // Await result
      final result = await _receivePort!.first as List<int>?;
      return result;
    } catch (e) {
      debugPrint('[AIController] Error during computation: $e');
      return null;
    } finally {
      _cancelComputation();
    }
  }

  static void _aiIsolateTask(List<dynamic> args) {
    SendPort sendPort = args[0];
    List<int> board = args[1];
    int side = args[2];
    int level = args[3];

    ChessEngine engine = ChessEngine();
    engine.b = board;
    
    // Run the engine iterative deepening search
    List<int>? bestMove = engine.getBestMove(side, level);
    
    if (bestMove != null) {
      sendPort.send(bestMove);
    } else {
      sendPort.send(null);
    }
  }
}
