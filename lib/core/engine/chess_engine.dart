// ignore_for_file: constant_identifier_names, unnecessary_library_name, non_constant_identifier_names
// Chess Engine — Dart port of the negamax C engine with iterative deepening + time-budgeting.
// Piece encoding: 0=empty, 1=pawn, 2=knight, 3=bishop, 4=rook, 5=queen, 6=king, 7=sentinel
// +ve = white, -ve = black

const List<int> v = [0, 1, 3, 3, 5, 9, 99];

// Knight move offsets
const List<int> N_DIRS = [-21, -19, -12, -8, 8, 12, 19, 21];
// Rook/Bishop/Queen/King offsets (0-3 orthogonal, 4-7 diagonal)
const List<int> K_DIRS = [-1, 1, -10, 10, -11, -9, 9, 11];

int _abs(int x) => x < 0 ? -x : x;

// ────────────────────────────────────────────────────────────────────────
// Time budget per level (milliseconds). Keeps the game snappy.
// Level 1 = near-instant shallow look, Level 4 = deeper but still fast.
// ────────────────────────────────────────────────────────────────────────
const List<int> _levelBudgetMs = [0, 200, 800, 1500, 3000];

// Max iterative-deepening depth cap per level.
const List<int> _levelMaxDepth = [0, 2, 3, 4, 5];

class ChessEngine {
  late List<int> b; // Board (120 cell mailbox)
  int bs = 0;       // Best move source
  int bd = 0;       // Best move destination

  // Time guard
  late DateTime _deadline;
  bool _aborted = false;

  ChessEngine() {
    b = List.filled(120, 0);
    initBoard();
  }

  /// Initialise board to the standard starting position.
  void initBoard() {
    const backRank = '42356324';
    for (int i = 0; i < 120; i++) {
      int row = i ~/ 10;
      int col = i % 10;
      if (row < 2 || row > 9 || col < 1 || col > 8) {
        b[i] = 7;
      } else if (row == 3) {
        b[i] = 1;
      } else if (row == 8) {
        b[i] = -1;
      } else if (row == 2) {
        b[i] = int.parse(backRank[col - 1]);
      } else if (row == 9) {
        b[i] = -int.parse(backRank[col - 1]);
      } else {
        b[i] = 0;
      }
    }
  }

  /// Is the king of [s] in check?
  bool isInCheck(int s) {
    int kingSq = 0;
    int enemy = -s;
    for (int i = 21; i < 99; i++) {
      if (b[i] == 6 * s) { kingSq = i; break; }
    }
    if (kingSq == 0) return false;
    // Pawn
    if (s == 1) {
      if (b[kingSq + 9] == -1 || b[kingSq + 11] == -1) return true;
    } else {
      if (b[kingSq - 9] == 1 || b[kingSq - 11] == 1) return true;
    }
    // Knight
    for (int d in N_DIRS) {
      if (b[kingSq + d] == 2 * enemy) return true;
    }
    // Enemy king
    for (int d in K_DIRS) {
      if (b[kingSq + d] == 6 * enemy) return true;
    }
    // Rook/Queen (orthogonal)
    for (int i = 0; i < 4; i++) {
      int t = kingSq;
      while (true) {
        t += K_DIRS[i];
        if (b[t] == 7) break;
        if (b[t] == 0) continue;
        if ((b[t] > 0) == (enemy > 0) && (_abs(b[t]) == 4 || _abs(b[t]) == 5)) return true;
        break;
      }
    }
    // Bishop/Queen (diagonal)
    for (int i = 4; i < 8; i++) {
      int t = kingSq;
      while (true) {
        t += K_DIRS[i];
        if (b[t] == 7) break;
        if (b[t] == 0) continue;
        if ((b[t] > 0) == (enemy > 0) && (_abs(b[t]) == 3 || _abs(b[t]) == 5)) return true;
        break;
      }
    }
    return false;
  }

  // ── Move-try helper ──────────────────────────────────────────────
  int _tryMove(int s, int d, int a, int be, int from, int to, int piece, int captured, List<int> result) {
    if (_aborted) return a;
    b[to] = piece;
    b[from] = 0;
    if (isInCheck(s)) {
      b[from] = piece;
      b[to] = captured;
      return a;
    }
    result[0] = 1;
    int score = -_search(-s, d > 0 ? d - 1 : 0, -be, -a);
    b[from] = piece;
    b[to] = captured;
    if (score > a) {
      a = score;
      // Record root best move when at the top depth marker
      if (d >= _rootDepth) { bs = from; bd = to; }
    }
    return a >= be ? be : a;
  }

  int _rootDepth = 0; // Updated by iterative loop

  // ── Negamax alpha-beta ────────────────────────────────────────────
  int _search(int s, int d, int a, int be) {
    if (_aborted || DateTime.now().isAfter(_deadline)) {
      _aborted = true;
      return a;
    }

    bool atLeaf = d == 0;
    List<int> hasLegal = [0];

    if (atLeaf) {
      int sc = 0;
      for (int i = 21; i < 99; i++) {
        if (b[i] != 7) sc += b[i] > 0 ? v[b[i]] : -v[-b[i]];
      }
      sc *= s;
      if (sc > a) a = sc;
      if (a >= be) return be;
    }

    for (int pass = 0; pass < (atLeaf ? 1 : 2); pass++) {
      for (int from = 21; from < 99; from++) {
        if (_aborted) return a;
        int piece = b[from];
        if (piece == 7 || piece == 0 || (piece > 0) != (s > 0)) continue;
        int type = _abs(piece);

        if (type == 1) {
          int fwd = s == 1 ? 10 : -10;
          if (pass == 0) {
            for (int dx = -1; dx <= 1; dx += 2) {
              int to = from + fwd + dx;
              int captured = b[to];
              if (captured != 0 && captured != 7 && (captured > 0) != (s > 0)) {
                a = _tryMove(s, d, a, be, from, to, piece, captured, hasLegal);
                if (a >= be) return be;
              }
            }
          } else {
            if (b[from + fwd] == 0) {
              a = _tryMove(s, d, a, be, from, from + fwd, piece, 0, hasLegal);
              if (a >= be) return be;
              if (((s == 1 && from < 40) || (s == -1 && from > 70)) && b[from + 2 * fwd] == 0) {
                a = _tryMove(s, d, a, be, from, from + 2 * fwd, piece, 0, hasLegal);
                if (a >= be) return be;
              }
            }
          }
        } else {
          List<int> dirs;
          int start, end;
          if (type == 2) { dirs = N_DIRS; start = 0; end = 8; }
          else if (type == 4) { dirs = K_DIRS; start = 0; end = 4; }
          else if (type == 3) { dirs = K_DIRS; start = 4; end = 8; }
          else { dirs = K_DIRS; start = 0; end = 8; }
          bool slider = type != 2 && type != 6;

          for (int i = start; i < end; i++) {
            int to = from;
            while (true) {
              to += dirs[i];
              int target = b[to];
              if (target == 7) break;
              if (target != 0 && (target > 0) == (s > 0)) break;
              if (pass == 0) {
                if (target != 0) {
                  a = _tryMove(s, d, a, be, from, to, piece, target, hasLegal);
                  if (a >= be) return be;
                  break;
                }
              } else {
                if (target == 0) {
                  a = _tryMove(s, d, a, be, from, to, piece, 0, hasLegal);
                  if (a >= be) return be;
                } else { break; }
              }
              if (!slider) break;
            }
          }
        }
      }
    }

    if (hasLegal[0] == 0 && !atLeaf) return isInCheck(s) ? -9999 : 0;
    return a;
  }

  // ── Public API: Iterative deepening with time budget ───────────────
  /// Level 1-4 → uses time budget + depth cap for that level.
  List<int>? getBestMove(int side, int level) {
    int budgetMs = _levelBudgetMs[level.clamp(1, 4)];
    int maxDepth = _levelMaxDepth[level.clamp(1, 4)];
    
    // ignore: avoid_print
    print('[ChessEngine] Search starting... Level: $level, Budget: ${budgetMs}ms, Max Depth: $maxDepth');

    _deadline = DateTime.now().add(Duration(milliseconds: budgetMs));
    _aborted = false;

    int bestFrom = 0;
    int bestTo = 0;

    // Iterative deepening: search depth 1, then 2, then … until time runs out
    for (int depth = 1; depth <= maxDepth; depth++) {
      if (_aborted || DateTime.now().isAfter(_deadline)) {
        // ignore: avoid_print
        print('[ChessEngine] Search aborted at depth $depth (timeout)');
        break;
      }
      bs = 0;
      bd = 0;
      _rootDepth = depth;
      _search(side, depth, -10000, 10000);
      if (!_aborted && bs != 0) {
        bestFrom = bs;
        bestTo = bd;
      }
    }

    if (bestFrom == 0 && bestTo == 0) {
      // ignore: avoid_print
      print('[ChessEngine] Failed to find move.');
      return null;
    }
    
    // ignore: avoid_print
    print('[ChessEngine] Found move $bestFrom -> $bestTo');
    return [bestFrom, bestTo];
  }

  /// Quick hint: always uses the FULL level budget (same quality as AI).
  List<int>? getHintMove(int side, int level) => getBestMove(side, level);

  /// Notation helper: mailbox index → algebraic (e.g. 31 → "a1")
  static String squareToNotation(int sq) {
    int col = sq % 10;
    int row = sq ~/ 10;
    String file = String.fromCharCode('a'.codeUnitAt(0) + col - 1);
    return '$file${row - 1}';
  }
}
