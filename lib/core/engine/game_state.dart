// ignore_for_file: constant_identifier_names
import 'chess_engine.dart';

/// Manages all chess game state: board, turn, selection, move history etc.
class GameState {
  final ChessEngine engine;

  /// Board stored in the same 120-cell mailbox format.
  List<int> get board => engine.b;

  bool isWhiteTurn = true;

  /// Currently selected square (mailbox index), or -1 if none
  int selectedSq = -1;

  /// Legal destination squares from the selected piece
  List<int> legalMoves = [];

  /// Move history as strings
  List<String> moveHistory = [];

  /// Board snapshots – one per move (saved BEFORE the move is applied).
  List<List<int>> boardSnapshots = [];
  List<List<int>> capturedWhiteSnapshots = [];
  List<List<int>> capturedBlackSnapshots = [];

  /// Captured pieces (piece codes)
  List<int> capturedByWhite = [];
  List<int> capturedByBlack = [];

  /// Current visual hint [from, to] squares.
  List<int> hintMove = [];

  bool isGameOver = false;
  String gameOverMessage = '';

  // ── Special move state ─────────────────────────────────────────────────────

  /// Castling rights: [whiteKingside, whiteQueenside, blackKingside, blackQueenside]
  List<bool> castlingRights = [true, true, true, true];

  /// En passant target square (mailbox index) after a double pawn push, else -1.
  int epSquare = -1;

  /// When a pawn reaches the back rank, this is set to the target square.
  /// The UI must call [completePromotion] with the chosen piece type to finalise.
  int? promotionPendingTo; // mailbox square
  int? promotionPendingFrom;
  int? promotionPendingSide; // 1=white, -1=black

  GameState() : engine = ChessEngine();

  // ── Coordinate helpers ─────────────────────────────────────────────────────

  /// Convert grid index (0-63, row 0 = top visually) to mailbox index.
  static int gridToMailbox(int gridIndex) {
    int visualRow = gridIndex ~/ 8;
    int col = gridIndex % 8;
    int mailboxRow = 9 - visualRow;
    return mailboxRow * 10 + col + 1;
  }

  /// Convert mailbox index back to grid index (0-63)
  static int mailboxToGrid(int sq) {
    int row = sq ~/ 10;
    int col = sq % 10;
    int visualRow = 9 - row;
    return visualRow * 8 + (col - 1);
  }

  /// Piece type letter for display
  static String pieceTypeLetter(int piece) {
    switch (piece.abs()) {
      case 1: return 'p';
      case 2: return 'n';
      case 3: return 'b';
      case 4: return 'r';
      case 5: return 'q';
      case 6: return 'k';
      default: return '';
    }
  }

  // ── User interaction ───────────────────────────────────────────────────────

  /// Call when a board tile at [gridIndex] is tapped.
  /// Returns true if the board changed (needs full repaint).
  bool onTap(int gridIndex) {
    if (isGameOver) return false;
    if (promotionPendingTo != null) return false; // Wait for promotion choice

    hintMove = [];

    int sq = gridToMailbox(gridIndex);
    int piece = board[sq];

    if (selectedSq != -1) {
      if (legalMoves.contains(sq)) {
        _executeMove(selectedSq, sq);
        selectedSq = -1;
        legalMoves = [];
        return true;
      }
      if (piece != 0 && piece != 7 && (piece > 0) == isWhiteTurn) {
        selectedSq = sq;
        legalMoves = _getLegalMoves(sq);
        return true;
      }
      selectedSq = -1;
      legalMoves = [];
      return true;
    }

    if (piece != 0 && piece != 7 && (piece > 0) == isWhiteTurn) {
      selectedSq = sq;
      legalMoves = _getLegalMoves(sq);
      return true;
    }
    return false;
  }

  // ── Move generation ────────────────────────────────────────────────────────

  List<int> _getLegalMoves(int sq) {
    int piece = board[sq];
    int side = piece > 0 ? 1 : -1;
    List<int> moves = [];
    int type = piece.abs();

    if (type == 1) {
      int fwd = side == 1 ? 10 : -10;

      // Diagonal captures (including en passant)
      for (int dx in [-1, 1]) {
        int to = sq + fwd + dx;
        int target = board[to];
        // Normal capture
        if (target != 0 && target != 7 && (target > 0) != (side > 0)) {
          if (_moveIsLegal(sq, to, piece, target)) moves.add(to);
        }
        // En passant
        if (to == epSquare && epSquare != -1) {
          if (_epMoveIsLegal(sq, to, side)) moves.add(to);
        }
      }
      // Forward
      int fwdSq = sq + fwd;
      if (board[fwdSq] == 0) {
        if (_moveIsLegal(sq, fwdSq, piece, 0)) moves.add(fwdSq);
        bool onStartRow = side == 1 ? (sq >= 31 && sq <= 38) : (sq >= 81 && sq <= 88);
        if (onStartRow) {
          int dbl = sq + 2 * fwd;
          if (board[dbl] == 0 && _moveIsLegal(sq, dbl, piece, 0)) moves.add(dbl);
        }
      }
    } else if (type == 6) {
      // King normal moves
      for (int d in K_DIRS) {
        int to = sq + d;
        int target = board[to];
        if (target == 7) continue;
        if (target != 0 && (target > 0) == (side > 0)) continue;
        if (_moveIsLegal(sq, to, piece, target)) moves.add(to);
      }
      // Castling
      if (side == 1 && sq == 25) {
        // White kingside
        if (castlingRights[0] &&
            board[26] == 0 && board[27] == 0 &&
            board[28] == 4 &&
            !engine.isInCheck(1) &&
            !_squareAttacked(26, -1) &&
            !_squareAttacked(27, -1)) {
          moves.add(27); // King lands on g1 (sq 27)
        }
        // White queenside
        if (castlingRights[1] &&
            board[24] == 0 && board[23] == 0 && board[22] == 0 &&
            board[21] == 4 &&
            !engine.isInCheck(1) &&
            !_squareAttacked(24, -1) &&
            !_squareAttacked(23, -1)) {
          moves.add(23); // King lands on c1 (sq 23)
        }
      } else if (side == -1 && sq == 95) {
        // Black kingside
        if (castlingRights[2] &&
            board[96] == 0 && board[97] == 0 &&
            board[98] == -4 &&
            !engine.isInCheck(-1) &&
            !_squareAttacked(96, 1) &&
            !_squareAttacked(97, 1)) {
          moves.add(97); // King lands on g8
        }
        // Black queenside
        if (castlingRights[3] &&
            board[94] == 0 && board[93] == 0 && board[92] == 0 &&
            board[91] == -4 &&
            !engine.isInCheck(-1) &&
            !_squareAttacked(94, 1) &&
            !_squareAttacked(93, 1)) {
          moves.add(93); // King lands on c8
        }
      }
    } else {
      List<int> dirs;
      int start, end;
      if (type == 2)      { dirs = N_DIRS; start = 0; end = 8; }
      else if (type == 4) { dirs = K_DIRS; start = 0; end = 4; }
      else if (type == 3) { dirs = K_DIRS; start = 4; end = 8; }
      else                { dirs = K_DIRS; start = 0; end = 8; } // queen

      bool slider = type != 2;

      for (int i = start; i < end; i++) {
        int to = sq;
        while (true) {
          to += dirs[i];
          int target = board[to];
          if (target == 7) break;
          if (target != 0 && (target > 0) == (side > 0)) break;
          if (_moveIsLegal(sq, to, piece, target)) moves.add(to);
          if (target != 0) break;
          if (!slider) break;
        }
      }
    }
    return moves;
  }

  bool _moveIsLegal(int from, int to, int piece, int captured) {
    board[to] = piece;
    board[from] = 0;
    bool inCheck = engine.isInCheck(piece > 0 ? 1 : -1);
    board[from] = piece;
    board[to] = captured;
    return !inCheck;
  }

  bool _epMoveIsLegal(int from, int to, int side) {
    int capturedPawnSq = to - (side == 1 ? 10 : -10);
    int capturedPawn = board[capturedPawnSq];
    int movingPawn = board[from];
    board[to] = movingPawn;
    board[from] = 0;
    board[capturedPawnSq] = 0;
    bool inCheck = engine.isInCheck(side);
    board[from] = movingPawn;
    board[to] = 0;
    board[capturedPawnSq] = capturedPawn;
    return !inCheck;
  }

  bool _squareAttacked(int sq, int byEnemy) {
    // Temporarily set the square to a sentinel and use engine's check logic trick:
    // Instead, do a proper attack check.
    // Check if [sq] is attacked by any piece of the [byEnemy] side.
    // Pawn attacks
    if (byEnemy == -1) {
      // Black pawns attack downward (towards smaller sq)
      if (board[sq + 9] == -1 || board[sq + 11] == -1) return true;
    } else {
      // White pawns attack upward
      if (board[sq - 9] == 1 || board[sq - 11] == 1) return true;
    }
    // Knight
    for (int d in N_DIRS) {
      int t = sq + d;
      if (board[t] == 2 * byEnemy) return true;
    }
    // Rook/Queen (orthogonal)
    for (int i = 0; i < 4; i++) {
      int t = sq;
      while (true) {
        t += K_DIRS[i];
        if (board[t] == 7) break;
        if (board[t] == 0) continue;
        if (board[t] == 4 * byEnemy || board[t] == 5 * byEnemy) return true;
        break;
      }
    }
    // Bishop/Queen (diagonal)
    for (int i = 4; i < 8; i++) {
      int t = sq;
      while (true) {
        t += K_DIRS[i];
        if (board[t] == 7) break;
        if (board[t] == 0) continue;
        if (board[t] == 3 * byEnemy || board[t] == 5 * byEnemy) return true;
        break;
      }
    }
    // King
    for (int d in K_DIRS) {
      if (board[sq + d] == 6 * byEnemy) return true;
    }
    return false;
  }

  // ── Move execution ─────────────────────────────────────────────────────────

  void _executeMove(int from, int to) {
    int piece = board[from];
    int captured = board[to];
    int side = piece > 0 ? 1 : -1;

    // Save full snapshot (including special state)
    boardSnapshots.add(List<int>.from(board));
    capturedWhiteSnapshots.add(List<int>.from(capturedByWhite));
    capturedBlackSnapshots.add(List<int>.from(capturedByBlack));

    String moveStr = '${ChessEngine.squareToNotation(from).toUpperCase()}-'
        '${ChessEngine.squareToNotation(to).toUpperCase()}';

    // ── En Passant capture ────────────────────────
    int newEp = -1;
    if (piece.abs() == 1 && to == epSquare && epSquare != -1) {
      int capturedPawnSq = to - (side == 1 ? 10 : -10);
      int capturedPawn = board[capturedPawnSq];
      board[capturedPawnSq] = 0;
      if (isWhiteTurn) { capturedByWhite.add(capturedPawn); }
      else             { capturedByBlack.add(capturedPawn); }
      moveStr += ' e.p.';
    } else if (captured != 0) {
      if (isWhiteTurn) { capturedByWhite.add(captured); }
      else             { capturedByBlack.add(captured); }
    }

    board[to] = piece;
    board[from] = 0;

    // ── Set new en passant square ─────────────────
    if (piece.abs() == 1 && (to - from).abs() == 20) {
      newEp = (from + to) ~/ 2; // middle square
    }
    epSquare = newEp;

    // ── Castling – move the rook ──────────────────
    if (piece.abs() == 6) {
      if (piece == 6) {
        // White king
        if (from == 25 && to == 27) { board[28] = 0; board[26] = 4; moveStr = 'O-O'; }
        if (from == 25 && to == 23) { board[21] = 0; board[24] = 4; moveStr = 'O-O-O'; }
      } else {
        // Black king
        if (from == 95 && to == 97) { board[98] = 0; board[96] = -4; moveStr = 'O-O'; }
        if (from == 95 && to == 93) { board[91] = 0; board[94] = -4; moveStr = 'O-O-O'; }
      }
    }

    // ── Update castling rights ────────────────────
    if (piece == 6)  { castlingRights[0] = false; castlingRights[1] = false; }
    if (piece == -6) { castlingRights[2] = false; castlingRights[3] = false; }
    if (from == 28 || to == 28) castlingRights[0] = false; // h1 rook
    if (from == 21 || to == 21) castlingRights[1] = false; // a1 rook
    if (from == 98 || to == 98) castlingRights[2] = false; // h8 rook
    if (from == 91 || to == 91) castlingRights[3] = false; // a8 rook

    // ── Pawn promotion – request UI choice ───────
    bool isPromotion = (piece == 1 && to >= 91 && to <= 98) ||
                       (piece == -1 && to >= 21 && to <= 28);
    if (isPromotion) {
      promotionPendingFrom = from;
      promotionPendingTo   = to;
      promotionPendingSide = side;
      // Don't flip turn yet; wait for completePromotion()
      moveHistory.add('$moveStr=?');
      return; // caller must call completePromotion()
    }

    moveHistory.add(moveStr);
    isWhiteTurn = !isWhiteTurn;
    _checkGameOverInternal();
  }

  /// Called by the UI after user picks a promotion piece.
  /// [pieceType]: 2=knight, 3=bishop, 4=rook, 5=queen
  void completePromotion(int pieceType) {
    if (promotionPendingTo == null) return;
    int to   = promotionPendingTo!;
    int side = promotionPendingSide!;
    board[to] = pieceType * side;
    if (moveHistory.isNotEmpty) {
      moveHistory[moveHistory.length - 1] =
          moveHistory.last.replaceAll('=?', '=${_pieceChar(pieceType)}');
    }
    promotionPendingTo   = null;
    promotionPendingFrom = null;
    promotionPendingSide = null;
    isWhiteTurn = !isWhiteTurn;
    _checkGameOverInternal();
  }

  String _pieceChar(int t) {
    switch (t) { case 2: return 'N'; case 3: return 'B'; case 4: return 'R'; default: return 'Q'; }
  }

  void _checkGameOverInternal() {
    int side = isWhiteTurn ? 1 : -1;
    bool hasAnyMove = false;
    for (int from = 21; from < 99; from++) {
      int p = board[from];
      if (p == 7 || p == 0 || (p > 0) != (side > 0)) continue;
      if (_getLegalMoves(from).isNotEmpty) { hasAnyMove = true; break; }
    }
    if (!hasAnyMove) {
      isGameOver = true;
      if (engine.isInCheck(side)) {
        gameOverMessage = isWhiteTurn ? 'BLACK WINS BY CHECKMATE!' : 'WHITE WINS BY CHECKMATE!';
      } else {
        gameOverMessage = 'STALEMATE — DRAW!';
      }
    }
  }

  void checkGameOver() => _checkGameOverInternal();

  static int depthForLevel(int level) {
    const depths = [0, 2, 3, 4, 5];
    return depths[level.clamp(1, 4)];
  }

  void applyAiMove(int from, int to) {
    if (isGameOver) return;
    _executeMove(from, to);
    // Auto-queen any AI promotion (AI always promotes to queen)
    if (promotionPendingTo != null) {
      completePromotion(5);
    }
  }

  void popSnapshot() {
    if (boardSnapshots.isEmpty) return;
    List<int> oldBoard = boardSnapshots.removeLast();
    for (int i = 0; i < oldBoard.length; i++) { board[i] = oldBoard[i]; }
    if (capturedWhiteSnapshots.isNotEmpty) capturedByWhite = capturedWhiteSnapshots.removeLast();
    if (capturedBlackSnapshots.isNotEmpty) capturedByBlack = capturedBlackSnapshots.removeLast();
    if (moveHistory.isNotEmpty) moveHistory.removeLast();
    isWhiteTurn = !isWhiteTurn;
    isGameOver = false;
    gameOverMessage = '';
    legalMoves.clear();
    selectedSq = -1;
    promotionPendingTo   = null;
    promotionPendingFrom = null;
    promotionPendingSide = null;
    // Restore ep square (approximate: clear it on undo − safe)
    epSquare = -1;
  }

  void reset() {
    engine.initBoard();
    isWhiteTurn = true;
    selectedSq = -1;
    legalMoves = [];
    capturedByWhite.clear();
    capturedByBlack.clear();
    moveHistory.clear();
    boardSnapshots.clear();
    capturedWhiteSnapshots.clear();
    capturedBlackSnapshots.clear();
    isGameOver = false;
    gameOverMessage = '';
    castlingRights = [true, true, true, true];
    epSquare = -1;
    promotionPendingTo   = null;
    promotionPendingFrom = null;
    promotionPendingSide = null;
    hintMove = [];
  }
}
