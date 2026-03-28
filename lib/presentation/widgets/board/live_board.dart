// ignore_for_file: unused_field
import 'dart:isolate';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/engine/chess_engine.dart';
import '../../../core/engine/game_state.dart';
import 'vector_chess_pieces.dart';

// ─── Public API ──────────────────────────────────────────────────

class LiveBoard extends StatefulWidget {
  final int aiLevel;
  final bool playerIsWhite;
  final bool vsPlayer;
  final Function(List<String> history, List<List<int>> snapshots,
      List<int> capturedByWhite, List<int> capturedByBlack) onHistoryUpdate;
  final Function(String message) onGameOver;
  final Function(bool isPlayerTurn) onTurnChange;

  const LiveBoard({
    super.key,
    required this.aiLevel,
    required this.playerIsWhite,
    this.vsPlayer = false,
    required this.onHistoryUpdate,
    required this.onGameOver,
    required this.onTurnChange,
  });

  @override
  State<LiveBoard> createState() => LiveBoardState();
}

// ─── State ───────────────────────────────────────────────────────

class LiveBoardState extends State<LiveBoard> with TickerProviderStateMixin {
  late GameState _state;
  GameState get gameState => _state;
  bool _aiThinking = false;

  // Animated move tracker
  int? _animFromSq;
  int? _animToSq;
  String? _animPieceType;
  bool? _animPieceIsWhite;
  bool _animating = false;

  // Hint: squares to highlight
  int? _hintFrom;
  int? _hintTo;

  @override
  void initState() {
    super.initState();
    _state = GameState();
    _maybeAiMove();
  }


  // ─── Public methods called from GameScreen ────────────────────

  void _notifyHistory() {
    widget.onHistoryUpdate(
      List.from(_state.moveHistory),
      List.from(_state.boardSnapshots),
      List.from(_state.capturedByWhite),
      List.from(_state.capturedByBlack),
    );
  }

  void resetGame() {
    _animFromSq = null;
    _animToSq = null;
    _animating = false;
    _hintFrom = null;
    _hintTo = null;
    setState(() {
      _state.reset();
      _aiThinking = false;
    });
    widget.onTurnChange(true);
    _maybeAiMove();
  }

  /// Show the best-move hint at the current AI level quality.
  void showHint() async {
    if (_aiThinking || _state.isGameOver) return;
    int side = _state.isWhiteTurn ? 1 : -1;
    int level = widget.aiLevel; // hint uses exact same depth as chosen AI level

    final receive = ReceivePort();
    final boardCopy = List<int>.from(_state.board);
    await Isolate.spawn<List<dynamic>>(_aiIsolate, [receive.sendPort, boardCopy, side, level, true]);
    final result = await receive.first as List<int>?;

    if (mounted && result != null) {
      setState(() {
        _hintFrom = result[0];
        _hintTo = result[1];
      });
      Future.delayed(const Duration(seconds: 4), () {
        if (mounted) setState(() { _hintFrom = null; _hintTo = null; });
      });
    }
  }

  // ─── Internal game logic ──────────────────────────────────────

  void _onTileTap(int gridIndex) {
    if (_aiThinking || _animating) return;
    bool isHumanTurn = _state.isWhiteTurn == widget.playerIsWhite;
    if (!isHumanTurn) return;

    // Clear hint on any tap
    _hintFrom = null;
    _hintTo = null;

    int prevSelected = _state.selectedSq;
    int prevLegalCount = _state.legalMoves.length;

    bool changed = _state.onTap(gridIndex);

    if (changed) {
      // Did a move happen? (legal moves got cleared, and we had something selected)
      bool moveHappened = prevSelected != -1 &&
          prevLegalCount > 0 &&
          _state.selectedSq == -1 &&
          _state.legalMoves.isEmpty;

      if (moveHappened) {
        _triggerMoveAnimation(
          from: prevSelected,
          to: GameState.gridToMailbox(gridIndex),
        );
      } else {
        setState(() {});
      }

      _notifyHistory();

      if (_state.isGameOver) {
        widget.onGameOver(_state.gameOverMessage);
        return;
      }

      bool isNowAiTurn = !widget.vsPlayer && (_state.isWhiteTurn != widget.playerIsWhite);
      widget.onTurnChange(!isNowAiTurn);
      if (isNowAiTurn) _doAiMove();
    }
  }

  void _maybeAiMove() {
    bool isAiTurn = _state.isWhiteTurn != widget.playerIsWhite;
    if (isAiTurn && !_state.isGameOver) {
      Future.delayed(const Duration(milliseconds: 400), _doAiMove);
    }
  }

  void _doAiMove() async {
    if (_state.isGameOver || !mounted) return;
    setState(() => _aiThinking = true);

    int side = _state.isWhiteTurn ? 1 : -1;
    int level = widget.aiLevel; // Level drives time budget in engine

    final receive = ReceivePort();
    final boardCopy = List<int>.from(_state.board);
    await Isolate.spawn<List<dynamic>>(_aiIsolate, [receive.sendPort, boardCopy, side, level, false]);
    final result = await receive.first as List<int>?;

    if (!mounted) return;

    if (result != null) {
      int from = result[0];
      int to = result[1];

      String pieceType = GameState.pieceTypeLetter(_state.board[from]);
      bool pieceIsWhite = _state.board[from] > 0;

      // Record move before modifying board (for animation overlay)
      _state.board[to] = _state.board[from];
      _state.board[from] = 0;

      String fromNotation = ChessEngine.squareToNotation(from).toUpperCase();
      String toNotation = ChessEngine.squareToNotation(to).toUpperCase();
      _state.moveHistory.add('$fromNotation-$toNotation');
      _state.isWhiteTurn = !_state.isWhiteTurn;
      _state.checkGameOver();

      setState(() => _aiThinking = false);
      _triggerMoveAnimation(from: from, to: to, type: pieceType, isWhite: pieceIsWhite);

      _notifyHistory();
      widget.onTurnChange(true);

      if (_state.isGameOver) widget.onGameOver(_state.gameOverMessage);
    } else {
      setState(() => _aiThinking = false);
    }
  }

  // ─── Move animation ───────────────────────────────────────────

  void _triggerMoveAnimation({
    required int from,
    required int to,
    String? type,
    bool? isWhite,
  }) {
    String pType = type ?? GameState.pieceTypeLetter(_state.board[to]);
    bool pIsWhite = isWhite ?? (_state.board[to] > 0);

    setState(() {
      _animFromSq = from;
      _animToSq = to;
      _animPieceType = pType;
      _animPieceIsWhite = pIsWhite;
      _animating = true;
    });

    Future.delayed(const Duration(milliseconds: 260), () {
      if (mounted) {
        setState(() {
          _animFromSq = null;
          _animToSq = null;
          _animPieceType = null;
          _animPieceIsWhite = null;
          _animating = false;
        });
      }
    });
  }

  // ─── Build ────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _buildBoardTransform(),
        if (_aiThinking) _buildThinkingOverlay(),
      ],
    );
  }

  Widget _buildBoardTransform() {
    return Expanded(
      child: Transform.scale(
        scale: 0.85,
        child: Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.0015)
            ..rotateX(-0.6),
          alignment: FractionalOffset.center,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.white, width: 2),
            ),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
              itemCount: 64,
              itemBuilder: (ctx, index) => _buildTile(index),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThinkingOverlay() {
    return Positioned.fill(
      child: IgnorePointer(
        child: Container(
          color: Colors.black.withValues(alpha: 0.35),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 24, height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'AI THINKING...',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    letterSpacing: 3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTile(int gridIndex) {
    int sq = GameState.gridToMailbox(gridIndex);
    int piece = _state.board[sq];
    int visualRow = gridIndex ~/ 8;
    int visualCol = gridIndex % 8;
    bool isLight = (visualRow + visualCol) % 2 == 0;
    bool isSelected = _state.selectedSq == sq;
    bool isLegal = _state.legalMoves.contains(sq);
    bool isHintFrom = _hintFrom == sq;
    bool isHintTo = _hintTo == sq;
    bool isAnimating = _animFromSq == sq || _animToSq == sq;

    String? pieceType;
    bool? isPieceWhite;
    if (piece != 0 && piece != 7 && !isAnimating) {
      pieceType = GameState.pieceTypeLetter(piece);
      isPieceWhite = piece > 0;
    }

    // Tile color
    Color tileColor = isLight ? AppColors.white : AppColors.black;
    if (isHintFrom) tileColor = const Color(0xFFCCCC44); // gold tint for hint from
    if (isHintTo) tileColor = isLight ? const Color(0xFF88DD88) : const Color(0xFF224422); // green for hint to
    if (isLegal && !isHintFrom && !isHintTo) {
      tileColor = isLight ? const Color(0xFFCCCCCC) : const Color(0xFF444444);
    }

    Color borderColor = AppColors.white.withValues(alpha: 0.15);
    double borderWidth = 0.5;
    if (isSelected) { borderColor = AppColors.white; borderWidth = 3; }
    if (isHintFrom || isHintTo) { borderColor = AppColors.white; borderWidth = 2; }

    return GestureDetector(
      onTap: () => _onTileTap(gridIndex),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: tileColor,
          border: Border.all(color: borderColor, width: borderWidth),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Legal move indicator
            if (isLegal && piece == 0)
              Container(
                width: 10, height: 10,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.45),
                  shape: BoxShape.circle,
                ),
              ),
            if (isLegal && piece != 0)
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white.withValues(alpha: 0.7), width: 2),
                ),
              ),
            // The piece
            if (pieceType != null)
              _buildPieceWidget(pieceType, isPieceWhite!, isSelected),
          ],
        ),
      ),
    );
  }

  Widget _buildPieceWidget(String type, bool isWhite, bool isSelected) {
    return AnimatedScale(
      scale: isSelected ? 1.12 : 1.0,
      duration: const Duration(milliseconds: 180),
      curve: Curves.elasticOut,
      child: AnimatedOpacity(
        opacity: 1.0,
        duration: const Duration(milliseconds: 120),
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: ChessPiece(
            type: type,
            isWhite: isWhite,
            size: 40,
            isSelected: isSelected,
          ),
        ),
      ),
    );
  }
}

// ─── Isolate helper ───────────────────────────────────────────────
// args: [SendPort, board, side, level, isHint]
void _aiIsolate(List<dynamic> args) {
  SendPort send = args[0];
  List<int> boardCopy = List<int>.from(args[1]);
  int side = args[2];
  int level = args[3];
  // args[4] (isHint bool) reserved — both AI and hint use same engine call

  var engine = ChessEngine();
  engine.b = boardCopy;
  // getBestMove uses iterative deepening within the level's time budget
  List<int>? move = engine.getBestMove(side, level);
  send.send(move);
}
