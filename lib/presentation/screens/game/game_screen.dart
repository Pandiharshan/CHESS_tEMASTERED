import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/engine/game_state.dart';
import '../../../core/controllers/game_controller.dart';
import '../../../core/controllers/ai_controller.dart';
import '../../widgets/board/chess_board_widget.dart';
import '../settings/settings_screen.dart';

class GameScreen extends StatefulWidget {
  final int aiLevel;
  final bool playerIsWhite;
  final bool vsPlayer; 
  final bool autoAiMode;

  const GameScreen({
    super.key,
    this.aiLevel = 2,
    this.playerIsWhite = true,
    this.vsPlayer = false,
    this.autoAiMode = false,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late GameController _controller;
  
  // Timers
  Timer? _timer;
  bool _isPaused = false;
  
  // Animations
  late AnimationController _blinkCtrl;
  late Animation<double> _blinkAnim;

  @override
  void initState() {
    super.initState();
    
    // Initialize Controllers
    _controller = GameController(
      state: GameState(),
      aiController: AIController(),
      aiLevel: widget.aiLevel,
      autoAiMode: widget.autoAiMode,
      playerIsWhite: widget.playerIsWhite,
      vsPlayer: widget.vsPlayer,
    );

    _controller.addListener(_onControllerUpdate);

    // Explicitly reset the controller to trigger AI if it's AI's turn to start
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.reset();
    });

    // Blinker for critical time (<30s)
    _blinkCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700))
      ..repeat(reverse: true);
    _blinkAnim = Tween<double>(begin: 0.4, end: 1.0).animate(_blinkCtrl);

    _startTimer();
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    _controller.disposeAll();
    _timer?.cancel();
    _blinkCtrl.dispose();
    super.dispose();
  }

  void _onControllerUpdate() {
    setState(() {});
    // Promotion needed? Show picker
    if (_controller.state.promotionPendingTo != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showPromotionDialog();
      });
      return; // Don't show game over yet
    }
    if (_controller.state.isGameOver) {
      _timer?.cancel();
      _showGameOverDialog(_controller.state.gameOverMessage);
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_controller.state.isGameOver || _isPaused) return;
      
      setState(() {
        if (_controller.state.isWhiteTurn == _controller.playerIsWhite) {
          if (_controller.player1Seconds > 0) {
            _controller.player1Seconds--;
          } else {
            t.cancel();
            _onTimeout(isPlayer: true);
          }
        } else {
          if (_controller.player2Seconds > 0) {
            _controller.player2Seconds--;
          } else {
            t.cancel();
            _onTimeout(isPlayer: false);
          }
        }
      });
    });
  }

  void _onTimeout({required bool isPlayer}) {
    final msg = isPlayer ? 'TIME\'S UP — AI WINS!' : 'TIME\'S UP — YOU WIN!';
    _controller.state.gameOverMessage = msg;
    _controller.state.isGameOver = true;
    _showGameOverDialog(msg);
  }

  String _fmt(int s) => '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';

  void _showPromotionDialog() {
    final side = _controller.state.promotionPendingSide ?? 1;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.black,
        shape: RoundedRectangleBorder(side: const BorderSide(color: AppColors.white, width: 2)),
        title: Text('PROMOTE PAWN', style: AppTextStyles.title),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _promoBtn(ctx, 'Q', 5, side),
            _promoBtn(ctx, 'R', 4, side),
            _promoBtn(ctx, 'B', 3, side),
            _promoBtn(ctx, 'N', 2, side),
          ],
        ),
      ),
    );
  }

  Widget _promoBtn(BuildContext ctx, String label, int pieceType, int side) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(ctx);
        _controller.state.completePromotion(pieceType);
        _controller.refresh();
      },
      child: Container(
        width: 48, height: 48,
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(color: AppColors.black, width: 2),
        ),
        child: Center(
          child: Text(label, style: const TextStyle(color: AppColors.black, fontWeight: FontWeight.bold, fontSize: 20)),
        ),
      ),
    );
  }

  // ── UI Actions ────────────────────────────────────────────────
  void _undoMove() {
    if (_controller.state.moveHistory.isEmpty) return;
    _controller.state.popSnapshot();
    if (!_controller.vsPlayer && _controller.isAiEnabled) {
      _controller.state.popSnapshot(); // Pop AI move too
    }
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('MOVE UNDONE', style: AppTextStyles.body), backgroundColor: AppColors.black));
  }

  void _restartGame() {
    _controller.reset();
    _isPaused = false;
    _startTimer();
  }

  void _showGameOverDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.black,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: AppColors.white, width: 2),
        ),
        title: Text('GAME OVER', style: AppTextStyles.title),
        content: Text(message, style: AppTextStyles.body),
        actions: [
          ElevatedButton(
             style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.white,
              foregroundColor: AppColors.black,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _restartGame();
            },
            child: Text('REMATCH', style: AppTextStyles.buttonText),
          ),
        ],
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: AppColors.black,
        title: Text('MAC CHESS', style: AppTextStyles.headline),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: AppColors.white),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
             _buildTopBar(),
             const Spacer(),
             
             Expanded(
               flex: 6,
               child: Center(
                 child: AspectRatio(
                   aspectRatio: 1,
                   child: ChessBoardWidget(controller: _controller),
                 ),
               ),
             ),
             
             const Spacer(),
             _buildBottomControls(),
             const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildTimerBox("AI (Lvl ${_controller.aiLevel})", _controller.player2Seconds, false),
          _buildTimerBox("PLAYER", _controller.player1Seconds, true),
        ],
      ),
    );
  }

  Widget _buildTimerBox(String lbl, int secs, bool isPlayer) {
    bool active = _controller.state.isWhiteTurn == (isPlayer ? _controller.playerIsWhite : !_controller.playerIsWhite);
    bool urgent = active && secs < 30;

    Widget timeText = Text(_fmt(secs), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.black, fontFamily: 'monospace'));
    
    if (urgent) {
      timeText = AnimatedBuilder(
        animation: _blinkAnim,
        builder: (ctx, child) => Opacity(opacity: _blinkAnim.value, child: child),
        child: Text(_fmt(secs), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red, fontFamily: 'monospace')),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: active ? AppColors.white : AppColors.gray.withValues(alpha: 0.5),
        border: Border.all(color: AppColors.white, width: 2),
      ),
      child: Column(
        children: [
          Text(lbl, style: TextStyle(fontSize: 10, color: AppColors.black, fontWeight: FontWeight.bold, letterSpacing: 1)),
          timeText,
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      color: AppColors.black,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          // ROW 1: Undo | Hint | Restart
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildControl(Icons.undo, "UNDO", _undoMove),
              _buildControl(Icons.lightbulb_outline, "HINT", () => _controller.requestHint()),
              _buildControl(Icons.refresh, "RESTART", _restartGame),
            ],
          ),
          const SizedBox(height: 16),
          
          // ROW 2: Resign | Pause
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildControl(Icons.flag, "RESIGN", () => _onTimeout(isPlayer: true)),
              _buildControl(_isPaused ? Icons.play_arrow : Icons.pause, _isPaused ? "RESUME" : "PAUSE", () {
                setState(() => _isPaused = !_isPaused);
              }),
            ],
          ),
          const SizedBox(height: 16),
          
          // ROW 3: AI Dropdown | Toggle Auto Play
          if (!_controller.vsPlayer)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("AI LEVEL", style: AppTextStyles.body),
                DropdownButton<int>(
                  value: _controller.aiLevel,
                  dropdownColor: AppColors.black,
                  style: AppTextStyles.body,
                  iconEnabledColor: AppColors.white,
                  items: const [
                    DropdownMenuItem(value: 1, child: Text('EASY (1)')),
                    DropdownMenuItem(value: 2, child: Text('MEDIUM (2)')),
                    DropdownMenuItem(value: 3, child: Text('HARD (3)')),
                    DropdownMenuItem(value: 4, child: Text('EXPERT (4)')),
                  ],
                  onChanged: (v) {
                    if (v != null) _controller.setAiLevel(v);
                  },
                ),
                Row(
                  children: [
                    Text("AUTO AI", style: AppTextStyles.body),
                    Switch(
                      value: _controller.isAiEnabled,
                      activeThumbColor: AppColors.white,
                      activeTrackColor: AppColors.gray,
                      inactiveThumbColor: AppColors.gray,
                      inactiveTrackColor: AppColors.black,
                      onChanged: _controller.toggleAutoAi,
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildControl(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: AppColors.white, size: 28),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: AppColors.white, fontSize: 10, letterSpacing: 1)),
        ],
      ),
    );
  }
}
